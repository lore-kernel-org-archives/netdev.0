From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Wed, 09 Mar 2016 16:10:38 -0500 (EST)
Message-ID: <20160309.161038.283281065293712589.davem@davemloft.net>
References: <20160309204158.GO2207@uranus.lan>
	<20160309.154725.1921352291794389965.davem@davemloft.net>
	<20160309205746.GQ2207@uranus.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, solar@openwall.com, vvs@virtuozzo.com,
	avagin@virtuozzo.com, xemul@virtuozzo.com, vdavydov@virtuozzo.com,
	khorenko@virtuozzo.com, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org
To: gorcunov@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160309205746.GQ2207@uranus.lan>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cyrill Gorcunov <gorcunov@gmail.com>
Date: Wed, 9 Mar 2016 23:57:47 +0300

> Aha! So in your patch __inet_del_ifa bypass first blocking_notifier_call_chain
> 
> __inet_del_ifa
> 	...
> 	if (in_dev->dead)
> 		goto no_promotions;
> 
> 	// First call to NETDEV_DOWN
> ...
> no_promotions:
> 	rtmsg_ifa(RTM_DELADDR, ifa1, nlh, portid);
> 	blocking_notifier_call_chain(&inetaddr_chain, NETDEV_DOWN, ifa1);
> 
> and here we call for NETDEV_DOWN, which then hits masq_device_event
> and go further to conntrack code.

Yes that's where the notifier comes from, which happens with or without
my patch.
