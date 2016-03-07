From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] ipv6: per netns fib6 walkers
Date: Mon, 07 Mar 2016 14:48:46 -0500 (EST)
Message-ID: <20160307.144846.1271615479587219087.davem@davemloft.net>
References: <cover.1457085016.git.mkubecek@suse.cz>
	<6df8e224d6337b658a097ac87e72e1467cddf13d.1457085016.git.mkubecek@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, hannes@stressinduktion.org, kafai@fb.com
To: mkubecek@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53512 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753798AbcCGTst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 14:48:49 -0500
In-Reply-To: <6df8e224d6337b658a097ac87e72e1467cddf13d.1457085016.git.mkubecek@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>
Date: Fri,  4 Mar 2016 11:59:25 +0100 (CET)

> @@ -1978,6 +1980,12 @@ static int ipv6_route_yield(struct fib6_walker *w)
>  
>  static void ipv6_route_seq_setup_walk(struct ipv6_route_iter *iter)
>  {
> +#ifdef CONFIG_NET_NS
> +	struct net *net = iter->p.net;
> +#else
> +	struct net *net = &init_net;
> +#endif

Please use read_pnet(), it exists so that we don't need to do ugly CPP
stuff like this in *.c files.

Thanks.
