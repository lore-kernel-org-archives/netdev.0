From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bridge: add compile-time assert for cb struct size
Date: Mon, 02 Mar 2015 22:00:27 -0500 (EST)
Message-ID: <20150302.220027.1732186270596185340.davem@davemloft.net>
References: <1425351022-5415-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56218 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753759AbbCCDOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 22:14:03 -0500
In-Reply-To: <1425351022-5415-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue,  3 Mar 2015 03:50:22 +0100

> @@ -188,8 +188,11 @@ static const struct stp_proto br_stp_proto = {
>  
>  static int __init br_init(void)
>  {
> +	struct sk_buff *skb;
>  	int err;
>  
> +	BUILD_BUG_ON(sizeof(struct br_input_skb_cb) > sizeof(skb->cb));
> +
>  	err = stp_proto_register(&br_stp_proto);
>  	if (err < 0) {
>  		pr_err("bridge: can't register sap for STP\n");

The canonical way to do this, unless you needed the 'skb' variable
for another reason, is to use FIELD_SIZEOF().
