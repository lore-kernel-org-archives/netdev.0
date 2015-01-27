From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH ipsec-next] xfrm: Do not parse 32bits compiled xfrm
 netlink msg on 64bits host
Date: Mon, 26 Jan 2015 23:39:38 -0800 (PST)
Message-ID: <20150126.233938.513240875461315013.davem@davemloft.net>
References: <1422327262-6344-1-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, fengyuleidian0615@gmail.com
To: fan.du@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48100 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757183AbbA0Hjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 02:39:41 -0500
In-Reply-To: <1422327262-6344-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@intel.com>
Date: Tue, 27 Jan 2015 10:54:22 +0800

> @@ -2419,6 +2419,11 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
>  	const struct xfrm_link *link;
>  	int type, err;
>  
> +#ifdef CONFIG_COMPAT
> +	if (is_compat_task())
> +		return -EPERM;
> +#endif
> +

This seems more like an unsupported operation rather then a permission
problem.
