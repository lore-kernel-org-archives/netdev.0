From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] bridge: partial rtnetlink hooks
Date: Thu, 27 Apr 2006 10:24:18 +0200
Message-ID: <44507FB2.5050002@trash.net>
References: <20060426104521.44682924@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:25521 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S964976AbWD0IYU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Apr 2006 04:24:20 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060426104521.44682924@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> This is the start of adding support for rtnetlink to the bridge code.
> So far it only supports accessing the list of links and notifying
> about link changes. It is just a prototype to get early feedback, don't
> use to build your own masterpiece yet.
> 

> +static int br_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
> +{
> +	struct net_device *dev;
> +	int idx = 0;
> +	int err = 0;
> +
> +	printk(KERN_DEBUG "bridge dump ifinfo\n");
> +	for (dev = dev_base; dev; dev = dev->next) {
> +		struct net_bridge_port *p = rcu_dereference(dev->br_port);


I think using rcu_dereference (especially without rcu_read_lock()) is
a bit misleading, the pointer is actually protected by the RTNL at
this point.

