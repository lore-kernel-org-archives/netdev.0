From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] datapath: Add basic MPLS support to kernel
Date: Fri, 14 Jun 2013 12:51:24 -0700
Message-ID: <CAEP_g=8nU+K70onAcAw=ms7hHjC8TncRHSN6jMhrKfme5AQgdQ@mail.gmail.com>
References: <1370851669-32400-1-git-send-email-horms@verge.net.au>
 <CAEP_g=_rC9unxv13xvEL3fpC4i2p9rcSWMo4NOeHFWHsp36QRw@mail.gmail.com> <20130612063526.GA16477@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Ben Pfaff <blp@nicira.com>,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>,
	Joe Stringer <joe@wand.net.nz>,
	Pravin Shelar <pshelar@nicira.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:53324 "HELO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751217Ab3FNTvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 15:51:45 -0400
Received: by mail-ie0-f169.google.com with SMTP id 10so2329726ied.28
        for <netdev@vger.kernel.org>; Fri, 14 Jun 2013 12:51:44 -0700 (PDT)
In-Reply-To: <20130612063526.GA16477@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 11, 2013 at 11:35 PM, Simon Horman <horms@verge.net.au> wrote:
> On Tue, Jun 11, 2013 at 02:26:32PM -0700, Jesse Gross wrote:
>> When looking at this, I had an additional thought: different versions
>> of OpenFlow define the tag order differently and there is some limited
>> flexibility in how they get applied. Obviously, we're assuming that
>> vlans are applied before MPLS here. However, I'm not sure that is
>> actually required and may even simplify things (for example, your MPLS
>> GSO code doesn't do anything special with vlans and it should continue
>> to just work either way). I'm hesitant to suggest changes at this
>> point but it might actually make things cleaner and work with the
>> general model that we already have.
>
> Unsurprisingly I am also hesitant.
>
> I'm not sure that my readings of the specs leads to different valid
> orderings but if they are specified I am somewhat surprised.
>
> I believe that we could get bogged down in discussing various
> specifications without too much difficulty and at the risk of doing so I
> will explain my interpretation of Open Flow 1.3.2.
>
> Section 5.12 states:
>
> "Newly pushed tags should always be inserted as the outermost tag in the
> outermost valid location for that tag.".
>
> And RFC 3032 MPLS Label Stack Encoding states in section 2.1:
>
> "The label stack entries appear AFTER the data link layer headers, but
> BEFORE any network layer headers.".
>
> My reading is that the only valid location for an MPLS LSE to be pushed
> is after the L2 header including any VLAN tags that may be present. And
> that the only valid place to push any VLAN tags is after the L2 header,
> that is, before the MPLS label stack if it is present.
>
> Of course there may be other relevant RFCs that I have not examined.

My goal is also to avoid getting bogged down in various specs and
RFCs, which to some extent being flexible actually helps to avoid. The
specific scenario that triggered this thought is QinQ: since it
typically uses a different EtherType, which we don't support at the
moment, we would push the MPLS header before the vlan. However, if we
added support for QinQ then we would start push the MPLS header, which
seems an undesirable change.
