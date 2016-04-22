From: Yisen Zhuang <Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 03/10] net: hns: add attribute port-idx-in-ae in enet node.
Date: Fri, 22 Apr 2016 15:20:12 +0800
Message-ID: <1461309619-167621-4-git-send-email-Yisen.Zhuang@huawei.com>
References: <1461309619-167621-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <liguozhu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<xieqianqian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1461309619-167621-1-git-send-email-Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch parses port-idx-in-ae in enet node. In NIC mode of DSAF, all 6
PHYs of service DSAF are taken as ethernet ports to the CPU. The
port-idx-in-ae can be 0 to 5. Here is the diagram:
            +-----+---------------+
            |            CPU      |
            +-+-+-+---+-+-+-+-+-+-+
              |    |   | | | | | |
           debug debug   service
           port  port     port
           (0)   (0)     (0-5)

In Switch mode of DSAF, all 6 PHYs of service DSAF are taken as physical
ports connected to a LAN Switch while the CPU side assume itself have one
single NIC connected to this switch. In this case, the port-idx-in-ae will
be 0 only.
            +-----+-----+------+------+
            |                CPU      |
            +-+-+-+-+-+-+-+-+-+-+-+-+-+
              |    |     service| port(0)
            debug debug  +------------+
            port  port   |   switch   |
            (0)   (0)    +-+-+-+-+-+-++
                          | | | | | |
                         external port

when port-idx-in-ae does not exist, old attribute port-id will be used
(only for compatible purpose, not recommended to use port-id in new code).

Signed-off-by: Daode Huang <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Signed-off-by: Yisen Zhuang <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 .../devicetree/bindings/net/hisilicon-hns-nic.txt  | 30 +++++++++++++++++++-
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  | 33 ++++------------------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |  1 -
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      | 17 ++++++++---
 drivers/net/ethernet/hisilicon/hns/hns_enet.h      |  3 ++
 5 files changed, 51 insertions(+), 33 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
index e6a9d1c..b9ff4ba 100644
--- a/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
+++ b/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
@@ -36,6 +36,34 @@ Required properties:
                        | | | | | |
                       external port
 
+  This attribute is remained for compatible purpose. It is not recommended to
+  use it in new code.
+
+- port-idx-in-ae: is the index of port provided by AE.
+  In NIC mode of DSAF, all 6 PHYs of service DSAF are taken as ethernet ports
+  to the CPU. The port-idx-in-ae can be 0 to 5. Here is the diagram:
+            +-----+---------------+
+            |            CPU      |
+            +-+-+-+---+-+-+-+-+-+-+
+              |    |   | | | | | |
+           debug debug   service
+           port  port     port
+           (0)   (0)     (0-5)
+
+  In Switch mode of DSAF, all 6 PHYs of service DSAF are taken as physical
+  ports connected to a LAN Switch while the CPU side assume itself have one
+  single NIC connected to this switch. In this case, the port-idx-in-ae
+  will be 0 only.
+            +-----+-----+------+------+
+            |                CPU      |
+            +-+-+-+-+-+-+-+-+-+-+-+-+-+
+              |    |     service| port(0)
+            debug debug  +------------+
+            port  port   |   switch   |
+            (0)   (0)    +-+-+-+-+-+-++
+                          | | | | | |
+                         external port
+
 - local-mac-address: mac addr of the ethernet interface
 
 Example:
@@ -43,6 +71,6 @@ Example:
 	ethernet@0{
 		compatible = "hisilicon,hns-nic-v1";
 		ae-handle = <&dsaf0>;
-		port-id = <0>;
+		port-idx-in-ae = <0>;
 		local-mac-address = [a2 14 e4 4b 56 76];
 	};
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index 1e8bf22..1c86336 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -29,25 +29,6 @@ static struct hns_mac_cb *hns_get_mac_cb(struct hnae_handle *handle)
 	return vf_cb->mac_cb;
 }
 
-/**
- * hns_ae_map_eport_to_dport - translate enet port id to dsaf port id
- * @port_id: enet port id
- *: debug port 0-1, service port 2 -7 (dsaf mode only 2)
- * return: dsaf port id
- *: service ports 0 - 5, debug port 6-7
- **/
-static int hns_ae_map_eport_to_dport(u32 port_id)
-{
-	int port_index;
-
-	if (port_id < DSAF_DEBUG_NW_NUM)
-		port_index = port_id + DSAF_SERVICE_PORT_NUM_PER_DSAF;
-	else
-		port_index = port_id - DSAF_DEBUG_NW_NUM;
-
-	return port_index;
-}
-
 static struct dsaf_device *hns_ae_get_dsaf_dev(struct hnae_ae_dev *dev)
 {
 	return container_of(dev, struct dsaf_device, ae_dev);
@@ -110,7 +91,6 @@ static struct ring_pair_cb *hns_ae_get_ring_pair(struct hnae_queue *q)
 struct hnae_handle *hns_ae_get_handle(struct hnae_ae_dev *dev,
 				      u32 port_id)
 {
-	int port_idx;
 	int vfnum_per_port;
 	int qnum_per_vf;
 	int i;
@@ -120,11 +100,10 @@ struct hnae_handle *hns_ae_get_handle(struct hnae_ae_dev *dev,
 	struct hnae_vf_cb *vf_cb;
 
 	dsaf_dev = hns_ae_get_dsaf_dev(dev);
-	port_idx = hns_ae_map_eport_to_dport(port_id);
 
-	ring_pair_cb = hns_ae_get_base_ring_pair(dsaf_dev, port_idx);
-	vfnum_per_port = hns_ae_get_vf_num_per_port(dsaf_dev, port_idx);
-	qnum_per_vf = hns_ae_get_q_num_per_vf(dsaf_dev, port_idx);
+	ring_pair_cb = hns_ae_get_base_ring_pair(dsaf_dev, port_id);
+	vfnum_per_port = hns_ae_get_vf_num_per_port(dsaf_dev, port_id);
+	qnum_per_vf = hns_ae_get_q_num_per_vf(dsaf_dev, port_id);
 
 	vf_cb = kzalloc(sizeof(*vf_cb) +
 			qnum_per_vf * sizeof(struct hnae_queue *), GFP_KERNEL);
@@ -163,14 +142,14 @@ struct hnae_handle *hns_ae_get_handle(struct hnae_ae_dev *dev,
 	}
 
 	vf_cb->dsaf_dev = dsaf_dev;
-	vf_cb->port_index = port_idx;
-	vf_cb->mac_cb = &dsaf_dev->mac_cb[port_idx];
+	vf_cb->port_index = port_id;
+	vf_cb->mac_cb = &dsaf_dev->mac_cb[port_id];
 
 	ae_handle->phy_if = vf_cb->mac_cb->phy_if;
 	ae_handle->phy_node = vf_cb->mac_cb->phy_node;
 	ae_handle->if_support = vf_cb->mac_cb->if_support;
 	ae_handle->port_type = vf_cb->mac_cb->mac_type;
-	ae_handle->dport_id = port_idx;
+	ae_handle->dport_id = port_id;
 
 	return ae_handle;
 vf_id_err:
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index 8782608..ed0043a 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -24,7 +24,6 @@
 #define DSAF_SERVICE_NW_NUM	6
 #define DSAF_COMM_CHN		DSAF_SERVICE_NW_NUM
 #define DSAF_GE_NUM		((DSAF_SERVICE_NW_NUM) + (DSAF_DEBUG_NW_NUM))
-#define DSAF_PORT_NUM		((DSAF_SERVICE_NW_NUM) + (DSAF_DEBUG_NW_NUM))
 #define DSAF_XGE_NUM		DSAF_SERVICE_NW_NUM
 #define DSAF_PORT_TYPE_NUM 3
 #define DSAF_NODE_NUM		18
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 687204b..e47aff2 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -1873,6 +1873,7 @@ static int hns_nic_dev_probe(struct platform_device *pdev)
 	struct net_device *ndev;
 	struct hns_nic_priv *priv;
 	struct device_node *node = dev->of_node;
+	u32 port_id;
 	int ret;
 
 	ndev = alloc_etherdev_mq(sizeof(struct hns_nic_priv), NIC_MAX_Q_PER_VF);
@@ -1896,10 +1897,18 @@ static int hns_nic_dev_probe(struct platform_device *pdev)
 		dev_err(dev, "not find ae-handle\n");
 		goto out_read_prop_fail;
 	}
-
-	ret = of_property_read_u32(node, "port-id", &priv->port_id);
-	if (ret)
-		goto out_read_prop_fail;
+	/* try to find port-idx-in-ae first */
+	ret = of_property_read_u32(node, "port-idx-in-ae", &port_id);
+	if (ret) {
+		/* only for old code compatible */
+		ret = of_property_read_u32(node, "port-id", &port_id);
+		if (ret)
+			goto out_read_prop_fail;
+		/* for old dts, we need to caculate the port offset */
+		port_id = port_id < HNS_SRV_OFFSET ? port_id + HNS_DEBUG_OFFSET
+			: port_id - HNS_SRV_OFFSET;
+	}
+	priv->port_id = port_id;
 
 	hns_init_mac_addr(ndev);
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.h b/drivers/net/ethernet/hisilicon/hns/hns_enet.h
index c68ab3d..337efa5 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.h
@@ -18,6 +18,9 @@
 
 #include "hnae.h"
 
+#define HNS_DEBUG_OFFSET	6
+#define HNS_SRV_OFFSET		2
+
 enum hns_nic_state {
 	NIC_STATE_TESTING = 0,
 	NIC_STATE_RESETTING,
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
