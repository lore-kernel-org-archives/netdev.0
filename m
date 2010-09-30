From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next-2.6 3/5] XFRM,IPv6: Add IRO src/dst address
 remapping XFRM types and i/o handlers
Date: Wed, 29 Sep 2010 20:16:18 -0700 (PDT)
Message-ID: <20100929.201618.241458205.davem@davemloft.net>
References: <cover.1285749610.git.arno@natisbad.org>
	<fd4eec3c9486c46b535e89ceed479c7536f51fb9.1285749610.git.arno@natisbad.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, herbert@gondor.apana.org.au,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: arno@natisbad.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34420
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751348Ab0I3DP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 23:15:57 -0400
In-Reply-To: <fd4eec3c9486c46b535e89ceed479c7536f51fb9.1285749610.git.arno@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaud Ebalard <arno@natisbad.org>
Date: Wed, 29 Sep 2010 11:05:47 +0200

> +static int mip6_iro_src_reject(struct xfrm_state *x, struct sk_buff *skb, struct flowi *fl)
> +{
> +	int err = 0;
> +
> +	/* XXX We may need some reject handler at some point but it is not
> +	 * critical yet: see xfrm_secpath_reject() in net/xfrm/xfrm_policy.c
> +	 * and aslo what mip6_destopt_reject() implements */
> +
> +	printk("XXX FIXME: mip6_iro_src_reject() called\n");

pr_debug() or pr_err() or get rid of it altogher and use WARN_ON() or
similar.

> +	spin_lock(&x->lock);
> +	if (!ipv6_addr_equal(&iph->daddr, (struct in6_addr *)x->coaddr) &&
> +	    !ipv6_addr_any((struct in6_addr *)x->coaddr))
> +		err = -ENOENT;
> +	spin_unlock(&x->lock);

What are you actually protecting with this lock?  The moment you drop
it the x->coaddr can change which changes the result you should return
here.

I suspect you either don't need the lock, or you need to lock at a higher
level.

> +		printk(KERN_INFO "%s: spi is not 0: %u\n", __func__,

pr_info()

> +		printk(KERN_INFO "%s: state's mode is not %u: %u\n",

pr_info()

> +		       __func__, XFRM_MODE_ROUTEOPTIMIZATION,

Printing decimal values for CPP macro constants does not make log
messages very readable.
