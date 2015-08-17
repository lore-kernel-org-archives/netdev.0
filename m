From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1 net-next 0/5] netlink: mmap: kernel panic and some
 issues
Date: Mon, 17 Aug 2015 14:02:22 -0700 (PDT)
Message-ID: <20150817.140222.1763422851882964859.davem@davemloft.net>
References: <20150814085807.GA30443@gmail.com>
	<55CDBC84.8020605@iogearbox.net>
	<55CDC51D.1060204@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chamaken@gmail.com, netdev@vger.kernel.org, fw@strlen.de
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36208 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbbHQVCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 17:02:25 -0400
In-Reply-To: <55CDC51D.1060204@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 14 Aug 2015 12:38:21 +0200

> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 67d2104..4307446 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -238,6 +238,13 @@ static void __netlink_deliver_tap(struct sk_buff
> *skb)
> 
>  static void netlink_deliver_tap(struct sk_buff *skb)
>  {
> +	/* Netlink mmaped skbs must not access shared info, and thus
> +	 * are not allowed to be cloned. For now, just don't allow
> +	 * them to get inspected by taps.
> +	 */
> +	if (netlink_skb_is_mmaped(skb))
> +		return;
> +

I would seriously rather see us do an expensive full copy of the SKB
than to have traffic which is unexpectedly invisible to taps.
