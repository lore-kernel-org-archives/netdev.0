From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: Change skb->data before using icmpv6_notify()
 to propagate redirect
Date: Thu, 13 Dec 2012 12:59:11 -0500 (EST)
Message-ID: <20121213.125911.566802923957164958.davem@davemloft.net>
References: <50C9BA41.1010507@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: djduanjiong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39828 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755904Ab2LMR7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 12:59:16 -0500
In-Reply-To: <50C9BA41.1010507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <djduanjiong@gmail.com>
Date: Thu, 13 Dec 2012 19:21:37 +0800

> +	if (!ndisc_parse_options(msg->opt, ndoptlen, &ndopts)) {
> +		ND_PRINTK(2, warn,
> +			  "Redirect: invalid ND options\n");

Do not add more uses of such baroque kernel logging mechanisms.

> +	if (!ndopts.nd_opts_rh) {
> +		return;
> +	}

Single statement basic blocks should never be surrounded by
curly braces, they just waste lines.

> +	hdr = (u8 *)ndopts.nd_opts_rh;

(u8 *)[SPACE]ndopts...

> +	if(!pskb_pull(skb, hdr - skb_transport_header(skb))) {

if[SPACE](...
