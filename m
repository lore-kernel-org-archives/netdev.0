From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 1/4] r8152: check code with checkpatch.pl
Date: Wed, 20 Aug 2014 16:58:36 +0800
Message-ID: <1394712342-15778-17-Taiwan-albertk@realtek.com>
References: <1394712342-15778-16-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-16-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 626: CHECK: Alignment should match open parenthesis
 646: CHECK: Alignment should match open parenthesis
 655: CHECK: Alignment should match open parenthesis
 695: CHECK: Alignment should match open parenthesis
 729: CHECK: Alignment should match open parenthesis
 739: CHECK: Alignment should match open parenthesis
 976: WARNING: externs should be avoided in .c files
 1314: CHECK: Alignment should match open parenthesis
 1358: WARNING: networking block comments don't use an empty /* line, use /* Comment...
 1402: WARNING: networking block comments don't use an empty /* line, use /* Comment...
 1521: CHECK: multiple assignments should be avoided
 1775: CHECK: Alignment should match open parenthesis
 1838: CHECK: multiple assignments should be avoided
 1843: CHECK: multiple assignments should be avoided
 1847: CHECK: multiple assignments should be avoided
 1850: WARNING: Missing a blank line after declarations
 1864: CHECK: Alignment should match open parenthesis
 1872: CHECK: braces {} should be used on all arms of this statement
 1906: CHECK: usleep_range is preferred over udelay
 2865: WARNING: networking block comments don't use an empty /* line, use /* Comment...
 3088: CHECK: Alignment should match open parenthesis
 total: 0 errors, 5 warnings, 16 checks, 3567 lines checked

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 66 ++++++++++++++++++++++++++-----------------------
 1 file changed, 35 insertions(+), 31 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 87f7104..2470d9c 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -623,8 +623,8 @@ int get_registers(struct r8152 *tp, u16 value, u16 index, u16 size, void *data)
 		return -ENOMEM;
 
 	ret = usb_control_msg(tp->udev, usb_rcvctrlpipe(tp->udev, 0),
-			       RTL8152_REQ_GET_REGS, RTL8152_REQT_READ,
-			       value, index, tmp, size, 500);
+			      RTL8152_REQ_GET_REGS, RTL8152_REQT_READ,
+			      value, index, tmp, size, 500);
 
 	memcpy(data, tmp, size);
 	kfree(tmp);
@@ -643,8 +643,8 @@ int set_registers(struct r8152 *tp, u16 value, u16 index, u16 size, void *data)
 		return -ENOMEM;
 
 	ret = usb_control_msg(tp->udev, usb_sndctrlpipe(tp->udev, 0),
-			       RTL8152_REQ_SET_REGS, RTL8152_REQT_WRITE,
-			       value, index, tmp, size, 500);
+			      RTL8152_REQ_SET_REGS, RTL8152_REQT_WRITE,
+			      value, index, tmp, size, 500);
 
 	kfree(tmp);
 
@@ -652,7 +652,7 @@ int set_registers(struct r8152 *tp, u16 value, u16 index, u16 size, void *data)
 }
 
 static int generic_ocp_read(struct r8152 *tp, u16 index, u16 size,
-				void *data, u16 type)
+			    void *data, u16 type)
 {
 	u16 limit = 64;
 	int ret = 0;
@@ -692,7 +692,7 @@ static int generic_ocp_read(struct r8152 *tp, u16 index, u16 size,
 }
 
 static int generic_ocp_write(struct r8152 *tp, u16 index, u16 byteen,
-				u16 size, void *data, u16 type)
+			     u16 size, void *data, u16 type)
 {
 	int ret;
 	u16 byteen_start, byteen_end, byen;
@@ -726,8 +726,8 @@ static int generic_ocp_write(struct r8152 *tp, u16 index, u16 byteen,
 		while (size) {
 			if (size > limit) {
 				ret = set_registers(tp, index,
-					type | BYTE_EN_DWORD,
-					limit, data);
+						    type | BYTE_EN_DWORD,
+						    limit, data);
 				if (ret < 0)
 					goto error1;
 
@@ -736,8 +736,8 @@ static int generic_ocp_write(struct r8152 *tp, u16 index, u16 byteen,
 				size -= limit;
 			} else {
 				ret = set_registers(tp, index,
-					type | BYTE_EN_DWORD,
-					size, data);
+						    type | BYTE_EN_DWORD,
+						    size, data);
 				if (ret < 0)
 					goto error1;
 
@@ -972,8 +972,8 @@ void write_mii_word(struct net_device *netdev, int phy_id, int reg, int val)
 	usb_autopm_put_interface(tp->intf);
 }
 
-static
-int r8152_submit_rx(struct r8152 *tp, struct rx_agg *agg, gfp_t mem_flags);
+static int
+r8152_submit_rx(struct r8152 *tp, struct rx_agg *agg, gfp_t mem_flags);
 
 static inline void set_ethernet_addr(struct r8152 *tp)
 {
@@ -1311,8 +1311,8 @@ static int alloc_all_mem(struct r8152 *tp)
 
 	tp->intr_interval = (int)ep_intr->desc.bInterval;
 	usb_fill_int_urb(tp->intr_urb, tp->udev, usb_rcvintpipe(tp->udev, 3),
-		     tp->intr_buff, INTBUFSIZE, intr_callback,
-		     tp, tp->intr_interval);
+			 tp->intr_buff, INTBUFSIZE, intr_callback,
+			 tp, tp->intr_interval);
 
 	return 0;
 
@@ -1354,8 +1354,7 @@ static inline __be16 get_protocol(struct sk_buff *skb)
 	return protocol;
 }
 
-/*
- * r8152_csum_workaround()
+/* r8152_csum_workaround()
  * The hw limites the value the transport offset. When the offset is out of the
  * range, calculate the checksum by sw.
  */
@@ -1398,8 +1397,7 @@ drop:
 	}
 }
 
-/*
- * msdn_giant_send_check()
+/* msdn_giant_send_check()
  * According to the document of microsoft, the TCP Pseudo Header excludes the
  * packet length for IPv6 TCP large packets.
  */
@@ -1518,7 +1516,8 @@ static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
 	spin_unlock(&tx_queue->lock);
 
 	tx_data = agg->head;
-	agg->skb_num = agg->skb_len = 0;
+	agg->skb_num = 0;
+	agg->skb_len = 0;
 	remain = rx_buf_sz;
 
 	while (remain >= ETH_ZLEN + sizeof(struct tx_desc)) {
@@ -1772,8 +1771,8 @@ static
 int r8152_submit_rx(struct r8152 *tp, struct rx_agg *agg, gfp_t mem_flags)
 {
 	usb_fill_bulk_urb(agg->urb, tp->udev, usb_rcvbulkpipe(tp->udev, 1),
-		      agg->head, rx_buf_sz,
-		      (usb_complete_t)read_bulk_callback, agg);
+			  agg->head, rx_buf_sz,
+			  (usb_complete_t)read_bulk_callback, agg);
 
 	return usb_submit_urb(agg->urb, mem_flags);
 }
@@ -1835,18 +1834,22 @@ static void _rtl8152_set_rx_mode(struct net_device *netdev)
 		/* Unconditionally log net taps. */
 		netif_notice(tp, link, netdev, "Promiscuous mode enabled\n");
 		ocp_data |= RCR_AM | RCR_AAP;
-		mc_filter[1] = mc_filter[0] = 0xffffffff;
+		mc_filter[1] = 0xffffffff;
+		mc_filter[0] = 0xffffffff;
 	} else if ((netdev_mc_count(netdev) > multicast_filter_limit) ||
 		   (netdev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter perfectly -- accept all multicasts. */
 		ocp_data |= RCR_AM;
-		mc_filter[1] = mc_filter[0] = 0xffffffff;
+		mc_filter[1] = 0xffffffff;
+		mc_filter[0] = 0xffffffff;
 	} else {
 		struct netdev_hw_addr *ha;
 
-		mc_filter[1] = mc_filter[0] = 0;
+		mc_filter[1] = 0;
+		mc_filter[0] = 0;
 		netdev_for_each_mc_addr(ha, netdev) {
 			int bit_nr = ether_crc(ETH_ALEN, ha->addr) >> 26;
+
 			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
 			ocp_data |= RCR_AM;
 		}
@@ -1861,7 +1864,7 @@ static void _rtl8152_set_rx_mode(struct net_device *netdev)
 }
 
 static netdev_tx_t rtl8152_start_xmit(struct sk_buff *skb,
-					struct net_device *netdev)
+				      struct net_device *netdev)
 {
 	struct r8152 *tp = netdev_priv(netdev);
 
@@ -1877,8 +1880,9 @@ static netdev_tx_t rtl8152_start_xmit(struct sk_buff *skb,
 			usb_mark_last_busy(tp->udev);
 			tasklet_schedule(&tp->tl);
 		}
-	} else if (skb_queue_len(&tp->tx_queue) > tp->tx_qlen)
+	} else if (skb_queue_len(&tp->tx_queue) > tp->tx_qlen) {
 		netif_stop_queue(netdev);
+	}
 
 	return NETDEV_TX_OK;
 }
@@ -1903,7 +1907,7 @@ static void rtl8152_nic_reset(struct r8152 *tp)
 	for (i = 0; i < 1000; i++) {
 		if (!(ocp_read_byte(tp, MCU_TYPE_PLA, PLA_CR) & CR_RST))
 			break;
-		udelay(100);
+		usleep_range(100, 400);
 	}
 }
 
@@ -2861,8 +2865,7 @@ static int rtl8152_close(struct net_device *netdev)
 	if (res < 0) {
 		rtl_drop_queued_tx(tp);
 	} else {
-		/*
-		 * The autosuspend may have been enabled and wouldn't
+		/* The autosuspend may have been enabled and wouldn't
 		 * be disable when autoresume occurs, because the
 		 * netif_running() would be false.
 		 */
@@ -3085,8 +3088,9 @@ static int rtl8152_resume(struct usb_interface *intf)
 		} else {
 			tp->rtl_ops.up(tp);
 			rtl8152_set_speed(tp, AUTONEG_ENABLE,
-				tp->mii.supports_gmii ? SPEED_1000 : SPEED_100,
-				DUPLEX_FULL);
+					  tp->mii.supports_gmii ?
+					  SPEED_1000 : SPEED_100,
+					  DUPLEX_FULL);
 		}
 		tp->speed = 0;
 		netif_carrier_off(tp->netdev);
-- 
1.9.3
