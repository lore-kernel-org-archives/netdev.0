From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 1/5] vxlan: implement GPE in L2 mode
Date: Tue, 1 Mar 2016 19:16:22 +0100
Message-ID: <20160301191622.53df6f3f@griffin>
References: <cover.1456472746.git.jbenc@redhat.com>
	<6fe53252314d644e994950522d4320bc54ced928.1456472746.git.jbenc@redhat.com>
	<CALx6S34vm6nqce481mcH_S3sfc4B5ift7YwJmTba4Vvdvnmj3w@mail.gmail.com>
	<20160227203142.5b7309f3@griffin>
	<CALx6S358JT6HRR70SgJrNOsTg4LbnTXERpW6n0DDiXKqxg--Yg@mail.gmail.com>
	<20160229112322.4da0f0c0@griffin>
	<CALx6S37aU8q1QResU+HKMeCbMgkGDqWbnuckqs1V_9bC-jp8Ow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54979 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750846AbcCASQ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2016 13:16:28 -0500
In-Reply-To: <CALx6S37aU8q1QResU+HKMeCbMgkGDqWbnuckqs1V_9bC-jp8Ow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 Feb 2016 09:13:50 -0800, Tom Herbert wrote:
> As defined now, GPB can't be used with VXLAN-GPE at all, but when I
> read your patch it looks very much like GPB is being checked and
> allowed in the VXLAN-GPE path. The fact that "if (vs->flags &
> VXLAN_F_GBP)" always fails for VXLAN-GPE packets because of
> configuration constraints is not at all obvious, and really this just
> results in an unnecessary conditional that gives the same answer for
> every single VXLAN-GPE packet which we've already checked for just a
> few lines above. At least the check for GPB could be moved to an else
> block of " if (vs->flags & VXLAN_F_GPE)", this alone improves clarity
> and eliminates an unnecessary conditional in the VXLAN-GPE path.

The problem here is ordering. GPE needs to be called before
iptunnel_pull_header, while GBP needs to be called after udp_tun_rx_dst
(and hence after iptunnel_pull_header).

I agree that it's a check that's done for every packet and would be
nice to get rid of. On the other hand, the amount of processing in the
rx path of vxlan is so huge that it hardly matters. Yes, we should work
on overall vxlan performance and it's something I'm actually looking
into.

As for not being obvious that the GBP processing can't happen, I see
your point. I'll add a comment that explains this to the code in v2.

Thanks,

 Jiri
