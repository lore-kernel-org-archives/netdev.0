From: xiaohui.xin@intel.com
Subject: [PATCH v12 03/17] Add a ndo_mp_port_prep pointer to net_device_ops.
Date: Thu, 30 Sep 2010 22:04:20 +0800
Message-ID: <71d822c4ef96c404f21fce724549c0ba9f71bd36.1285853725.git.xiaohui.xin@intel.com>
References: <1285855474-12110-1-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1285855474-12110-1-git-send-email-xiaohui.xin@intel.com>
In-Reply-To: <59d8a50047ee01e26658fd676d26c0162b79e5fd.1285853725.git.xiaohui.xin@intel.com>
References: <59d8a50047ee01e26658fd676d26c0162b79e5fd.1285853725.git.xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

If the driver want to allocate external buffers,
then it can export it's capability, as the skb
buffer header length, the page length can be DMA, etc.
The external buffers owner may utilize this.

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---
 include/linux/netdevice.h |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9ef9bf1..24a31e7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -651,6 +651,12 @@ struct mp_port	{
  * int (*ndo_set_vf_tx_rate)(struct net_device *dev, int vf, int rate);
  * int (*ndo_get_vf_config)(struct net_device *dev,
  *			    int vf, struct ifla_vf_info *ivf);
+ *
+ * int (*ndo_mp_port_prep)(struct net_device *dev, struct mp_port *port);
+ *	If the driver want to allocate external buffers,
+ *	then it can export it's capability, as the skb
+ *	buffer header length, the page length can be DMA, etc.
+ *	The external buffers owner may utilize this.
  */
 #define HAVE_NET_DEVICE_OPS
 struct net_device_ops {
@@ -713,6 +719,10 @@ struct net_device_ops {
 	int			(*ndo_fcoe_get_wwn)(struct net_device *dev,
 						    u64 *wwn, int type);
 #endif
+#if defined(CONFIG_MEDIATE_PASSTHRU) || defined(CONFIG_MEDIATE_PASSTHRU_MODULE)
+	int			(*ndo_mp_port_prep)(struct net_device *dev,
+						struct mp_port *port);
+#endif
 };
 
 /*
-- 
1.7.3
