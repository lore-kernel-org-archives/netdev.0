From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Multicast routing stops functioning after 4G multicast packets
 recived.
Date: Sun, 5 Jan 2014 10:56:55 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1401051050320.1538@ja.home.ssi.bg>
References: <20131219144816.33310@gmx.com> <alpine.LFD.2.11.1401042143330.1598@ja.home.ssi.bg> <20140104233840.GD25828@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Bob Falken <NetFestivalHaveFun@gmx.com>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:53210 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750826AbaAEI5Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 03:57:16 -0500
In-Reply-To: <20140104233840.GD25828@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sun, 5 Jan 2014, Hannes Frederic Sowa wrote:

> I guess we should just try. I somehow forgot to look after that. Thanks
> for reminding, Julian.

	If that patch solves the problem, do not forget
to include same fix for ip6mr_fib_lookup(). As for net/decnet/,
it looks ok, it uses fib_rule_put() in dn_fib_res_put().

> Bob, can you try with this patch again?
> 
> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
> index 421a249..b9b3472 100644
> --- a/net/ipv4/ipmr.c
> +++ b/net/ipv4/ipmr.c
> @@ -157,9 +157,12 @@ static struct mr_table *ipmr_get_table(struct net *net, u32 id)
>  static int ipmr_fib_lookup(struct net *net, struct flowi4 *flp4,
>  			   struct mr_table **mrt)
>  {
> -	struct ipmr_result res;
> -	struct fib_lookup_arg arg = { .result = &res, };
>  	int err;
> +	struct ipmr_result res;
> +	struct fib_lookup_arg arg = {
> +		.result = &res,
> +		.flags = FIB_LOOKUP_NOREF,
> +	};
>  
>  	err = fib_rules_lookup(net->ipv4.mr_rules_ops,
>  			       flowi4_to_flowi(flp4), 0, &arg);

Regards

--
Julian Anastasov <ja@ssi.bg>
