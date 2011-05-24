From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 1/2] net: add dev_ethtool_set_flags helper
Date: Tue, 24 May 2011 13:15:13 -0400
Message-ID: <1306257314-3925-2-git-send-email-nhorman@tuxdriver.com>
References: <1306257314-3925-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55843 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751229Ab1EXRP3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 13:15:29 -0400
In-Reply-To: <1306257314-3925-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a helper to check for presence of a set_flags method in an ethtool_ops
structure and conditionally call it

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: davem@davemloft.net
---
 include/linux/netdevice.h |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ca333e7..243781c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2624,6 +2624,13 @@ static inline u32 dev_ethtool_get_flags(struct net_device *dev)
 	return dev->ethtool_ops->get_flags(dev);
 }
 
+static inline int dev_ethtool_set_flags(struct net_device *dev, u32 flags)
+{
+	if (!dev->ethtool_ops || !dev->ethtool_ops->set_flags)
+		return 0;
+	return dev->ethtool_ops->set_flags(dev, flags);
+}
+
 /* Logging, debugging and troubleshooting/diagnostic helpers. */
 
 /* netdev_printk helpers, similar to dev_printk */
-- 
1.7.5.1

