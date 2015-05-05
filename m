From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH -next 4/5] net: sched: remove AT INGRESS/EGRESS
Date: Tue, 05 May 2015 13:06:46 +0200
Message-ID: <5548A446.90901@iogearbox.net>
References: <1430765318-13788-1-git-send-email-fw@strlen.de> <1430765318-13788-5-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, alexei.starovoitov@gmail.com
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60474 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757853AbbEELGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 07:06:55 -0400
In-Reply-To: <1430765318-13788-5-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/2015 08:48 PM, Florian Westphal wrote:
> use single marker to propagate location.
> tc_at_ingress 1: ingress, 0 is egress.
>
> The new flag is set/unset in sch_ingress instead of the core.
> We will also no longer set skb->tc_verd to AT_EGRESS in the xmit
> handler.
>
> Signed-off-by: Florian Westphal <fw@strlen.de>
...
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 911d84e..d794077 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -488,6 +488,7 @@ static inline u32 skb_mstamp_us_delta(const struct skb_mstamp *t1,
>    *	@queue_mapping: Queue mapping for multiqueue devices
>    *	@xmit_more: More SKBs are pending for this queue
>    *	@tc_from_ingress: skb is processed during rx, not transmit
> + *	@tc_at_ingress: skb is processed during rx, not transmit

Minor nit:

I think both comments needs to be a bit more clear. I.e. tc_at_ingress
tells the *current* location whether we are invoked from ingress or
egress. And, tc_from_ingress explains the *previous* location, whether
the skbs has been mirred from ingress path or egress path.

Otherwise, the rest looks good to me.

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
