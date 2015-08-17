From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 4/4] net: Identifier Locator Addressing
 module
Date: Mon, 17 Aug 2015 12:09:33 -0700 (PDT)
Message-ID: <20150817.120933.1027656588494926587.davem@davemloft.net>
References: <1439837957-673905-1-git-send-email-tom@herbertland.com>
	<1439837957-673905-5-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35624 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625AbbHQTJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 15:09:34 -0400
In-Reply-To: <1439837957-673905-5-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Mon, 17 Aug 2015 11:59:17 -0700

> +static int ila_build_state(struct net_device *dev, struct nlattr *nla,
> +			   struct lwtunnel_state **ts)
> +{
> +	struct ila_params *p;
> +	struct nlattr *tb[ILA_ATTR_MAX + 1];
> +	size_t encap_len = sizeof(*p);
> +	struct lwtunnel_state *newts;
> +	int ret;
> +
> +	ret = nla_parse_nested(tb, ILA_ATTR_MAX, nla,
> +			       ila_nl_policy);
> +	if (ret < 0)
> +		return ret;
> +
> +	newts = lwtunnel_state_alloc(encap_len);
> +	if (!newts)
> +		return -ENOMEM;
> +
> +	newts->len = encap_len;
> +	p = ila_params_lwtunnel(newts);
> +
> +	if (!tb[ILA_ATTR_LOCATOR])
> +		return -EINVAL;

This final error check leaks 'newts'.

You should probably just validate that ILA_ATTR_LOCATOR is present
before allocating any resources at all.
