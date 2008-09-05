From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH -mm] Fix dev_load() compilation again
Date: Fri, 5 Sep 2008 23:32:44 +0400
Message-ID: <20080905193244.GD11569@x200.localdomain>
References: <20080904224004.d3dd3076.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, h-shimamoto@ct.jp.nec.com,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.186]:18473 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbYIETbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 15:31:04 -0400
Received: by mu-out-0910.google.com with SMTP id g7so432134muf.1
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2008 12:31:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080904224004.d3dd3076.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_load() doesn't exist if MODULES=n.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/netdevice.h |    6 ++++++
 1 file changed, 6 insertions(+)

--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1639,7 +1639,13 @@ extern int		dev_set_allmulti(struct net_device *dev, int inc);
 extern void		netdev_state_change(struct net_device *dev);
 extern void		netdev_bonding_change(struct net_device *dev);
 extern void		netdev_features_change(struct net_device *dev);
+#ifdef CONFIG_MODULES
 extern void		dev_load(struct net *net, const char *name);
+#else
+static inline void dev_load(struct net *net, const char *name)
+{
+}
+#endif
 extern void		dev_mcast_init(void);
 extern int		netdev_max_backlog;
 extern int		weight_p;

