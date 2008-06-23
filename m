From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 07/25] netns ct: per-netns expectations
Date: Mon, 23 Jun 2008 12:27:53 +0200
Message-ID: <485F7AA9.7000308@trash.net>
References: <20080622010643.GH5392@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	den@openvz.org, xemul@openvz.org, ebiederm@xmission.com,
	benjamin.thery@bull.net, dlezcano@fr.ibm.com
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44351 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753578AbYFWK15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 06:27:57 -0400
In-Reply-To: <20080622010643.GH5392@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> Make per-netns expectation count, expectation hash.
> 
> netns of expectations is netns of its master conntrack.
> This way expectation is not bloated with netns pointer and something
> is seriously wrong anyway if those two differ.
> 
> +static inline struct net *exp_net(struct nf_conntrack_expect *exp)
> +{
> +#ifdef CONFIG_NET_NS
> +	return exp->master->ct_net;	/* by definition */
> +#else
> +	return &init_net;
> +#endif
> +}

nf_ct_exp_net() or nf_ct_expect_net() please.

> --- a/net/netfilter/nf_conntrack_expect.c
> +++ b/net/netfilter/nf_conntrack_expect.c
> @@ -28,17 +28,12 @@
>  #include <net/netfilter/nf_conntrack_helper.h>
>  #include <net/netfilter/nf_conntrack_tuple.h>
>  
> -struct hlist_head *nf_ct_expect_hash __read_mostly;
> -EXPORT_SYMBOL_GPL(nf_ct_expect_hash);
> -
>  unsigned int nf_ct_expect_hsize __read_mostly;
>  EXPORT_SYMBOL_GPL(nf_ct_expect_hsize);

This one also needs to be in the namespace I think. BTW, are
module parameters also per namespace?

