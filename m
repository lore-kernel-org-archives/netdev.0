From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next 4/5] net: sched: remove AT INGRESS/EGRESS
Date: Tue, 5 May 2015 13:11:32 +0200
Message-ID: <20150505111132.GD17061@breakpoint.cc>
References: <1430765318-13788-1-git-send-email-fw@strlen.de>
 <1430765318-13788-5-git-send-email-fw@strlen.de>
 <5548A446.90901@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	jhs@mojatatu.com, alexei.starovoitov@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:48558 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753042AbbEELLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 07:11:34 -0400
Content-Disposition: inline
In-Reply-To: <5548A446.90901@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 05/04/2015 08:48 PM, Florian Westphal wrote:
> >use single marker to propagate location.
> >tc_at_ingress 1: ingress, 0 is egress.
> >
> >The new flag is set/unset in sch_ingress instead of the core.
> >We will also no longer set skb->tc_verd to AT_EGRESS in the xmit
> >handler.
> >
> >Signed-off-by: Florian Westphal <fw@strlen.de>
> ...
> >diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> >index 911d84e..d794077 100644
> >--- a/include/linux/skbuff.h
> >+++ b/include/linux/skbuff.h
> >@@ -488,6 +488,7 @@ static inline u32 skb_mstamp_us_delta(const struct skb_mstamp *t1,
> >   *	@queue_mapping: Queue mapping for multiqueue devices
> >   *	@xmit_more: More SKBs are pending for this queue
> >   *	@tc_from_ingress: skb is processed during rx, not transmit
> >+ *	@tc_at_ingress: skb is processed during rx, not transmit
> 
> Minor nit:
> 
> I think both comments needs to be a bit more clear. I.e. tc_at_ingress
> tells the *current* location whether we are invoked from ingress or
> egress. And, tc_from_ingress explains the *previous* location, whether
> the skbs has been mirred from ingress path or egress path.

Agree, the reason is that I tried to go with single tc_ingress:1 but it
turned out to be not as trivial as I thought.

I'll fix it up in v2, I'll wait a bit more though to give others
a chance to comment.

Thanks for reviewing!
