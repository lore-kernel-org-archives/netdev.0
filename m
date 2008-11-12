From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: #ifdef inet_bind_bucket::ib_net
Date: Wed, 12 Nov 2008 04:24:23 -0800 (PST)
Message-ID: <20081112.042423.237213345.davem@davemloft.net>
References: <20081112104439.GA4292@x200.localdomain>
	<491AB4F5.2070206@cosmosbay.com>
	<20081112122448.GA12646@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47246
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753727AbYKLMYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 07:24:23 -0500
In-Reply-To: <20081112122448.GA12646@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Wed, 12 Nov 2008 15:24:48 +0300

> +static inline void ib_net_set(struct inet_bind_bucket *ib, struct net *net)
> +{
> +#ifdef CONFIG_NET_NS
> +	ib->ib_net = net;
> +#endif
> +}
> +

It's basically read_pnet() hidden behind another name.
And you'll add new "aliases" for read_pnet() over and over
again.

That makes no sense to me.

I like read_pnet() much better, and the only thing that
can be improved is read_pnet()'d name (along with the
name of every other similar interface already in
net_namespace.h)
