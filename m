From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] net: Cache route in IP tunnels
Date: Fri, 13 Dec 2013 09:53:52 +0200 (EET)
Message-ID: <alpine.LFD.2.10.1312130948220.2431@ja.home.ssi.bg>
References: <alpine.DEB.2.02.1312112207400.27914@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:42806 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750830Ab3LMHya (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Dec 2013 02:54:30 -0500
In-Reply-To: <alpine.DEB.2.02.1312112207400.27914@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 11 Dec 2013, Tom Herbert wrote:

> +static inline void
> +tunnel_dst_set(struct ip_tunnel *t, struct dst_entry *dst)
> +{
> +	struct dst_entry *old_dst;
> +
> +	spin_lock(&t->dst_lock);
> +	old_dst = rcu_dereference_raw(t->dst_cache);
> +	rcu_assign_pointer(t->dst_cache, dst);
> +	dst_release(old_dst);
> +	spin_unlock(&t->dst_lock);

	It seems the func is also called by ip_tunnel_update(),
do we need _bh locks in such case?

> +}
> +
> +static inline void
> +tunnel_dst_reset(struct ip_tunnel *t)
> +{
> +	tunnel_dst_set(t, NULL);
> +}
> +

...

> @@ -696,6 +750,7 @@ static void ip_tunnel_update(struct ip_tunnel_net *itn,
>  		if (set_mtu)
>  			dev->mtu = mtu;
>  	}
> +	tunnel_dst_reset(t);
>  	netdev_state_change(dev);
>  }

Regards

--
Julian Anastasov <ja@ssi.bg>
