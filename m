From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v8 02/11] ipv6: make ip6_dst_hoplimit() static
 inline
Date: Fri, 17 May 2013 14:13:27 -0700 (PDT)
Message-ID: <20130517.141327.2084320693913331713.davem@davemloft.net>
References: <1368750099-14086-1-git-send-email-amwang@redhat.com>
	<1368750099-14086-3-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43836 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756177Ab3EQVN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 17:13:28 -0400
In-Reply-To: <1368750099-14086-3-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Fri, 17 May 2013 08:21:30 +0800

> @@ -201,4 +200,24 @@ static inline struct in6_addr *rt6_nexthop(struct rt6_info *rt, struct in6_addr
>  	return dest;
>  }
>  
> +#if IS_ENABLED(CONFIG_IPV6)
> +static inline int ip6_dst_hoplimit(struct dst_entry *dst)
> +{
> +	int hoplimit = dst_metric_raw(dst, RTAX_HOPLIMIT);
> +	if (hoplimit == 0) {
> +		struct net_device *dev = dst->dev;
> +		struct inet6_dev *idev;
> +
> +		rcu_read_lock();
> +		idev = __in6_dev_get(dev);
> +		if (idev)
> +			hoplimit = idev->cnf.hop_limit;
> +		else
> +			hoplimit = dev_net(dev)->ipv6.devconf_all->hop_limit;
> +		rcu_read_unlock();
> +	}
> +	return hoplimit;
> +}
> +#endif

Create a dummy stub version in an #else branch here, so that you have
to ifdef less in vxlan.c

In fact I think you can avoid nearly every ifdef in vxlan.c if you apply
this technique throughout your changes.

Please do that and resubmit this series.

Thanks.
