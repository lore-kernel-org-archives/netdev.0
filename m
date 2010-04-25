From: xiaohui.xin@intel.com
Subject: [RFC][PATCH v4 03/18] Add a ndo_mp_port_prep pointer to net_device_ops.
Date: Sun, 25 Apr 2010 17:19:50 +0800
Message-ID: <1272187206-18534-3-git-send-email-xiaohui.xin@intel.com>
References: <1272187206-18534-1-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-2-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, jdike@linux.intel.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1272187206-18534-2-git-send-email-xiaohui.xin@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

If the driver want to allocate external buffers,
then it can export it's capability, as the skb
buffer header length, the page length can be DMA, etc.
The external buffers owner may utilize this.

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---
 include/linux/netdevice.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5c473fb..3a1583b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -707,6 +707,10 @@ struct net_device_ops {
 	int			(*ndo_fcoe_get_wwn)(struct net_device *dev,
 						    u64 *wwn, int type);
 #endif
+#if defined(CONFIG_MEDIATE_PASSTHRU) || defined(CONFIG_MEDIATE_PASSTHRU_MODULE)
+	int			(*ndo_mp_port_prep)(struct net_device *dev,
+						struct mpassthru_port *port);
+#endif
 };
 
 /*
-- 
1.5.4.4

