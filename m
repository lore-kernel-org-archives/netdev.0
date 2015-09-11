From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net 1/5] ipv6: Refactor common ip6gre_tunnel_init
 codes
Date: Fri, 11 Sep 2015 15:30:59 -0700 (PDT)
Message-ID: <20150911.153059.459077104316140368.davem@davemloft.net>
References: <1441994781-2718585-1-git-send-email-kafai@fb.com>
	<1441994781-2718585-2-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	hannes@stressinduktion.org, kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50872 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752853AbbIKWbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 18:31:02 -0400
In-Reply-To: <1441994781-2718585-2-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Fri, 11 Sep 2015 11:06:17 -0700

> @@ -1460,19 +1474,16 @@ static void ip6gre_netlink_parms(struct nlattr *data[],
>  static int ip6gre_tap_init(struct net_device *dev)
>  {
>  	struct ip6_tnl *tunnel;
> +	int ret;
>  
> -	tunnel = netdev_priv(dev);
> +	ret = ip6gre_tunnel_init_common(dev);
> +	if (ret)
> +		return ret;
>  
> -	tunnel->dev = dev;
> -	tunnel->net = dev_net(dev);
> -	strcpy(tunnel->parms.name, dev->name);
> +	tunnel = netdev_priv(dev);
>  
>  	ip6gre_tnl_link_config(tunnel, 1);
>  
> -	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
> -	if (!dev->tstats)
> -		return -ENOMEM;
> -
>  	return 0;
>  }

Is this really equivalent?

The existing code for GRE tap device initialization would use whatever
ether_setup() left in the broadcast address, it would leave
dev->dev_addr alone, and unconditionally use eth_header_ops.

You are changing behavior here, and it's been like this has been this
way long enough that I can't see clearly whether this is a valid
change or not.  It probably is not.

Either way, even if it is valid, you have to document what is happening
here and why it's ok.
