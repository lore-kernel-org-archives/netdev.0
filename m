From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 05/11] net: add FCoE offload support through net_device
Date: Fri, 27 Feb 2009 14:06:59 -0800
Message-ID: <20090227220659.4987.48034.stgit.yi.zou@intel.com>
References: <20090227220034.4987.50755.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: yi.zou@intel.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090227220034.4987.50755.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds support to provide Fiber Channel over Ethernet (FCoE) offload
through net_device's net_device_ops struct. The offload through net_device
for FCoE is enabled in kernel as built-in or module driver.

Signed-off-by: Yi Zou <yi.zou@intel.com>
---

 include/linux/netdevice.h |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5c40557..7ed49f5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -582,6 +582,14 @@ struct net_device_ops {
 #define HAVE_NETDEV_POLL
 	void                    (*ndo_poll_controller)(struct net_device *dev);
 #endif
+#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
+	int			(*ndo_fcoe_ddp_setup)(struct net_device *dev,
+						      u16 xid,
+						      struct scatterlist *sgl,
+						      unsigned int sgc);
+	int			(*ndo_fcoe_ddp_done)(struct net_device *dev,
+						     u16 xid);
+#endif
 };
 
 /*
@@ -843,6 +851,11 @@ struct net_device
 	struct dcbnl_rtnl_ops *dcbnl_ops;
 #endif
 
+#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
+	/* max exchange id for FCoE LRO by ddp */
+	unsigned int		fcoe_ddp_xid;
+#endif
+
 #ifdef CONFIG_COMPAT_NET_DEV_OPS
 	struct {
 		int			(*init)(struct net_device *dev);

