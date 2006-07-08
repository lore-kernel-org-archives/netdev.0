From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 07 Jul 2006 17:05:11 -0700 (PDT)
Message-ID: <20060707.170511.52188432.davem@davemloft.net>
References: <200605161102.29472.kelly@au.ibm.com>
	<20060515.221637.90861876.davem@davemloft.net>
	<200606221205.35161.kelly@au.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:157
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932334AbWGHAEk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 20:04:40 -0400
To: kelly@au1.ibm.com
In-Reply-To: <200606221205.35161.kelly@au.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kelly Daly <kelly@au1.ibm.com>
Date: Thu, 22 Jun 2006 12:05:35 +1000

> > The hash table bits look good, just as they did last time :-)
> > So I'll put this part into my vj-2.6 tree now, thanks.
> Rockin' - thanks...
> 
> Sorry for the massive delay - here's the next attempt.

My review delay was just as bad if not worse :-)

> +static int sock_add_netchannel(struct sock *sk)
> +{
> +	struct netchannel *np;
> +
> +	np = kmalloc(sizeof(struct netchannel), GFP_KERNEL);
> +	if (!np)
> +		return -ENOMEM;
> +	netchannel_init(np, netchannel_wake, (void *)np);
> +	sk->sk_channel = np;
> +
> +	return 0;
> +}

This function is unreferenced entirely?  It's marked static,
so don't bother including it unless it is being used.

Fix this, give me a good changelog and signed-off-by line
and I'll stick this into the vj-2.6 tree

Thanks!
