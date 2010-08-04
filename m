From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] cls_rsvp: add sanity check for the packet length
Date: Wed, 04 Aug 2010 09:42:07 -0400
Message-ID: <1280929327.5669.10.camel@bigi>
References: <1280912124-30374-1-git-send-email-xiaosuo@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:60107 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757526Ab0HDNmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 09:42:43 -0400
Received: by ywh1 with SMTP id 1so1955001ywh.19
        for <netdev@vger.kernel.org>; Wed, 04 Aug 2010 06:42:42 -0700 (PDT)
In-Reply-To: <1280912124-30374-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-08-04 at 16:55 +0800, Changli Gao wrote:
> The packet length should be checked before the packet data is dereferenced.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  net/sched/cls_rsvp.h |   10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
> index dd9414e..4fa119d 100644
> --- a/net/sched/cls_rsvp.h
> +++ b/net/sched/cls_rsvp.h
> @@ -143,9 +143,17 @@ static int rsvp_classify(struct sk_buff *skb, struct tcf_proto *tp,
>  	u8 tunnelid = 0;
>  	u8 *xprt;
>  #if RSVP_DST_LEN == 4
> -	struct ipv6hdr *nhptr = ipv6_hdr(skb);
> +	struct ipv6hdr *nhptr;
> +
> +	if (!pskb_may_pull(skb, skb_network_offset(skb) + sizeof(*nhptr)))
> +		return -1;
> +	nhptr = ipv6_hdr(skb);
>  #else
>  	struct iphdr *nhptr = ip_hdr(skb);
> +
> +	if (!pskb_may_pull(skb, skb_network_offset(skb) + sizeof(*nhptr)))
> +		return -1;
> +	nhptr = ip_hdr(skb);
>  #endif

Maybe a good time to move nhptr declaration outside #if since it is used
in #else as well.

Otherwise:
Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

cheers,
jamal

