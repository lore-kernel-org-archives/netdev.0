From: David Miller <davem@davemloft.net>
Subject: Re: 802.1q HW filter spammage in 3.7.2+ kernels.
Date: Wed, 16 Jan 2013 01:11:20 -0500 (EST)
Message-ID: <20130116.011120.2166745757980086775.davem@davemloft.net>
References: <50F60404.3090605@candelatech.com>
	<1358316108.19956.82.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55714 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757544Ab3APGLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 01:11:23 -0500
In-Reply-To: <1358316108.19956.82.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Jan 2013 22:01:48 -0800

> @@ -828,7 +828,12 @@ static int macvlan_changelink(struct net_device *dev,
>  
>  static size_t macvlan_get_size(const struct net_device *dev)
>  {
> -	return nla_total_size(4);
> +	return
> +		/* IFLA_MACVLAN_MODE, */
> +		nla_total_size(4) +
> +		/* IFLA_MACVLAN_FLAGS */
> +		nla_total_size(2) +
> +		0;


Maybe:

	return (nla_total_size(4) + /* IFLA_MACVLAN_MODE, */
		nla_total_size(2) + /* IFLA_MACVLAN_FLAGS */
		0);
