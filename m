From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net/core: move vlan_depth out of while loop in
 skb_network_protocol()
Date: Tue, 12 Mar 2013 07:56:26 +0100
Message-ID: <1363071386.13690.7.camel@edumazet-glaptop>
References: <1363069844-10624-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:47123 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753416Ab3CLG4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 02:56:31 -0400
Received: by mail-ee0-f54.google.com with SMTP id c41so2615821eek.41
        for <netdev@vger.kernel.org>; Mon, 11 Mar 2013 23:56:30 -0700 (PDT)
In-Reply-To: <1363069844-10624-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-12 at 14:30 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> move vlan_depth out of while loop, or else vlan_depth always is ETH_HLEN,
> can not be increased, and lead to infinite loop when frame has two vlan headers.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  net/core/dev.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 90cee5b..35a6a6e 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2211,9 +2211,9 @@ EXPORT_SYMBOL(skb_checksum_help);
>  __be16 skb_network_protocol(struct sk_buff *skb)
>  {
>  	__be16 type = skb->protocol;
> +	int vlan_depth = ETH_HLEN;
>  
>  	while (type == htons(ETH_P_8021Q)) {
> -		int vlan_depth = ETH_HLEN;
>  		struct vlan_hdr *vh;
>  
>  		if (unlikely(!pskb_may_pull(skb, vlan_depth + VLAN_HLEN)))

Nice catch, bug added in commit 05e8ef4ab2d8087d (net: factor out
skb_mac_gso_segment() from skb_gso_segment() )

So this is a patch for net tree, not for net-next.

Acked-by: Eric Dumazet <edumazet@google.com>
