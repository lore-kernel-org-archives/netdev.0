From: David Miller <davem@davemloft.net>
Subject: Re: 4.4-rc2 xfrm_lookup kasan trace
Date: Thu, 03 Dec 2015 11:59:18 -0500 (EST)
Message-ID: <20151203.115918.730123340200500473.davem@davemloft.net>
References: <20151130232733.GA27119@codemonkey.org.uk>
	<1448932931.25582.2.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@codemonkey.org.uk, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41356 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753049AbbLCQ7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 11:59:19 -0500
In-Reply-To: <1448932931.25582.2.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 30 Nov 2015 17:22:11 -0800

> @@ -2198,6 +2198,7 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
>  	xdst = NULL;
>  	route = NULL;
>  
> +	sk = sk_to_full_sk((struct sock *)sk);

The war against const...

I know this is the only instance where const is input, but you may want to
consider adding the const verion of the helper anyways to avoid ugly casts
like this.
