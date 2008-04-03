From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH 0/3 net-2.6.26] Compilation fixes.
Date: Thu, 03 Apr 2008 18:13:52 +0400
Message-ID: <1207232032.19874.6.camel@iris.sw.ru>
References: <1207165579.7118.4.camel@iris.sw.ru>
	 <20080402.135609.145425148.davem@davemloft.net>
	 <1207170007.7118.6.camel@iris.sw.ru>
	 <20080402.140046.192884423.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-2Dg6Z4RP0C9ymXXgep4G"
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	containers@lists.osdl.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:31010 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755523AbYDCON4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Apr 2008 10:13:56 -0400
In-Reply-To: <20080402.140046.192884423.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-2Dg6Z4RP0C9ymXXgep4G
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Wed, 2008-04-02 at 14:00 -0700, David Miller wrote:
> From: "Denis V. Lunev" <den@openvz.org>
> Date: Thu, 03 Apr 2008 01:00:07 +0400
> 
> > On Wed, 2008-04-02 at 13:56 -0700, David Miller wrote:
> > > From: "Denis V. Lunev" <den@openvz.org>
> > > Date: Wed, 02 Apr 2008 23:46:19 +0400
> > > 
> > > Could you do such a patch set?  Thanks.
> > 
> > Sure, but, unfortunately, only tomorrow morning. It is too late today in
> > Moscow :)
> 
> No problem, there is no rush :-)

pls consider this. I have found only 3 commits related

--=-2Dg6Z4RP0C9ymXXgep4G
Content-Disposition: attachment; filename=diff-netns-compile.txt
Content-Type: text/plain; name=diff-netns-compile.txt; charset=KOI8-R
Content-Transfer-Encoding: 7bit

[NETNS]: Declare init_net even without CONFIG_NET defined.

This does not look good, but there is no other choice. The compilation
without CONFIG_NET is broken and can not be fixed with ease.

After that there is no need for the following commits:
1567ca7eec7664b8be3b07755ac59dc1b1ec76cb
3edf8fa5ccf10688a9280b5cbca8ed3947c42866
2d38f9a4f8d2ebdc799f03eecf82345825495711

Revert them.

Signed-off-by: Denis V. Lunev <den@openvz.org>
----
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c36c76c..8b17ed4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -741,7 +741,6 @@ struct net_device
 #define	NETDEV_ALIGN		32
 #define	NETDEV_ALIGN_CONST	(NETDEV_ALIGN - 1)
 
-#ifdef CONFIG_NET
 /*
  * Net namespace inlines
  */
@@ -762,7 +761,6 @@ void dev_net_set(struct net_device *dev, struct net *net)
 	dev->nd_net = net;
 #endif
 }
-#endif
 
 /**
  *	netdev_priv - access network device private data
@@ -827,7 +825,6 @@ struct packet_type {
 extern rwlock_t				dev_base_lock;		/* Device list lock */
 
 
-#ifdef CONFIG_NET
 #define for_each_netdev(net, d)		\
 		list_for_each_entry(d, &(net)->dev_base_head, dev_list)
 #define for_each_netdev_safe(net, d, n)	\
@@ -851,7 +848,6 @@ static inline struct net_device *first_net_device(struct net *net)
 	return list_empty(&net->dev_base_head) ? NULL :
 		net_device_entry(net->dev_base_head.next);
 }
-#endif
 
 extern int 			netdev_boot_setup_check(struct net_device *dev);
 extern unsigned long		netdev_boot_base(const char *prefix, int unit);
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 6c9a48a..0ab62ed 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -60,11 +60,12 @@ struct net {
 };
 
 
-#ifdef CONFIG_NET
 #include <linux/seq_file_net.h>
 
 /* Init's network namespace */
 extern struct net init_net;
+
+#ifdef CONFIG_NET
 #define INIT_NET_NS(net_ns) .net_ns = &init_net,
 
 extern struct net *copy_net_ns(unsigned long flags, struct net *net_ns);
diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
index 0d56dad..b06185e 100644
--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -19,12 +19,10 @@
 #include <linux/kobject.h>
 #include <linux/module.h>
 
-#ifdef CONFIG_NET
 #include <linux/socket.h>
 #include <linux/skbuff.h>
 #include <linux/netlink.h>
 #include <net/sock.h>
-#endif
 
 
 u64 uevent_seqnum;

--=-2Dg6Z4RP0C9ymXXgep4G--

