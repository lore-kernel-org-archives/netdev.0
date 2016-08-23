From: sthemmin@exchange.microsoft.com
Subject: [PATCH 04/14] hv_netvsc: style cleanups
Date: Tue, 23 Aug 2016 12:17:47 -0700
Message-ID: <1471979877-17802-4-git-send-email-sthemmin@exchange.microsoft.com>
References: <1471979877-17802-1-git-send-email-sthemmin@exchange.microsoft.com>
Reply-To: sthemmin@microsoft.com
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: "K. Y. Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded04.prod.phx3.secureserver.net ([208.109.80.198]:38276
        "EHLO p3plsmtps2ded04.prod.phx3.secureserver.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752857AbcHWSH6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 14:07:58 -0400
In-Reply-To: <1471979877-17802-1-git-send-email-sthemmin@exchange.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <sthemmin@microsoft.com>

Fix most of the complaints about the style of the code.
Things like extra blank lines and return statements.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c       | 18 ++----------------
 drivers/net/hyperv/netvsc_drv.c   |  7 -------
 drivers/net/hyperv/rndis_filter.c |  8 +-------
 3 files changed, 3 insertions(+), 30 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index f64c978..fe83de3 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -59,7 +59,6 @@ void netvsc_switch_datapath(struct net_device *ndev, bool vf)
 			       VM_PKT_DATA_INBAND, 0);
 }
 
-
 static struct netvsc_device *alloc_net_device(void)
 {
 	struct netvsc_device *net_device;
@@ -123,7 +122,6 @@ get_in_err:
 	return net_device;
 }
 
-
 static int netvsc_destroy_buf(struct hv_device *device)
 {
 	struct nvsp_message *revoke_packet;
@@ -285,7 +283,6 @@ static int netvsc_init_buf(struct hv_device *device)
 		goto cleanup;
 	}
 
-
 	/* Notify the NetVsp of the gpadl handle */
 	init_packet = &net_device->channel_init_pkt;
 
@@ -412,7 +409,7 @@ static int netvsc_init_buf(struct hv_device *device)
 	/* Section count is simply the size divided by the section size.
 	 */
 	net_device->send_section_cnt =
-		net_device->send_buf_size/net_device->send_section_size;
+		net_device->send_buf_size / net_device->send_section_size;
 
 	dev_info(&device->device, "Send section size: %d, Section count:%d\n",
 		 net_device->send_section_size, net_device->send_section_cnt);
@@ -437,7 +434,6 @@ exit:
 	return ret;
 }
 
-
 /* Negotiate NVSP protocol version */
 static int negotiate_nvsp_ver(struct hv_device *device,
 			      struct netvsc_device *net_device,
@@ -593,7 +589,6 @@ int netvsc_device_remove(struct hv_device *device)
 	return 0;
 }
 
-
 #define RING_AVAIL_PERCENT_HIWATER 20
 #define RING_AVAIL_PERCENT_LOWATER 10
 
@@ -676,13 +671,11 @@ static void netvsc_send_completion(struct netvsc_device *net_device,
 		    !net_device_ctx->start_remove &&
 		    (hv_ringbuf_avail_percent(&channel->outbound) >
 		     RING_AVAIL_PERCENT_HIWATER || queue_sends < 1))
-				netif_tx_wake_queue(netdev_get_tx_queue(
-						    ndev, q_idx));
+			netif_tx_wake_queue(netdev_get_tx_queue(ndev, q_idx));
 	} else {
 		netdev_err(ndev, "Unknown send completion packet type- "
 			   "%d received!!\n", nvsp_packet->hdr.msg_type);
 	}
-
 }
 
 static u32 netvsc_get_next_send_section(struct netvsc_device *net_device)
@@ -1157,7 +1150,6 @@ static void netvsc_receive(struct netvsc_device *net_device,
 		/* Pass it to the upper layer */
 		status = rndis_filter_receive(device, netvsc_packet, &data,
 					      channel);
-
 	}
 
 	if (!net_device->mrc[q_idx].buf) {
@@ -1182,7 +1174,6 @@ static void netvsc_receive(struct netvsc_device *net_device,
 	rcd->status = status;
 }
 
-
 static void netvsc_send_table(struct hv_device *hdev,
 			      struct nvsp_message *nvmsg)
 {
@@ -1263,7 +1254,6 @@ static void netvsc_process_raw_pkt(struct hv_device *device,
 	}
 }
 
-
 void netvsc_channel_cb(void *context)
 {
 	int ret;
@@ -1320,8 +1310,6 @@ void netvsc_channel_cb(void *context)
 						       ndev,
 						       request_id,
 						       desc);
-
-
 			} else {
 				/*
 				 * We are done for this pass.
@@ -1350,8 +1338,6 @@ void netvsc_channel_cb(void *context)
 		kfree(buffer);
 
 	netvsc_chk_recv_comp(net_device, channel, q_idx);
-
-	return;
 }
 
 /*
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 6924d01a..3bbf073 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -40,7 +40,6 @@
 
 #include "hyperv_net.h"
 
-
 #define RING_SIZE_MIN 64
 #define LINKCHANGE_INT (2 * HZ)
 #define NETVSC_HW_FEATURES	(NETIF_F_RXCSUM | \
@@ -411,7 +410,6 @@ check_size:
 			FIELD_SIZEOF(struct sk_buff, cb));
 	packet = (struct hv_netvsc_packet *)skb->cb;
 
-
 	packet->q_idx = skb_get_queue_mapping(skb);
 
 	packet->total_data_buflen = skb->len;
@@ -617,7 +615,6 @@ void netvsc_linkstatus_callback(struct hv_device *device_obj,
 	schedule_delayed_work(&ndev_ctx->dwork, 0);
 }
 
-
 static struct sk_buff *netvsc_alloc_recv_skb(struct net_device *net,
 				struct hv_netvsc_packet *packet,
 				struct ndis_tcp_ip_checksum_info *csum_info,
@@ -1271,7 +1268,6 @@ static int netvsc_vf_up(struct net_device *vf_netdev)
 	return NOTIFY_OK;
 }
 
-
 static int netvsc_vf_down(struct net_device *vf_netdev)
 {
 	struct net_device *ndev;
@@ -1305,7 +1301,6 @@ static int netvsc_vf_down(struct net_device *vf_netdev)
 	return NOTIFY_OK;
 }
 
-
 static int netvsc_unregister_vf(struct net_device *vf_netdev)
 {
 	struct net_device *ndev;
@@ -1433,7 +1428,6 @@ static int netvsc_remove(struct hv_device *dev)
 		return 0;
 	}
 
-
 	ndev_ctx = netdev_priv(net);
 	net_device = ndev_ctx->nvdev;
 
@@ -1480,7 +1474,6 @@ static struct  hv_driver netvsc_drv = {
 	.remove = netvsc_remove,
 };
 
-
 /*
  * On Hyper-V, every VF interface is matched with a corresponding
  * synthetic interface. The synthetic interface is presented first
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index a100380..9195d5d 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -721,7 +721,6 @@ static int rndis_filter_set_rss_param(struct rndis_device *rdev, int num_queue)
 	for (i = 0; i < HASH_KEYLEN; i++)
 		keyp[i] = netvsc_hash_key[i];
 
-
 	ret = rndis_filter_send_request(rdev, request);
 	if (ret != 0)
 		goto cleanup;
@@ -739,7 +738,6 @@ cleanup:
 	return ret;
 }
 
-
 static int rndis_filter_query_device_link_status(struct rndis_device *dev)
 {
 	u32 size = sizeof(u32);
@@ -815,7 +813,6 @@ cleanup:
 	return ret;
 }
 
-
 static int rndis_filter_init_device(struct rndis_device *dev)
 {
 	struct rndis_request *request;
@@ -903,7 +900,6 @@ cleanup:
 
 	if (request)
 		put_rndis_request(dev, request);
-	return;
 }
 
 static int rndis_filter_open_device(struct rndis_device *dev)
@@ -973,7 +969,7 @@ static void netvsc_sc_open(struct vmbus_channel *new_sc)
 }
 
 int rndis_filter_device_add(struct hv_device *dev,
-				  void *additional_info)
+			    void *additional_info)
 {
 	int ret;
 	struct net_device *net = hv_get_drvdata(dev);
@@ -1055,7 +1051,6 @@ int rndis_filter_device_add(struct hv_device *dev,
 	offloads.udp_ip_v6_csum = NDIS_OFFLOAD_PARAMETERS_TX_RX_ENABLED;
 	offloads.lso_v2_ipv4 = NDIS_OFFLOAD_PARAMETERS_LSOV2_ENABLED;
 
-
 	ret = rndis_filter_set_offload_params(net, &offloads);
 	if (ret)
 		goto err_dev_remv;
@@ -1181,7 +1176,6 @@ void rndis_filter_device_remove(struct hv_device *dev)
 	netvsc_device_remove(dev);
 }
 
-
 int rndis_filter_open(struct netvsc_device *nvdev)
 {
 	if (!nvdev)
-- 
2.9.3
