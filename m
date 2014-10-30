From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] gre: Fix regression in gretap TSO support
Date: Thu, 30 Oct 2014 09:51:13 -0400
Message-ID: <CADVnQykSY_Q3HL0T1uNO4iUheWTpTsLLF7gCnM4SbJyGp3x6Wg@mail.gmail.com>
References: <20141030032430.4452.46388.stgit@ahduyck-workstation.home>
	<CALnjE+oK-O-PJH_u50HqQQLnvh+GyeCnv6tNQf5qzL0o1RiPQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: alexander.duyck@gmail.com, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:33451 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759765AbaJ3NvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 09:51:14 -0400
Received: by mail-qc0-f182.google.com with SMTP id m20so4239410qcx.27
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 06:51:13 -0700 (PDT)
In-Reply-To: <CALnjE+oK-O-PJH_u50HqQQLnvh+GyeCnv6tNQf5qzL0o1RiPQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 30, 2014 at 1:14 AM, Pravin Shelar <pshelar@nicira.com> wrote:
> On Wed, Oct 29, 2014 at 8:26 PM,  <alexander.duyck@gmail.com> wrote:
>> From: Alexander Duyck <alexander.h.duyck@redhat.com>
>>
>> On recent kernels I found that TSO on gretap interfaces didn't work.  After
>> bisecting it I found that commit b884b1a4 had introduced a regression in
>> which the Ethernet header was being included in the GRE header length.
>>
>> This change corrects that by basing the GRE header length on the inner mac
>> header in the case of GRE tunnels using transparent Ethernet bridging, and
>> uses the network header for all other GRE tunnel types.
>>
>> Fixes: b884b1a4 ("gre_offload: simplify GRE header length calculation in gre_gso_segment()")

Hmm. There may be other protocols, either now or in the future, where
we want to be able to have a mac header inside the GRE header, rather
than a network header. AFAICT it would be safer to revert b884b1a4,
and go back to the previous code (from c50cd357), where we parse the
GRE header to figure out its length.

neal
