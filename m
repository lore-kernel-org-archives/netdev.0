From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/9] ipv6: sr: add code base for control plane support
 of SR-IPv6
Date: Mon, 17 Oct 2016 11:00:55 -0400 (EDT)
Message-ID: <20161017.110055.762862023679772858.davem@davemloft.net>
References: <1476715350-18983-1-git-send-email-david.lebrun@uclouvain.be>
        <1476715350-18983-3-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56362 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932698AbcJQPA4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 11:00:56 -0400
In-Reply-To: <1476715350-18983-3-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <david.lebrun@uclouvain.be>
Date: Mon, 17 Oct 2016 16:42:23 +0200

> +static int seg6_genl_set_tunsrc(struct sk_buff *skb, struct genl_info *info)
> +{
> +	struct net *net = genl_info_net(info);
> +	struct seg6_pernet_data *sdata = seg6_pernet(net);
> +	struct in6_addr *val, *t_old, *t_new;

Please ordre local variables from longest to shortest line (AKA reverse
christmas tree layout).

Please audit your entire submission for this problem.

> +	val = (struct in6_addr *)nla_data(info->attrs[SEG6_ATTR_DST]);

Please remove all casts from void pointers, they are completely unecessary.
Since nla_data() returns "(void *)", this applies here.

Please audit your entire submission for this problem.

> +	mutex_init(&sdata->lock);
> +
> +	sdata->tun_src = kzalloc(sizeof(*sdata->tun_src), GFP_KERNEL);
> +	if (!sdata->tun_src) {
> +		kfree(sdata);
> +		return -ENOMEM;

Best not to free an object while you still hold a mutex inside of it.

Also taking the mutex makes no sense at all, this object has no global
visibility, therefore no other thread of control can operate upon it.
