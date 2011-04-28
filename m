From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6] net: dont hold rtnl mutex during netlink
 dump callbacks
Date: Thu, 28 Apr 2011 08:40:48 -0700
Message-ID: <20110428084048.532d84e6@nehalam>
References: <1303980967.3360.60.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	Remi Denis-Courmont <remi.denis-courmont@nokia.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59720 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933156Ab1D1Pkv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2011 11:40:51 -0400
In-Reply-To: <1303980967.3360.60.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Apr 2011 10:56:07 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> @@ -1980,7 +1978,7 @@ static int __net_init rtnetlink_net_init(struct net *net)
>  {
>  	struct sock *sk;
>  	sk = netlink_kernel_create(net, NETLINK_ROUTE, RTNLGRP_MAX,
> -				   rtnetlink_rcv, &rtnl_mutex, THIS_MODULE);
> +				   rtnetlink_rcv, NULL, THIS_MODULE);

Looks like only genetlink is still using the mutex argument.
