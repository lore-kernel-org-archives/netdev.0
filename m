From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] bridge: Remove BR_PROXYARP flooding check code
Date: Tue, 9 Dec 2014 14:21:58 -0800
Message-ID: <20141209142158.7e513dbf@urahara>
References: <1418052460-30691-1-git-send-email-jouni@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Kyeyoon Park <kyeyoonp@codeaurora.org>
To: Jouni Malinen <jouni@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:37995 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752818AbaLIWWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 17:22:09 -0500
Received: by mail-pd0-f181.google.com with SMTP id v10so1420177pde.12
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 14:22:08 -0800 (PST)
In-Reply-To: <1418052460-30691-1-git-send-email-jouni@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  8 Dec 2014 17:27:40 +0200
Jouni Malinen <jouni@codeaurora.org> wrote:

> From: Kyeyoon Park <kyeyoonp@codeaurora.org>
> 
> Because dropping broadcast packets for IEEE 802.11 Proxy ARP is more
> selective than previously thought, it is better to remove the direct
> dropping logic in the bridge code in favor of using the netfilter
> infrastructure to provide more control on which frames get dropped. This
> code was added in commit 958501163ddd ("bridge: Add support for IEEE
> 802.11 Proxy ARP").
> 
> Signed-off-by: Kyeyoon Park <kyeyoonp@codeaurora.org>
> Signed-off-by: Jouni Malinen <jouni@codeaurora.org>
> ---
>  net/bridge/br_forward.c | 4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
> index f96933a..8a025a7 100644
> --- a/net/bridge/br_forward.c
> +++ b/net/bridge/br_forward.c
> @@ -185,10 +185,6 @@ static void br_flood(struct net_bridge *br, struct sk_buff *skb,
>  		if (unicast && !(p->flags & BR_FLOOD))
>  			continue;
>  
> -		/* Do not flood to ports that enable proxy ARP */
> -		if (p->flags & BR_PROXYARP)
> -			continue;
> -
>  		prev = maybe_deliver(prev, p, skb, __packet_hook);
>  		if (IS_ERR(prev))
>  			goto out;

Aren't you at risk of duplicate ARP responses in some cases.
You can't assume user will run netfilter.
