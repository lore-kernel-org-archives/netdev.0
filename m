From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 05/12] net: Add ndo_fcoe_control to net_device_ops
Date: Fri, 14 Aug 2009 15:42:39 -0700
Message-ID: <20090814224239.1640.74924.stgit@localhost.localdomain>
References: <20090814223857.1640.26881.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	gospo@redhat.com, Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090814223857.1640.26881.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yi Zou <yi.zou@intel.com>

Add ndo_fcoe_control to net_device_ops so the corresponding HW can initialize
itself for FCoE traffic or clean up after FCoE traffic is done. This is
expected to be called by the kernel FCoE stack upon receiving a request for
creating an FCoE instance on the corresponding netdev interface. When
implemented by the actual HW, the HW driver check the op code to perform
corresponding initialization or clean up for FCoE. The initialization normally
includes allocating extra queues for FCoE, setting corresponding HW registers
for FCoE, indicating FCoE offload features via netdev, etc. The clean-up would
include releasing the resources allocated for FCoE.

Currently, there are two defined op codes as NETDEV_FCOE_DISABLE and _ENABLE,
for initialization and cleanup accordingly.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/netdevice.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9192cdf..84c110b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -623,6 +623,10 @@ struct net_device_ops {
 	void                    (*ndo_poll_controller)(struct net_device *dev);
 #endif
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
+#define NETDEV_FCOE_DISABLE		0x0
+#define NETDEV_FCOE_ENABLE		0x1
+	int			(*ndo_fcoe_control)(struct net_device *dev,
+	                                            u32 op);
 	int			(*ndo_fcoe_ddp_setup)(struct net_device *dev,
 						      u16 xid,
 						      struct scatterlist *sgl,

