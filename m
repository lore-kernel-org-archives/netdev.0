From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: Make address flushing on ifdown optional -
 v2
Date: Sat, 31 Jan 2015 17:17:09 -0800 (PST)
Message-ID: <20150131.171709.1522796376864907030.davem@davemloft.net>
References: <1422504065-17445-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@redhat.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60898 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752090AbbBABRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2015 20:17:10 -0500
In-Reply-To: <1422504065-17445-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Wed, 28 Jan 2015 21:01:05 -0700

> @@ -3032,8 +3037,9 @@ static int addrconf_ifdown(struct net_device *dev, int how)
>  {
>  	struct net *net = dev_net(dev);
>  	struct inet6_dev *idev;
> -	struct inet6_ifaddr *ifa;
> +	struct inet6_ifaddr *ifa, *tmp;
>  	int state, i;
> +	struct list_head del_list;

Please order local variable declarations from longest to shortest line
(ie. reverse christmas tree) when it is easy to do so.

> +		/* 
> +		 * on NETDEV_DOWN events do not flush managed (user configured)
> +		 * addresses unless configured to do so. If the address is not
> +		 * deleted reset flags and state such that DAD is re-done on a
> + 		 * subsequent link up.
> + 		 */

Comments in the networking are to be formatted:

	/* Like
	 * this.
	 */

Thanks.
