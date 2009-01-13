From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH 3/4] virtio_net: Add a set_rx_mode interface
Date: Tue, 13 Jan 2009 14:23:19 -0700
Message-ID: <1231881799.9095.188.camel@bling>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kvm <kvm@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Mark McLoughlin <markmc@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
---

 drivers/net/virtio_net.c   |   18 ++++++++++++++++++
 include/linux/virtio_net.h |    4 ++++
 2 files changed, 22 insertions(+), 0 deletions(-)


diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index de348de..b18dd4c 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -664,6 +664,23 @@ static int virtnet_set_tx_csum(struct net_device *dev, u32 data)
 	return ethtool_op_set_tx_hw_csum(dev, data);
 }
 
+static void virtnet_set_rx_mode(struct net_device *dev)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	u8 promisc, allmulti;
+
+	promisc = ((dev->flags & IFF_PROMISC) != 0 || dev->uc_count > 0);
+	allmulti = ((dev->flags & IFF_ALLMULTI) != 0 || dev->mc_count > 0);
+
+	virtnet_send_command(vi, VIRTIO_NET_CTRL_RX_MODE,
+			     VIRTIO_NET_CTRL_RX_MODE_PROMISC,
+			     &promisc, sizeof(promisc));
+
+	virtnet_send_command(vi, VIRTIO_NET_CTRL_RX_MODE,
+			     VIRTIO_NET_CTRL_RX_MODE_ALLMULTI,
+			     &allmulti, sizeof(allmulti));
+}
+
 static struct ethtool_ops virtnet_ethtool_ops = {
 	.set_tx_csum = virtnet_set_tx_csum,
 	.set_sg = ethtool_op_set_sg,
@@ -687,6 +704,7 @@ static const struct net_device_ops virtnet_netdev = {
 	.ndo_start_xmit      = start_xmit,
 	.ndo_validate_addr   = eth_validate_addr,
 	.ndo_set_mac_address = virtnet_set_mac_address,
+	.ndo_set_rx_mode     = virtnet_set_rx_mode,
 	.ndo_change_mtu	     = virtnet_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = virtnet_netpoll,
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 1de7c86..80cd7d3 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -56,4 +56,8 @@ struct virtio_net_hdr_mrg_rxbuf {
 #define VIRTIO_NET_OK     0
 #define VIRTIO_NET_ERR    1
 
+#define VIRTIO_NET_CTRL_RX_MODE    0
+ #define VIRTIO_NET_CTRL_RX_MODE_PROMISC      0
+ #define VIRTIO_NET_CTRL_RX_MODE_ALLMULTI     1
+
 #endif /* _LINUX_VIRTIO_NET_H */


