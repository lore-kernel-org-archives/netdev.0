From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bridge: Assign rtnl_link_ops to bridge devices created
 via ioctl()
Date: Tue, 26 Jun 2012 07:59:40 -0700
Message-ID: <20120626075940.099521a7@nehalam.linuxnetplumber.net>
References: <692d04316b78401b0256598155caae190d3f27c9.1340700973.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53573 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757276Ab2FZO7t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2012 10:59:49 -0400
In-Reply-To: <692d04316b78401b0256598155caae190d3f27c9.1340700973.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Jun 2012 10:56:15 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> +void br_assign_rtnl_link_ops(struct net_device *dev)
> +{
> +	dev->rtnl_link_ops = &br_link_ops;
> +}

I am fine with the concept, but maybe it would just be simpler to
make br_link_ops public?

--- a/net/bridge/br_netlink.c	2012-06-22 08:27:50.837126940 -0700
+++ b/net/bridge/br_netlink.c	2012-06-26 07:56:33.510237340 -0700
@@ -208,7 +208,7 @@ static int br_validate(struct nlattr *tb
 	return 0;
 }
 
-static struct rtnl_link_ops br_link_ops __read_mostly = {
+struct rtnl_link_ops br_link_ops __read_mostly = {
 	.kind		= "bridge",
 	.priv_size	= sizeof(struct net_bridge),
 	.setup		= br_dev_setup,
--- a/net/bridge/br_private.h	2012-06-22 08:27:50.837126940 -0700
+++ b/net/bridge/br_private.h	2012-06-26 07:57:25.873711454 -0700
@@ -549,6 +549,7 @@ extern int (*br_fdb_test_addr_hook)(stru
 #endif
 
 /* br_netlink.c */
+extern struct rtnl_link_ops br_link_ops;
 extern int br_netlink_init(void);
 extern void br_netlink_fini(void);
 extern void br_ifinfo_notify(int event, struct net_bridge_port *port);
--- a/net/bridge/br_if.c	2012-06-26 07:59:01.996746090 -0700
+++ b/net/bridge/br_if.c	2012-06-26 07:58:55.904807272 -0700
@@ -240,6 +240,7 @@ int br_add_bridge(struct net *net, const
 		return -ENOMEM;
 
 	dev_net_set(dev, net);
+	br->rtnl_link_ops = &br_link_ops;
 
 	res = register_netdev(dev);
 	if (res)
