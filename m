From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 10/27] ixgb: Don't check for vlan group on transmit
Date: Mon, 13 Dec 2010 19:40:53 -0800
Message-ID: <AANLkTi=9+F-dxeZrvnTUXHjFniQdtxzHyCcdvMpn-ygf@mail.gmail.com>
References: <1292048241-22026-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1292048241-22026-11-git-send-email-jeffrey.t.kirsher@intel.com>
	<AANLkTi=mi7pSRXrOyiFx75Feuo29tpw9bJbvHf0BrC_s@mail.gmail.com>
	<EA929A9653AAE14F841771FB1DE5A136602D607104@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"bphilips@novell.com" <bphilips@novell.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:51289 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754672Ab0LNDkz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 22:40:55 -0500
Received: by fxm18 with SMTP id 18so228910fxm.2
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 19:40:53 -0800 (PST)
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A136602D607104@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 13, 2010 at 10:43 AM, Tantilov, Emil S
<emil.s.tantilov@intel.com> wrote:
>>-----Original Message-----
>>From: Jesse Gross [mailto:jesse@nicira.com]
>>Sent: Sunday, December 12, 2010 5:01 PM
>>To: Kirsher, Jeffrey T
>>Cc: davem@davemloft.net; Tantilov, Emil S; netdev@vger.kernel.org;
>>gospo@redhat.com; bphilips@novell.com
>>Subject: Re: [PATCH 10/27] ixgb: Don't check for vlan group on transm=
it
>>
>>On Fri, Dec 10, 2010 at 10:17 PM, Jeff Kirsher
>><jeffrey.t.kirsher@intel.com> wrote:
>>> From: Emil Tantilov <emil.s.tantilov@intel.com>
>>>
>>> Based on a patch from Jesse Gross.
>>>
>>> Enable vlan tag insertion even when vlan group is not configured.
>>>
>>> For ixgb HW both CTRL0.VME and VLE bit in the Tx descriptor need to=
 be
>>set
>>> in order to enable HW acceleration.
>>>
>>> Introduced separate functions for enabling/disabling of vlan tag
>>stripping
>>> similar to ixgbe.
>>
>>Thanks for working on this. =A0However, I don't think that this patch
>>actually does what it says.
>>
>>In ixgb_xmit_frame() it's still checking whether adapter->vlgrp is
>>non-null before inserting a tag, so it will drop tags unless a vlan
>>group is configured. =A0Also, since it's not currently possible to
>>toggle NETIF_F_HW_VLAN_RX, vlan stripping will never get disabled.
>>This is actually a regression since before vlan stripping would get
>>disabled if no vlan group was configured. =A0Now, vlan headers will g=
et
>>silently dropped if there is no vlan group.
> I'm sorry. This patch was supposed to include your original patch tha=
t
> removed the vlgrp check on Tx. Somehow that didn't make it (I may hav=
e generated the patch from the wrong branch).
>
>>Regardless of that, I still think this is a useful change on the road
>>towards adopting the new vlan interfaces, the problem is just that
>>currently it's halfway in between the old and the new. =A0Given that,=
 it
>>would obviously be much better to move all the way over the new when
>>addressing this.
> Since this patch is already applied can you submit your change again?

Sure.  I think it's probably best to just complete the conversion to
the new vlan interfaces, so I went ahead and did that.  It's much
easier now that you've pulled the hardware specific bits out for
enabling/disabling vlan offloading.  I'll send out that patch shortly
- please take a look since I don't have the hardware to test it.

>
>>Out of curiosity, is the implication of this that vlan insertion on
>>transmit and stripping on receive are always configured together? =A0=
I
>>don't have hardware supported by this driver but when I worked on
>>ixgbe (which is at least superficially similar in this area) I didn't
>>have any problems configuring them independently.
>
> Yes - the design of the original 10GB HW supported in ixgb does not a=
llow
> setting Tx and Rx independently. As you mentioned ixgbe does not have
> this problem.

OK, thanks for the explanation.
