From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6 1/4] net: introduce mc list helpers
Date: Thu, 22 Oct 2009 15:52:21 +0200
Message-ID: <20091022135220.GD2868@psychotron.lab.eng.brq.redhat.com>
References: <20091022135120.GC2868@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com, e1000-devel@lists.sourceforge.net,
	mchehab@infradead.org, linux-media@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23986 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755413AbZJVNwf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2009 09:52:35 -0400
Content-Disposition: inline
In-Reply-To: <20091022135120.GC2868@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This helpers should be used by network drivers to access to netdev
multicast lists.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/netdevice.h |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8380009..7edc4a6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -921,6 +921,28 @@ struct net_device
 
 #define	NETDEV_ALIGN		32
 
+static inline int netdev_mc_count(struct net_device *dev)
+{
+	return dev->mc_count;
+}
+
+static inline bool netdev_mc_empty(struct net_device *dev)
+{
+	return netdev_mc_count(dev) == 0;
+}
+
+static inline void netdev_mc_walk(struct net_device *dev,
+				  void (*func)(void *, unsigned char *),
+				  void *data)
+{
+	struct dev_addr_list *mclist;
+	int i;
+
+	for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+	     i++, mclist = mclist->next)
+		func(data, mclist->dmi_addr);
+}
+
 static inline
 struct netdev_queue *netdev_get_tx_queue(const struct net_device *dev,
 					 unsigned int index)
-- 
1.6.2.5

