From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 02/02] net/ipv4: VTI support new module for
 ip_vti.
Date: Thu, 28 Jun 2012 18:07:25 -0700 (PDT)
Message-ID: <20120628.180725.2244572424738509573.davem@davemloft.net>
References: <20120629005231.GA4511@debian-saurabh-64.vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: saurabh.mohan@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58069 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753788Ab2F2BH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 21:07:26 -0400
In-Reply-To: <20120629005231.GA4511@debian-saurabh-64.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saurabh <saurabh.mohan@vyatta.com>
Date: Thu, 28 Jun 2012 17:52:31 -0700

> +static struct rtnl_link_stats64 *vti_get_stats64(struct net_device *dev,
> +					       struct rtnl_link_stats64 *tot)

Imporperly indentex, all of the argument lines must line up with the first
column after the initial "(" on the first line.

> +static struct ip_tunnel *vti_tunnel_lookup(struct net *net,
> +					 __be32 remote, __be32 local)

Likewise.

> +static struct ip_tunnel **__vti_bucket(struct vti_net *ipn,
> +				     struct ip_tunnel_parm *parms)

Likewise.

> +static inline struct ip_tunnel **vti_bucket(struct vti_net *ipn,
> +					  struct ip_tunnel *t)

Likewise.

> +static struct ip_tunnel *vti_tunnel_locate(struct net *net,
> +					 struct ip_tunnel_parm *parms,
> +					 int create)

Likewise.

> +	for (tp = __vti_bucket(ipn, parms);
> +	     (t = rtnl_dereference(*tp)) != NULL;
> +	     tp = &t->next) {

I find it very amusing that you are able to format this for() statement
correctly, but in the entire patch #1 you were unable to.   It's like
this patch was written by a completely different person.

> +	rcu_read_lock();
> +	t = vti_tunnel_lookup(dev_net(skb->dev), iph->daddr, iph->saddr);
> +	if (t == NULL)
> +		goto out;

You should return -ENOENT, like ipip() does, when the tunnel cannot
be found.

> +	flowi4_init_output(&fl4, tunnel->parms.link,
> +		htonl(tunnel->parms.i_key), RT_TOS(tos), RT_SCOPE_UNIVERSE,
> +		IPPROTO_IPIP, 0,
> +		dst, tiph->saddr, 0, 0);

Indent these arguments properly.

> +		/*
> +		 * if there is no transform then this tunnel is not functional.
> +		 * Or if the xfrm is not mode tunnel.
> +		 */

Format comments:

	/* Like
	 * this.
	 */

Not:

	/*
	 * Like
	 * this.
	 */

> +		flowi4_init_output(&fl4, tunnel->parms.link,
> +				htonl(tunnel->parms.i_key), RT_TOS(iph->tos), RT_SCOPE_UNIVERSE,
> +				IPPROTO_IPIP, 0,
> +				iph->daddr, iph->saddr, 0, 0);

Fix this indentation.
