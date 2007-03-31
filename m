From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: [PATCH] [SK_BUFF]: Introduce skb_copy_to_linear_data{_offset}
Date: Sat, 31 Mar 2007 12:14:12 -0300
Message-ID: <20070331151411.GC29188@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.225]:17621 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753156AbXCaPOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Mar 2007 11:14:18 -0400
Received: by wx-out-0506.google.com with SMTP id h31so864822wxd
        for <netdev@vger.kernel.org>; Sat, 31 Mar 2007 08:14:18 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To clearly state the intent of copying to linear sk_buffs, _offset being a
overly long variant but interesting for the sake of saving some bytes.

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 arch/ia64/hp/sim/simeth.c                 |    2 +-
 arch/ia64/sn/kernel/xpnet.c               |    2 +-
 drivers/isdn/hysdn/hycapi.c               |    3 +-
 drivers/net/8139too.c                     |    6 ++--
 drivers/net/appletalk/ltpc.c              |    2 +-
 drivers/net/atari_bionet.c                |    3 +-
 drivers/net/atari_pamsnet.c               |    3 +-
 drivers/net/chelsio/sge.c                 |   24 ++++++++++-----
 drivers/net/cxgb3/sge.c                   |    6 ++--
 drivers/net/defxx.c                       |    4 ++-
 drivers/net/e100.c                        |    2 +-
 drivers/net/e1000/e1000_main.c            |    9 ++++--
 drivers/net/ehea/ehea_main.c              |    4 +-
 drivers/net/irda/ali-ircc.c               |    2 +-
 drivers/net/irda/au1k_ir.c                |    2 +-
 drivers/net/irda/donauboe.c               |    4 +-
 drivers/net/irda/mcs7780.c                |    4 +-
 drivers/net/irda/nsc-ircc.c               |    8 ++++-
 drivers/net/irda/pxaficp_ir.c             |    2 +-
 drivers/net/irda/stir4200.c               |    2 +-
 drivers/net/irda/via-ircc.c               |    6 ++--
 drivers/net/irda/w83977af_ir.c            |    8 ++++-
 drivers/net/ixgb/ixgb_main.c              |    9 ++++--
 drivers/net/loopback.c                    |    3 +-
 drivers/net/macb.c                        |    7 ++--
 drivers/net/myri10ge/myri10ge.c           |    2 +-
 drivers/net/sk98lin/skge.c                |    2 +-
 drivers/net/skfp/skfddi.c                 |    2 +-
 drivers/net/sun3lance.c                   |    2 +-
 drivers/net/tokenring/smctr.c             |    4 +-
 drivers/net/tokenring/tms380tr.c          |    3 +-
 drivers/net/wan/dscc4.c                   |    3 +-
 drivers/net/wan/pc300_drv.c               |    2 +-
 drivers/net/wan/pc300_tty.c               |    4 +-
 drivers/net/wan/z85230.c                  |    2 +-
 drivers/net/wireless/prism54/islpci_eth.c |    4 +-
 drivers/s390/net/qeth_main.c              |    9 +++--
 drivers/usb/atm/usbatm.c                  |    4 ++-
 drivers/usb/net/asix.c                    |    2 +-
 include/linux/skbuff.h                    |   15 +++++++++
 net/atm/br2684.c                          |    2 +-
 net/atm/lec.c                             |    8 ++--
 net/atm/mpc.c                             |   11 ++++--
 net/bridge/br_netfilter.c                 |    3 +-
 net/core/netpoll.c                        |    2 +-
 net/core/skbuff.c                         |    2 +-
 net/ieee80211/ieee80211_rx.c              |    5 ++-
 net/ipv4/ipcomp.c                         |    2 +-
 net/ipv4/ipmr.c                           |    2 +-
 net/ipv4/ipvs/ip_vs_app.c                 |    2 +-
 net/ipv4/netfilter/ip_queue.c             |    2 +-
 net/ipv6/ipcomp6.c                        |    2 +-
 net/ipv6/netfilter/ip6_queue.c            |    2 +-
 net/irda/irttp.c                          |    2 +-
 net/irda/wrapper.c                        |    3 +-
 net/netfilter/nfnetlink_queue.c           |    2 +-
 net/netrom/nr_out.c                       |    4 +-
 net/rose/af_rose.c                        |    2 +-
 net/tipc/link.c                           |   46 +++++++++++++++--------------
 net/tipc/msg.h                            |    7 ++--
 net/tipc/port.c                           |    8 ++--
 net/wanrouter/wanmain.c                   |    4 +-
 net/x25/x25_out.c                         |    2 +-
 63 files changed, 185 insertions(+), 127 deletions(-)

diff --git a/arch/ia64/hp/sim/simeth.c b/arch/ia64/hp/sim/simeth.c
index edef008..f26077a 100644
--- a/arch/ia64/hp/sim/simeth.c
+++ b/arch/ia64/hp/sim/simeth.c
@@ -473,7 +473,7 @@ simeth_rx(struct net_device *dev)
 		 * XXX Fix me
 		 * Should really do a csum+copy here
 		 */
-		memcpy(skb->data, frame, len);
+		skb_copy_to_linear_data(skb, frame, len);
 #endif
 		skb->protocol = eth_type_trans(skb, dev);
 
diff --git a/arch/ia64/sn/kernel/xpnet.c b/arch/ia64/sn/kernel/xpnet.c
index 9fc0265..5419acb 100644
--- a/arch/ia64/sn/kernel/xpnet.c
+++ b/arch/ia64/sn/kernel/xpnet.c
@@ -233,7 +233,7 @@ xpnet_receive(partid_t partid, int channel, struct xpnet_message *msg)
 			"%lu)\n", skb->data, &msg->data,
 			(size_t) msg->embedded_bytes);
 
-		memcpy(skb->data, &msg->data, (size_t) msg->embedded_bytes);
+		skb_copy_to_linear_data(skb, &msg->data, (size_t)msg->embedded_bytes);
 	} else {
 		dev_dbg(xpnet, "transferring buffer to the skb->data area;\n\t"
 			"bte_copy(0x%p, 0x%p, %hu)\n", (void *)msg->buf_pa,
diff --git a/drivers/isdn/hysdn/hycapi.c b/drivers/isdn/hysdn/hycapi.c
index 4433ce0..f854501 100644
--- a/drivers/isdn/hysdn/hycapi.c
+++ b/drivers/isdn/hysdn/hycapi.c
@@ -399,7 +399,8 @@ static u16 hycapi_send_message(struct capi_ctr *ctrl, struct sk_buff *skb)
 			if (_len > 22) {
 				_len2 = _len - 22;
 				skb_copy_from_linear_data(skb, msghead, 22);
-				memcpy(skb->data + _len2, msghead, 22);
+				skb_copy_to_linear_data_offset(skb, _len2,
+							       msghead, 22);
 				skb_pull(skb, _len2);
 				CAPIMSG_SETLEN(skb->data, 22);
 				retval = capilib_data_b3_req(&cinfo->ncci_head,
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 2101334..a844b1f 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -1904,10 +1904,10 @@ static __inline__ void wrap_copy(struct sk_buff *skb, const unsigned char *ring,
 	u32 left = RX_BUF_LEN - offset;
 
 	if (size > left) {
-		memcpy(skb->data, ring + offset, left);
-		memcpy(skb->data+left, ring, size - left);
+		skb_copy_to_linear_data(skb, ring + offset, left);
+		skb_copy_to_linear_data_offset(skb, left, ring, size - left);
 	} else
-		memcpy(skb->data, ring + offset, size);
+		skb_copy_to_linear_data(skb, ring + offset, size);
 }
 #endif
 
diff --git a/drivers/net/appletalk/ltpc.c b/drivers/net/appletalk/ltpc.c
index 43c17c8..6a6cbd3 100644
--- a/drivers/net/appletalk/ltpc.c
+++ b/drivers/net/appletalk/ltpc.c
@@ -774,7 +774,7 @@ static int sendup_buffer (struct net_device *dev)
 	skb_pull(skb,3);
 
 	/* copy ddp(s,e)hdr + contents */
-	memcpy(skb->data,(void*)ltdmabuf,len);
+	skb_copy_to_linear_data(skb, ltdmabuf, len);
 
 	skb_reset_transport_header(skb);
 
diff --git a/drivers/net/atari_bionet.c b/drivers/net/atari_bionet.c
index 13dbed3..3d87bd2 100644
--- a/drivers/net/atari_bionet.c
+++ b/drivers/net/atari_bionet.c
@@ -550,7 +550,8 @@ bionet_poll_rx(struct net_device *dev) {
 
 			/* 'skb->data' points to the start of sk_buff data area.
 			 */
-			memcpy(skb->data, nic_packet->buffer, pkt_len);
+			skb_copy_to_linear_data(skb, nic_packet->buffer,
+						pkt_len);
 			skb->protocol = eth_type_trans( skb, dev );
 			netif_rx(skb);
 			dev->last_rx = jiffies;
diff --git a/drivers/net/atari_pamsnet.c b/drivers/net/atari_pamsnet.c
index 745101d..5471440 100644
--- a/drivers/net/atari_pamsnet.c
+++ b/drivers/net/atari_pamsnet.c
@@ -793,7 +793,8 @@ pamsnet_poll_rx(struct net_device *dev) {
 
 			/* 'skb->data' points to the start of sk_buff data area.
 			 */
-			memcpy(skb->data, nic_packet->buffer, pkt_len);
+			skb_copy_to_linear_data(skb, nic_packet->buffer,
+						pkt_len);
 			netif_rx(skb);
 			dev->last_rx = jiffies;
 			lp->stats.rx_packets++;
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index 1be1bbd..e4f874a 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -2095,10 +2095,14 @@ static void espibug_workaround_t204(unsigned long data)
 					0x0, 0x7, 0x43, 0x0, 0x0, 0x0
 				};
 
-				memcpy(skb->data + sizeof(struct cpl_tx_pkt),
-					ch_mac_addr, ETH_ALEN);
-				memcpy(skb->data + skb->len - 10,
-					ch_mac_addr, ETH_ALEN);
+				skb_copy_to_linear_data_offset(skb,
+						    sizeof(struct cpl_tx_pkt),
+							       ch_mac_addr,
+							       ETH_ALEN);
+				skb_copy_to_linear_data_offset(skb,
+							       skb->len - 10,
+							       ch_mac_addr,
+							       ETH_ALEN);
 				skb->cb[0] = 0xff;
 			}
 
@@ -2125,10 +2129,14 @@ static void espibug_workaround(unsigned long data)
 	                if (!skb->cb[0]) {
 	                        u8 ch_mac_addr[ETH_ALEN] =
 	                            {0x0, 0x7, 0x43, 0x0, 0x0, 0x0};
-	                        memcpy(skb->data + sizeof(struct cpl_tx_pkt),
-	                               ch_mac_addr, ETH_ALEN);
-	                        memcpy(skb->data + skb->len - 10, ch_mac_addr,
-	                               ETH_ALEN);
+	                        skb_copy_to_linear_data_offset(skb,
+						     sizeof(struct cpl_tx_pkt),
+							       ch_mac_addr,
+							       ETH_ALEN);
+	                        skb_copy_to_linear_data_offset(skb,
+							       skb->len - 10,
+							       ch_mac_addr,
+							       ETH_ALEN);
 	                        skb->cb[0] = 0xff;
 	                }
 
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 054631a..f884062 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -661,7 +661,7 @@ static inline struct sk_buff *get_imm_packet(const struct rsp_desc *resp)
 
 	if (skb) {
 		__skb_put(skb, IMMED_PKT_SIZE);
-		memcpy(skb->data, resp->imm_data, IMMED_PKT_SIZE);
+		skb_copy_to_linear_data(skb, resp->imm_data, IMMED_PKT_SIZE);
 	}
 	return skb;
 }
@@ -1722,11 +1722,11 @@ static void skb_data_init(struct sk_buff *skb, struct sge_fl_page *p,
 {
 	skb->len = len;
 	if (len <= SKB_DATA_SIZE) {
-		memcpy(skb->data, p->va, len);
+		skb_copy_to_linear_data(skb, p->va, len);
 		skb->tail += len;
 		put_page(p->frag.page);
 	} else {
-		memcpy(skb->data, p->va, SKB_DATA_SIZE);
+		skb_copy_to_linear_data(skb, p->va, SKB_DATA_SIZE);
 		skb_shinfo(skb)->frags[0].page = p->frag.page;
 		skb_shinfo(skb)->frags[0].page_offset =
 		    p->frag.page_offset + SKB_DATA_SIZE;
diff --git a/drivers/net/defxx.c b/drivers/net/defxx.c
index 8d29fae..571d82f 100644
--- a/drivers/net/defxx.c
+++ b/drivers/net/defxx.c
@@ -3091,7 +3091,9 @@ static void dfx_rcv_queue_process(
 					{
 						/* Receive buffer allocated, pass receive packet up */
 
-						memcpy(skb->data, p_buff + RCV_BUFF_K_PADDING, pkt_len+3);
+						skb_copy_to_linear_data(skb,
+							       p_buff + RCV_BUFF_K_PADDING,
+							       pkt_len + 3);
 					}
 
 					skb_reserve(skb,3);		/* adjust data field so that it points to FC byte */
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 0cefef5..4d0e0ae 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1769,7 +1769,7 @@ static int e100_rx_alloc_skb(struct nic *nic, struct rx *rx)
 
 	/* Align, init, and map the RFD. */
 	skb_reserve(rx->skb, NET_IP_ALIGN);
-	memcpy(rx->skb->data, &nic->blank_rfd, sizeof(struct rfd));
+	skb_copy_to_linear_data(rx->skb, &nic->blank_rfd, sizeof(struct rfd));
 	rx->dma_addr = pci_map_single(nic->pdev, rx->skb->data,
 		RFD_BUF_LEN, PCI_DMA_BIDIRECTIONAL);
 
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 913db0c..7f2b0d8 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -4227,9 +4227,12 @@ e1000_clean_rx_irq(struct e1000_adapter *adapter,
 			    netdev_alloc_skb(netdev, length + NET_IP_ALIGN);
 			if (new_skb) {
 				skb_reserve(new_skb, NET_IP_ALIGN);
-				memcpy(new_skb->data - NET_IP_ALIGN,
-				       skb->data - NET_IP_ALIGN,
-				       length + NET_IP_ALIGN);
+				skb_copy_to_linear_data_offset(new_skb,
+							       -NET_IP_ALIGN,
+							       (skb->data -
+							        NET_IP_ALIGN),
+							       (length +
+							        NET_IP_ALIGN));
 				/* save the skb in buffer_info as good */
 				buffer_info->skb = skb;
 				skb = new_skb;
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 8b53920..58364a0 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -391,8 +391,8 @@ static int ehea_poll(struct net_device *dev, int *budget)
 					if (!skb)
 						break;
 				}
-				memcpy(skb->data, ((char*)cqe) + 64,
-				       cqe->num_bytes_transfered - 4);
+				skb_copy_to_linear_data(skb, ((char*)cqe) + 64,
+					       cqe->num_bytes_transfered - 4);
 				ehea_fill_skb(dev, skb, cqe);
 			} else if (rq == 2) {  /* RQ2 */
 				skb = get_skb_by_index(skb_arr_rq2,
diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index fb2248a..f9c889c 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -1923,7 +1923,7 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
 			
 			/* Copy frame without CRC, CRC is removed by hardware*/
 			skb_put(skb, len);
-			memcpy(skb->data, self->rx_buff.data, len);
+			skb_copy_to_linear_data(skb, self->rx_buff.data, len);
 
 			/* Move to next frame */
 			self->rx_buff.data += len;
diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index cdd1f6c..4dbdfaa 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -604,7 +604,7 @@ static int au1k_irda_rx(struct net_device *dev)
 				skb_put(skb, count);
 			else
 				skb_put(skb, count-2);
-			memcpy(skb->data, (void *)pDB->vaddr, count-2);
+			skb_copy_to_linear_data(skb, pDB->vaddr, count - 2);
 			skb->dev = dev;
 			skb_reset_mac_header(skb);
 			skb->protocol = htons(ETH_P_IRDA);
diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index 9987a0d..8268997 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -1282,8 +1282,8 @@ dumpbufs(self->rx_bufs[self->rxs],len,'<');
                       skb_reserve (skb, 1);
 
                       skb_put (skb, len);
-                      memcpy (skb->data, self->rx_bufs[self->rxs], len);
-
+                      skb_copy_to_linear_data(skb, self->rx_bufs[self->rxs],
+		      			      len);
                       self->stats.rx_packets++;
                       skb->dev = self->netdev;
                       skb_reset_mac_header(skb);
diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
index 4b0037e..54d1d54 100644
--- a/drivers/net/irda/mcs7780.c
+++ b/drivers/net/irda/mcs7780.c
@@ -426,7 +426,7 @@ static void mcs_unwrap_mir(struct mcs_cb *mcs, __u8 *buf, int len)
 	}
 
 	skb_reserve(skb, 1);
-	memcpy(skb->data, buf, new_len);
+	skb_copy_to_linear_data(skb, buf, new_len);
 	skb_put(skb, new_len);
 	skb_reset_mac_header(skb);
 	skb->protocol = htons(ETH_P_IRDA);
@@ -479,7 +479,7 @@ static void mcs_unwrap_fir(struct mcs_cb *mcs, __u8 *buf, int len)
 	}
 
 	skb_reserve(skb, 1);
-	memcpy(skb->data, buf, new_len);
+	skb_copy_to_linear_data(skb, buf, new_len);
 	skb_put(skb, new_len);
 	skb_reset_mac_header(skb);
 	skb->protocol = htons(ETH_P_IRDA);
diff --git a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
index 0ff9927..d96c897 100644
--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -1868,10 +1868,14 @@ static int nsc_ircc_dma_receive_complete(struct nsc_ircc_cb *self, int iobase)
 			/* Copy frame without CRC */
 			if (self->io.speed < 4000000) {
 				skb_put(skb, len-2);
-				memcpy(skb->data, self->rx_buff.data, len-2);
+				skb_copy_to_linear_data(skb,
+							self->rx_buff.data,
+							len - 2);
 			} else {
 				skb_put(skb, len-4);
-				memcpy(skb->data, self->rx_buff.data, len-4);
+				skb_copy_to_linear_data(skb,
+							self->rx_buff.data,
+							len - 4);
 			}
 
 			/* Move to next frame */
diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/net/irda/pxaficp_ir.c
index 8fc1348..8951703 100644
--- a/drivers/net/irda/pxaficp_ir.c
+++ b/drivers/net/irda/pxaficp_ir.c
@@ -371,7 +371,7 @@ static void pxa_irda_fir_irq_eif(struct pxa_irda *si, struct net_device *dev)
 
 		/* Align IP header to 20 bytes  */
 		skb_reserve(skb, 1);
-		memcpy(skb->data, si->dma_rx_buff, len);
+		skb_copy_to_linear_data(skb, si->dma_rx_buff, len);
 		skb_put(skb, len);
 
 		/* Feed it to IrLAP  */
diff --git a/drivers/net/irda/stir4200.c b/drivers/net/irda/stir4200.c
index aec86a2..755aa44 100644
--- a/drivers/net/irda/stir4200.c
+++ b/drivers/net/irda/stir4200.c
@@ -348,7 +348,7 @@ static void fir_eof(struct stir_cb *stir)
 		}
 		skb_reserve(nskb, 1);
 		skb = nskb;
-		memcpy(nskb->data, rx_buff->data, len);
+		skb_copy_to_linear_data(nskb, rx_buff->data, len);
 	} else {
 		nskb = dev_alloc_skb(rx_buff->truesize);
 		if (unlikely(!nskb)) {
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index 45bbd66..ff53585 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -1189,7 +1189,7 @@ F01_E */
 		skb_reserve(skb, 1);
 		skb_put(skb, len - 4);
 
-		memcpy(skb->data, self->rx_buff.data, len - 4);
+		skb_copy_to_linear_data(skb, self->rx_buff.data, len - 4);
 		IRDA_DEBUG(2, "%s(): len=%x.rx_buff=%p\n", __FUNCTION__,
 			   len - 4, self->rx_buff.data);
 
@@ -1234,7 +1234,7 @@ static int upload_rxdata(struct via_ircc_cb *self, int iobase)
 	}
 	skb_reserve(skb, 1);
 	skb_put(skb, len - 4 + 1);
-	memcpy(skb->data, self->rx_buff.data, len - 4 + 1);
+	skb_copy_to_linear_data(skb, self->rx_buff.data, len - 4 + 1);
 	st_fifo->tail++;
 	st_fifo->len++;
 	if (st_fifo->tail > MAX_RX_WINDOW)
@@ -1303,7 +1303,7 @@ static int RxTimerHandler(struct via_ircc_cb *self, int iobase)
 			}
 			skb_reserve(skb, 1);
 			skb_put(skb, len - 4);
-			memcpy(skb->data, self->rx_buff.data, len - 4);
+			skb_copy_to_linear_data(skb, self->rx_buff.data, len - 4);
 
 			IRDA_DEBUG(2, "%s(): len=%x.head=%x\n", __FUNCTION__,
 				   len - 4, st_fifo->head);
diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index 0d4a686..5182e80 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -908,10 +908,14 @@ int w83977af_dma_receive_complete(struct w83977af_ir *self)
 			/* Copy frame without CRC */
 			if (self->io.speed < 4000000) {
 				skb_put(skb, len-2);
-				memcpy(skb->data, self->rx_buff.data, len-2);
+				skb_copy_to_linear_data(skb,
+							self->rx_buff.data,
+							len - 2);
 			} else {
 				skb_put(skb, len-4);
-				memcpy(skb->data, self->rx_buff.data, len-4);
+				skb_copy_to_linear_data(skb,
+							self->rx_buff.data,
+							len - 4);
 			}
 
 			/* Move to next frame */
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index e729ced..dfde80e 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -2017,9 +2017,12 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 			    netdev_alloc_skb(netdev, length + NET_IP_ALIGN);
 			if (new_skb) {
 				skb_reserve(new_skb, NET_IP_ALIGN);
-				memcpy(new_skb->data - NET_IP_ALIGN,
-				       skb->data - NET_IP_ALIGN,
-				       length + NET_IP_ALIGN);
+				skb_copy_to_linear_data_offset(new_skb,
+							       -NET_IP_ALIGN,
+							       (skb->data -
+							        NET_IP_ALIGN),
+							       (length +
+							        NET_IP_ALIGN));
 				/* save the skb in buffer_info as good */
 				buffer_info->skb = skb;
 				skb = new_skb;
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 20b5cb1..6df673a 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -94,7 +94,8 @@ static void emulate_large_send_offload(struct sk_buff *skb)
 		skb_set_mac_header(nskb, -ETH_HLEN);
 		skb_reset_network_header(nskb);
 		iph = ip_hdr(nskb);
-		memcpy(nskb->data, skb_network_header(skb), doffset);
+		skb_copy_to_linear_data(nskb, skb_network_header(skb),
+					doffset);
 		if (skb_copy_bits(skb,
 				  doffset + offset,
 				  nskb->data + doffset,
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 9e233f8..0e04f7a 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -367,9 +367,10 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 			BUG_ON(frag != last_frag);
 			frag_len = len - offset;
 		}
-		memcpy(skb->data + offset,
-		       bp->rx_buffers + (RX_BUFFER_SIZE * frag),
-		       frag_len);
+		skb_copy_to_linear_data_offset(skb, offset,
+					       (bp->rx_buffers +
+					        (RX_BUFFER_SIZE * frag)),
+					       frag_len);
 		offset += RX_BUFFER_SIZE;
 		bp->rx_ring[frag].addr &= ~MACB_BIT(RX_USED);
 		wmb();
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 56e6f97..973c552 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -879,7 +879,7 @@ myri10ge_rx_skb_build(struct sk_buff *skb, u8 * va,
 	 * skb_pull() (for ether_pad and eth_type_trans()) requires
 	 * the beginning of the packet in skb_headlen(), move it
 	 * manually */
-	memcpy(skb->data, va, hlen);
+	skb_copy_to_linear_data(skb, va, hlen);
 	skb_shinfo(skb)->frags[0].page_offset += hlen;
 	skb_shinfo(skb)->frags[0].size -= hlen;
 	skb->data_len -= hlen;
diff --git a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
index b987a5c..e0a9300 100644
--- a/drivers/net/sk98lin/skge.c
+++ b/drivers/net/sk98lin/skge.c
@@ -2127,7 +2127,7 @@ rx_start:
 						    (dma_addr_t) PhysAddr,
 						    FrameLength,
 						    PCI_DMA_FROMDEVICE);
-			memcpy(pNewMsg->data, pMsg, FrameLength);
+			skb_copy_to_linear_data(pNewMsg, pMsg, FrameLength);
 
 			pci_dma_sync_single_for_device(pAC->PciDev,
 						       (dma_addr_t) PhysAddr,
diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
index 064e7c2..a7ef6c8 100644
--- a/drivers/net/skfp/skfddi.c
+++ b/drivers/net/skfp/skfddi.c
@@ -1937,7 +1937,7 @@ int mac_drv_rx_init(struct s_smc *smc, int len, int fc,
 	}
 	skb_reserve(skb, 3);
 	skb_put(skb, len);
-	memcpy(skb->data, look_ahead, len);
+	skb_copy_to_linear_data(skb, look_ahead, len);
 
 	// deliver frame to system
 	skb->protocol = fddi_type_trans(skb, smc->os.dev);
diff --git a/drivers/net/sun3lance.c b/drivers/net/sun3lance.c
index a73786d..233c2ec 100644
--- a/drivers/net/sun3lance.c
+++ b/drivers/net/sun3lance.c
@@ -839,7 +839,7 @@ static int lance_rx( struct net_device *dev )
 
 				skb_reserve( skb, 2 );	/* 16 byte align */
 				skb_put( skb, pkt_len );	/* Make room */
-//			        memcpy( skb->data, PKTBUF_ADDR(head), pkt_len );
+//			        skb_copy_to_linear_data(skb, PKTBUF_ADDR(head), pkt_len);
 				eth_copy_and_sum(skb,
 						 PKTBUF_ADDR(head),
 						 pkt_len, 0);
diff --git a/drivers/net/tokenring/smctr.c b/drivers/net/tokenring/smctr.c
index b0296d8..19a6020 100644
--- a/drivers/net/tokenring/smctr.c
+++ b/drivers/net/tokenring/smctr.c
@@ -3889,7 +3889,7 @@ static int smctr_process_rx_packet(MAC_HEADER *rmf, __u16 size,
 
                 /* Slide data into a sleek skb. */
                 skb_put(skb, skb->len);
-                memcpy(skb->data, rmf, skb->len);
+                skb_copy_to_linear_data(skb, rmf, skb->len);
 
                 /* Update Counters */
                 tp->MacStat.rx_packets++;
@@ -4475,7 +4475,7 @@ static int smctr_rx_frame(struct net_device *dev)
 				if (skb) {
                                 	skb_put(skb, rx_size);
 
-                                	memcpy(skb->data, pbuff, rx_size);
+                                	skb_copy_to_linear_data(skb, pbuff, rx_size);
 
                                 	/* Update Counters */
                                 	tp->MacStat.rx_packets++;
diff --git a/drivers/net/tokenring/tms380tr.c b/drivers/net/tokenring/tms380tr.c
index e6f0817..12bd294 100644
--- a/drivers/net/tokenring/tms380tr.c
+++ b/drivers/net/tokenring/tms380tr.c
@@ -2178,7 +2178,8 @@ static void tms380tr_rcv_status_irq(struct net_device *dev)
 				|| rpl->SkbStat == SKB_DMA_DIRECT))
 			{
 				if(rpl->SkbStat == SKB_DATA_COPY)
-					memcpy(skb->data, ReceiveDataPtr, Length);
+					skb_copy_to_linear_data(skb, ReceiveDataPtr,
+						       Length);
 
 				/* Deliver frame to system */
 				rpl->Skb = NULL;
diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 25021a7..dca0244 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -1904,7 +1904,8 @@ static struct sk_buff *dscc4_init_dummy_skb(struct dscc4_dev_priv *dpriv)
 		struct TxFD *tx_fd = dpriv->tx_fd + last;
 
 		skb->len = DUMMY_SKB_SIZE;
-		memcpy(skb->data, version, strlen(version)%DUMMY_SKB_SIZE);
+		skb_copy_to_linear_data(skb, version,
+					strlen(version) % DUMMY_SKB_SIZE);
 		tx_fd->state = FrameEnd | TO_STATE_TX(DUMMY_SKB_SIZE);
 		tx_fd->data = pci_map_single(dpriv->pci_priv->pdev, skb->data,
 					     DUMMY_SKB_SIZE, PCI_DMA_TODEVICE);
diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index 8ba75bb..999bf71 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -1759,7 +1759,7 @@ cpc_trace(struct net_device *dev, struct sk_buff *skb_main, char rx_tx)
 	skb->pkt_type = PACKET_HOST;
 	skb->len = 10 + skb_main->len;
 
-	memcpy(skb->data, dev->name, 5);
+	skb_copy_to_linear_data(skb, dev->name, 5);
 	skb->data[5] = '[';
 	skb->data[6] = rx_tx;
 	skb->data[7] = ']';
diff --git a/drivers/net/wan/pc300_tty.c b/drivers/net/wan/pc300_tty.c
index de02a07..d289acb 100644
--- a/drivers/net/wan/pc300_tty.c
+++ b/drivers/net/wan/pc300_tty.c
@@ -1007,13 +1007,13 @@ static void cpc_tty_trace(pc300dev_t *dev, char* buf, int len, char rxtx)
 	skb->pkt_type = PACKET_HOST; 
 	skb->len = 10 + len; 
 
-	memcpy(skb->data,dev->dev->name,5);
+	skb_copy_to_linear_data(skb, dev->dev->name, 5);
 	skb->data[5] = '['; 
 	skb->data[6] = rxtx; 
 	skb->data[7] = ']'; 
 	skb->data[8] = ':'; 
 	skb->data[9] = ' '; 
-	memcpy(&skb->data[10], buf, len); 
+	skb_copy_to_linear_data_offset(skb, 10, buf, len); 
 	netif_rx(skb); 
 } 	
 
diff --git a/drivers/net/wan/z85230.c b/drivers/net/wan/z85230.c
index 9432d2c..98ef400 100644
--- a/drivers/net/wan/z85230.c
+++ b/drivers/net/wan/z85230.c
@@ -1656,7 +1656,7 @@ static void z8530_rx_done(struct z8530_channel *c)
 		else
 		{
 			skb_put(skb, ct);
-			memcpy(skb->data, rxb, ct);
+			skb_copy_to_linear_data(skb, rxb, ct);
 			c->stats.rx_packets++;
 			c->stats.rx_bytes+=ct;
 		}
diff --git a/drivers/net/wireless/prism54/islpci_eth.c b/drivers/net/wireless/prism54/islpci_eth.c
index 7d8bff1..dd070cc 100644
--- a/drivers/net/wireless/prism54/islpci_eth.c
+++ b/drivers/net/wireless/prism54/islpci_eth.c
@@ -136,7 +136,7 @@ islpci_eth_transmit(struct sk_buff *skb, struct net_device *ndev)
 				printk("islpci_eth_transmit:wds_mac\n");
 #endif
 				memmove(skb->data + 6, src, skb->len);
-				memcpy(skb->data, wds_mac, 6);
+				skb_copy_to_linear_data(skb, wds_mac, 6);
 			} else {
 				memmove(skb->data, src, skb->len);
 			}
@@ -165,7 +165,7 @@ islpci_eth_transmit(struct sk_buff *skb, struct net_device *ndev)
 				skb_copy_from_linear_data(skb,
 							  newskb->data + 6,
 							  skb->len);
-				memcpy(newskb->data, wds_mac, 6);
+				skb_copy_to_linear_data(newskb, wds_mac, 6);
 #ifdef ISLPCI_ETH_DEBUG
 				printk("islpci_eth_transmit:wds_mac\n");
 #endif
diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index df7f279..ad7792d 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -2501,7 +2501,8 @@ qeth_process_inbound_buffer(struct qeth_card *card,
 			vlan_tag = qeth_rebuild_skb(card, skb, hdr);
 		else { /*in case of OSN*/
 			skb_push(skb, sizeof(struct qeth_hdr));
-			memcpy(skb->data, hdr, sizeof(struct qeth_hdr));
+			skb_copy_to_linear_data(skb, hdr,
+						sizeof(struct qeth_hdr));
 		}
 		/* is device UP ? */
 		if (!(card->dev->flags & IFF_UP)){
@@ -3870,9 +3871,9 @@ __qeth_prepare_skb(struct qeth_card *card, struct sk_buff *skb, int ipv)
 		 * memcpys instead of one memmove to save cycles.
 		 */
 		skb_push(skb, VLAN_HLEN);
-		memcpy(skb->data, skb->data + 4, 4);
-		memcpy(skb->data + 4, skb->data + 8, 4);
-		memcpy(skb->data + 8, skb->data + 12, 4);
+		skb_copy_to_linear_data(skb, skb->data + 4, 4);
+		skb_copy_to_linear_data_offset(skb, 4, skb->data + 8, 4);
+		skb_copy_to_linear_data_offset(skb, 8, skb->data + 12, 4);
 		tag = (u16 *)(skb->data + 12);
 		/*
 		 * first two bytes  = ETH_P_8021Q (0x8100)
diff --git a/drivers/usb/atm/usbatm.c b/drivers/usb/atm/usbatm.c
index d287c57..d3e2c5f 100644
--- a/drivers/usb/atm/usbatm.c
+++ b/drivers/usb/atm/usbatm.c
@@ -396,7 +396,9 @@ static void usbatm_extract_one_cell(struct usbatm_data *instance, unsigned char
 			goto out;	/* atm_charge increments rx_drop */
 		}
 
-		memcpy(skb->data, skb_tail_pointer(sarb) - pdu_length, length);
+		skb_copy_to_linear_data(skb,
+					skb_tail_pointer(sarb) - pdu_length,
+					length);
 		__skb_put(skb, length);
 
 		vdbg("%s: sending skb 0x%p, skb->len %u, skb->truesize %u",
diff --git a/drivers/usb/net/asix.c b/drivers/usb/net/asix.c
index f56e2da..d5ef97b 100644
--- a/drivers/usb/net/asix.c
+++ b/drivers/usb/net/asix.c
@@ -352,7 +352,7 @@ static struct sk_buff *asix_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
 	skb_push(skb, 4);
 	packet_len = (((skb->len - 4) ^ 0x0000ffff) << 16) + (skb->len - 4);
 	cpu_to_le32s(&packet_len);
-	memcpy(skb->data, &packet_len, sizeof(packet_len));
+	skb_copy_to_linear_data(skb, &packet_len, sizeof(packet_len));
 
 	if ((skb->len % 512) == 0) {
 		cpu_to_le32s(&padbytes);
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 08fa5c8..cbdf8e0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1520,6 +1520,21 @@ static inline void skb_copy_from_linear_data_offset(const struct sk_buff *skb,
 	memcpy(to, skb->data + offset, len);
 }
 
+static inline void skb_copy_to_linear_data(struct sk_buff *skb,
+					   const void *from,
+					   const unsigned int len)
+{
+	memcpy(skb->data, from, len);
+}
+
+static inline void skb_copy_to_linear_data_offset(struct sk_buff *skb,
+						  const int offset,
+						  const void *from,
+						  const unsigned int len)
+{
+	memcpy(skb->data + offset, from, len);
+}
+
 extern void skb_init(void);
 
 /**
diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index a1686df..0e9f00c 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -173,7 +173,7 @@ static int br2684_xmit_vcc(struct sk_buff *skb, struct br2684_dev *brdev,
 	}
 	skb_push(skb, minheadroom);
 	if (brvcc->encaps == e_llc)
-		memcpy(skb->data, llc_oui_pid_pad, 10);
+		skb_copy_to_linear_data(skb, llc_oui_pid_pad, 10);
 	else
 		memset(skb->data, 0, 2);
 #endif /* FASTER_VERSION */
diff --git a/net/atm/lec.c b/net/atm/lec.c
index 4b3e72f..6d63afa 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -576,8 +576,8 @@ static int lec_atm_send(struct atm_vcc *vcc, struct sk_buff *skb)
 					break;
 				}
 				skb2->len = sizeof(struct atmlec_msg);
-				memcpy(skb2->data, mesg,
-				       sizeof(struct atmlec_msg));
+				skb_copy_to_linear_data(skb2, mesg,
+							sizeof(*mesg));
 				atm_force_charge(priv->lecd, skb2->truesize);
 				sk = sk_atm(priv->lecd);
 				skb_queue_tail(&sk->sk_receive_queue, skb2);
@@ -1337,7 +1337,7 @@ static int lane2_resolve(struct net_device *dev, u8 *dst_mac, int force,
 		if (skb == NULL)
 			return -1;
 		skb->len = *sizeoftlvs;
-		memcpy(skb->data, *tlvs, *sizeoftlvs);
+		skb_copy_to_linear_data(skb, *tlvs, *sizeoftlvs);
 		retval = send_to_lecd(priv, l_arp_xmt, dst_mac, NULL, skb);
 	}
 	return retval;
@@ -1371,7 +1371,7 @@ static int lane2_associate_req(struct net_device *dev, u8 *lan_dst,
 	if (skb == NULL)
 		return 0;
 	skb->len = sizeoftlvs;
-	memcpy(skb->data, tlvs, sizeoftlvs);
+	skb_copy_to_linear_data(skb, tlvs, sizeoftlvs);
 	retval = send_to_lecd(priv, l_associate_req, NULL, NULL, skb);
 	if (retval != 0)
 		printk("lec.c: lane2_associate_req() failed\n");
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index 4d2592c..813e08d 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -504,11 +504,13 @@ static int send_via_shortcut(struct sk_buff *skb, struct mpoa_client *mpc)
 		tagged_llc_snap_hdr.tag = entry->ctrl_info.tag;
 		skb_pull(skb, ETH_HLEN);                       /* get rid of Eth header */
 		skb_push(skb, sizeof(tagged_llc_snap_hdr));    /* add LLC/SNAP header   */
-		memcpy(skb->data, &tagged_llc_snap_hdr, sizeof(tagged_llc_snap_hdr));
+		skb_copy_to_linear_data(skb, &tagged_llc_snap_hdr,
+					sizeof(tagged_llc_snap_hdr));
 	} else {
 		skb_pull(skb, ETH_HLEN);                        /* get rid of Eth header */
 		skb_push(skb, sizeof(struct llc_snap_hdr));     /* add LLC/SNAP header + tag  */
-		memcpy(skb->data, &llc_snap_mpoa_data, sizeof(struct llc_snap_hdr));
+		skb_copy_to_linear_data(skb, &llc_snap_mpoa_data,
+					sizeof(struct llc_snap_hdr));
 	}
 
 	atomic_add(skb->truesize, &sk_atm(entry->shortcut)->sk_wmem_alloc);
@@ -711,7 +713,8 @@ static void mpc_push(struct atm_vcc *vcc, struct sk_buff *skb)
 		return;
 	}
 	skb_push(new_skb, eg->ctrl_info.DH_length);     /* add MAC header */
-	memcpy(new_skb->data, eg->ctrl_info.DLL_header, eg->ctrl_info.DH_length);
+	skb_copy_to_linear_data(new_skb, eg->ctrl_info.DLL_header,
+				eg->ctrl_info.DH_length);
 	new_skb->protocol = eth_type_trans(new_skb, dev);
 	skb_reset_network_header(new_skb);
 
@@ -936,7 +939,7 @@ int msg_to_mpoad(struct k_message *mesg, struct mpoa_client *mpc)
 	if (skb == NULL)
 		return -ENOMEM;
 	skb_put(skb, sizeof(struct k_message));
-	memcpy(skb->data, mesg, sizeof(struct k_message));
+	skb_copy_to_linear_data(skb, mesg, sizeof(*mesg));
 	atm_force_charge(mpc->mpoad_vcc, skb->truesize);
 
 	sk = sk_atm(mpc->mpoad_vcc);
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 8b45224..fd70d04 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -149,7 +149,8 @@ int nf_bridge_copy_header(struct sk_buff *skb)
 	if (err)
 		return err;
 
-	memcpy(skb->data - header_size, skb->nf_bridge->data, header_size);
+	skb_copy_to_linear_data_offset(skb, -header_size,
+				       skb->nf_bridge->data, header_size);
 
 	if (skb->protocol == htons(ETH_P_8021Q))
 		__skb_push(skb, VLAN_HLEN);
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index ae63087..e48a622 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -293,7 +293,7 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 	if (!skb)
 		return;
 
-	memcpy(skb->data, msg, len);
+	skb_copy_to_linear_data(skb, msg, len);
 	skb->len += len;
 
 	skb_push(skb, sizeof(*udph));
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e60864e..ddac26f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1188,7 +1188,7 @@ int skb_store_bits(const struct sk_buff *skb, int offset, void *from, int len)
 	if ((copy = start - offset) > 0) {
 		if (copy > len)
 			copy = len;
-		memcpy(skb->data + offset, from, copy);
+		skb_copy_to_linear_data_offset(skb, offset, from, copy);
 		if ((len -= copy) == 0)
 			return 0;
 		offset += copy;
diff --git a/net/ieee80211/ieee80211_rx.c b/net/ieee80211/ieee80211_rx.c
index 94e2b8e..6ae036b 100644
--- a/net/ieee80211/ieee80211_rx.c
+++ b/net/ieee80211/ieee80211_rx.c
@@ -759,8 +759,9 @@ int ieee80211_rx(struct ieee80211_device *ieee, struct sk_buff *skb,
 		    IEEE80211_FCTL_TODS) && skb->len >= ETH_HLEN + ETH_ALEN) {
 		/* Non-standard frame: get addr4 from its bogus location after
 		 * the payload */
-		memcpy(skb->data + ETH_ALEN,
-		       skb->data + skb->len - ETH_ALEN, ETH_ALEN);
+		skb_copy_to_linear_data_offset(skb, ETH_ALEN,
+					       skb->data + skb->len - ETH_ALEN,
+					       ETH_ALEN);
 		skb_trim(skb, skb->len - ETH_ALEN);
 	}
 #endif
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index ba348b1..ab86137 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -66,7 +66,7 @@ static int ipcomp_decompress(struct xfrm_state *x, struct sk_buff *skb)
 
 	skb->truesize += dlen - plen;
 	__skb_put(skb, dlen - plen);
-	memcpy(skb->data, scratch, dlen);
+	skb_copy_to_linear_data(skb, scratch, dlen);
 out:
 	put_cpu();
 	return err;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 48027df..0ebae41 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -584,7 +584,7 @@ static int ipmr_cache_report(struct sk_buff *pkt, vifi_t vifi, int assert)
 
 	skb->network_header = skb->tail;
 	skb_put(skb, ihl);
-	memcpy(skb->data,pkt->data,ihl);
+	skb_copy_to_linear_data(skb, pkt->data, ihl);
 	ip_hdr(skb)->protocol = 0;			/* Flag to the kernel this is a route add */
 	msg = (struct igmpmsg *)skb_network_header(skb);
 	msg->im_vif = vifi;
diff --git a/net/ipv4/ipvs/ip_vs_app.c b/net/ipv4/ipvs/ip_vs_app.c
index c8a822c..15ad5dd 100644
--- a/net/ipv4/ipvs/ip_vs_app.c
+++ b/net/ipv4/ipvs/ip_vs_app.c
@@ -602,7 +602,7 @@ int ip_vs_skb_replace(struct sk_buff *skb, gfp_t pri,
 		skb_put(skb, diff);
 		memmove(skb->data + o_offset + n_len,
 			skb->data + o_offset + o_len, o_left);
-		memcpy(skb->data + o_offset, n_buf, n_len);
+		skb_copy_to_linear_data_offset(skb, o_offset, n_buf, n_len);
 	}
 
 	/* must update the iph total length here */
diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index cd8fec0..0d72693 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -368,7 +368,7 @@ ipq_mangle_ipv4(ipq_verdict_msg_t *v, struct ipq_queue_entry *e)
 	}
 	if (!skb_make_writable(&e->skb, v->data_len))
 		return -ENOMEM;
-	memcpy(e->skb->data, v->payload, v->data_len);
+	skb_copy_to_linear_data(e->skb, v->payload, v->data_len);
 	e->skb->ip_summed = CHECKSUM_NONE;
 
 	return 0;
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index 7691a1b..1ee50b5 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -111,7 +111,7 @@ static int ipcomp6_input(struct xfrm_state *x, struct sk_buff *skb)
 
 	skb->truesize += dlen - plen;
 	__skb_put(skb, dlen - plen);
-	memcpy(skb->data, scratch, dlen);
+	skb_copy_to_linear_data(skb, scratch, dlen);
 	err = ipch->nexthdr;
 
 out_put_cpu:
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index 2f1ae42..bfae9fd 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -366,7 +366,7 @@ ipq_mangle_ipv6(ipq_verdict_msg_t *v, struct ipq_queue_entry *e)
 	}
 	if (!skb_make_writable(&e->skb, v->data_len))
 		return -ENOMEM;
-	memcpy(e->skb->data, v->payload, v->data_len);
+	skb_copy_to_linear_data(e->skb, v->payload, v->data_len);
 	e->skb->ip_summed = CHECKSUM_NONE;
 
 	return 0;
diff --git a/net/irda/irttp.c b/net/irda/irttp.c
index b55bc8f..3279897 100644
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -256,7 +256,7 @@ static struct sk_buff *irttp_reassemble_skb(struct tsap_cb *self)
 	 *  Copy all fragments to a new buffer
 	 */
 	while ((frag = skb_dequeue(&self->rx_fragments)) != NULL) {
-		memcpy(skb->data+n, frag->data, frag->len);
+		skb_copy_to_linear_data_offset(skb, n, frag->data, frag->len);
 		n += frag->len;
 
 		dev_kfree_skb(frag);
diff --git a/net/irda/wrapper.c b/net/irda/wrapper.c
index 2acc66d..a7a7f19 100644
--- a/net/irda/wrapper.c
+++ b/net/irda/wrapper.c
@@ -239,7 +239,8 @@ async_bump(struct net_device *dev,
 
 	if(docopy) {
 		/* Copy data without CRC (lenght already checked) */
-		memcpy(newskb->data, rx_buff->data, rx_buff->len - 2);
+		skb_copy_to_linear_data(newskb, rx_buff->data,
+					rx_buff->len - 2);
 		/* Deliver this skb */
 		dataskb = newskb;
 	} else {
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 9aefb1c..7a97bec 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -648,7 +648,7 @@ nfqnl_mangle(void *data, int data_len, struct nfqnl_queue_entry *e)
 	}
 	if (!skb_make_writable(&e->skb, data_len))
 		return -ENOMEM;
-	memcpy(e->skb->data, data, data_len);
+	skb_copy_to_linear_data(e->skb, data, data_len);
 	e->skb->ip_summed = CHECKSUM_NONE;
 	return 0;
 }
diff --git a/net/netrom/nr_out.c b/net/netrom/nr_out.c
index 7c467c9..e3e6c44 100644
--- a/net/netrom/nr_out.c
+++ b/net/netrom/nr_out.c
@@ -59,8 +59,8 @@ void nr_output(struct sock *sk, struct sk_buff *skb)
 
 			/* Duplicate the Transport Header */
 			skb_push(skbn, NR_TRANSPORT_LEN);
-			memcpy(skbn->data, transport, NR_TRANSPORT_LEN);
-
+			skb_copy_to_linear_data(skbn, transport,
+						NR_TRANSPORT_LEN);
 			if (skb->len > 0)
 				skbn->data[4] |= NR_MORE_FLAG;
 
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index f38c3b3..806bf6f 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1181,7 +1181,7 @@ static int rose_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 			/* Duplicate the Header */
 			skb_push(skbn, ROSE_MIN_LEN);
-			memcpy(skbn->data, header, ROSE_MIN_LEN);
+			skb_copy_to_linear_data(skbn, header, ROSE_MIN_LEN);
 
 			if (skb->len > 0)
 				skbn->data[2] |= M_BIT;
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 71c2f2f..f3f99c8 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1001,7 +1001,7 @@ static int link_bundle_buf(struct link *l_ptr,
 		return 0;
 
 	skb_put(bundler, pad + size);
-	memcpy(bundler->data + to_pos, buf->data, size);
+	skb_copy_to_linear_data_offset(bundler, to_pos, buf->data, size);
 	msg_set_size(bundler_msg, to_pos + size);
 	msg_set_msgcnt(bundler_msg, msg_msgcnt(bundler_msg) + 1);
 	dbg("Packed msg # %u(%u octets) into pos %u in buf(#%u)\n",
@@ -1109,8 +1109,8 @@ int tipc_link_send_buf(struct link *l_ptr, struct sk_buff *buf)
 			if (bundler) {
 				msg_init(&bundler_hdr, MSG_BUNDLER, OPEN_MSG,
 					 TIPC_OK, INT_H_SIZE, l_ptr->addr);
-				memcpy(bundler->data, (unchar *)&bundler_hdr,
-				       INT_H_SIZE);
+				skb_copy_to_linear_data(bundler, &bundler_hdr,
+							INT_H_SIZE);
 				skb_trim(bundler, INT_H_SIZE);
 				link_bundle_buf(l_ptr, bundler, buf);
 				buf = bundler;
@@ -1383,9 +1383,9 @@ again:
 	if (!buf)
 		return -ENOMEM;
 	buf->next = NULL;
-	memcpy(buf->data, (unchar *)&fragm_hdr, INT_H_SIZE);
+	skb_copy_to_linear_data(buf, &fragm_hdr, INT_H_SIZE);
 	hsz = msg_hdr_sz(hdr);
-	memcpy(buf->data + INT_H_SIZE, (unchar *)hdr, hsz);
+	skb_copy_to_linear_data_offset(buf, INT_H_SIZE, hdr, hsz);
 	msg_dbg(buf_msg(buf), ">BUILD>");
 
 	/* Chop up message: */
@@ -1416,8 +1416,8 @@ error:
 				return -EFAULT;
 			}
 		} else
-			memcpy(buf->data + fragm_crs, sect_crs, sz);
-
+			skb_copy_to_linear_data_offset(buf, fragm_crs,
+						       sect_crs, sz);
 		sect_crs += sz;
 		sect_rest -= sz;
 		fragm_crs += sz;
@@ -1442,7 +1442,7 @@ error:
 
 			buf->next = NULL;
 			prev->next = buf;
-			memcpy(buf->data, (unchar *)&fragm_hdr, INT_H_SIZE);
+			skb_copy_to_linear_data(buf, &fragm_hdr, INT_H_SIZE);
 			fragm_crs = INT_H_SIZE;
 			fragm_rest = fragm_sz;
 			msg_dbg(buf_msg(buf),"  >BUILD>");
@@ -2130,7 +2130,7 @@ void tipc_link_send_proto_msg(struct link *l_ptr, u32 msg_typ, int probe_msg,
 		buf = l_ptr->proto_msg_queue;
 		if (!buf)
 			return;
-		memcpy(buf->data, (unchar *)msg, sizeof(l_ptr->proto_msg));
+		skb_copy_to_linear_data(buf, msg, sizeof(l_ptr->proto_msg));
 		return;
 	}
 	msg_set_timestamp(msg, jiffies_to_msecs(jiffies));
@@ -2143,7 +2143,7 @@ void tipc_link_send_proto_msg(struct link *l_ptr, u32 msg_typ, int probe_msg,
 	if (!buf)
 		return;
 
-	memcpy(buf->data, (unchar *)msg, sizeof(l_ptr->proto_msg));
+	skb_copy_to_linear_data(buf, msg, sizeof(l_ptr->proto_msg));
 	msg_set_size(buf_msg(buf), msg_size);
 
 	if (tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr)) {
@@ -2319,8 +2319,8 @@ void tipc_link_tunnel(struct link *l_ptr,
 		     "unable to send tunnel msg\n");
 		return;
 	}
-	memcpy(buf->data, (unchar *)tunnel_hdr, INT_H_SIZE);
-	memcpy(buf->data + INT_H_SIZE, (unchar *)msg, length);
+	skb_copy_to_linear_data(buf, tunnel_hdr, INT_H_SIZE);
+	skb_copy_to_linear_data_offset(buf, INT_H_SIZE, msg, length);
 	dbg("%c->%c:", l_ptr->b_ptr->net_plane, tunnel->b_ptr->net_plane);
 	msg_dbg(buf_msg(buf), ">SEND>");
 	tipc_link_send_buf(tunnel, buf);
@@ -2361,7 +2361,7 @@ void tipc_link_changeover(struct link *l_ptr)
 
 		buf = buf_acquire(INT_H_SIZE);
 		if (buf) {
-			memcpy(buf->data, (unchar *)&tunnel_hdr, INT_H_SIZE);
+			skb_copy_to_linear_data(buf, &tunnel_hdr, INT_H_SIZE);
 			msg_set_size(&tunnel_hdr, INT_H_SIZE);
 			dbg("%c->%c:", l_ptr->b_ptr->net_plane,
 			    tunnel->b_ptr->net_plane);
@@ -2426,8 +2426,9 @@ void tipc_link_send_duplicate(struct link *l_ptr, struct link *tunnel)
 			     "unable to send duplicate msg\n");
 			return;
 		}
-		memcpy(outbuf->data, (unchar *)&tunnel_hdr, INT_H_SIZE);
-		memcpy(outbuf->data + INT_H_SIZE, iter->data, length);
+		skb_copy_to_linear_data(outbuf, &tunnel_hdr, INT_H_SIZE);
+		skb_copy_to_linear_data_offset(outbuf, INT_H_SIZE, iter->data,
+					       length);
 		dbg("%c->%c:", l_ptr->b_ptr->net_plane,
 		    tunnel->b_ptr->net_plane);
 		msg_dbg(buf_msg(outbuf), ">SEND>");
@@ -2457,7 +2458,7 @@ static struct sk_buff *buf_extract(struct sk_buff *skb, u32 from_pos)
 
 	eb = buf_acquire(size);
 	if (eb)
-		memcpy(eb->data, (unchar *)msg, size);
+		skb_copy_to_linear_data(eb, msg, size);
 	return eb;
 }
 
@@ -2631,9 +2632,9 @@ int tipc_link_send_long_buf(struct link *l_ptr, struct sk_buff *buf)
 			goto exit;
 		}
 		msg_set_size(&fragm_hdr, fragm_sz + INT_H_SIZE);
-		memcpy(fragm->data, (unchar *)&fragm_hdr, INT_H_SIZE);
-		memcpy(fragm->data + INT_H_SIZE, crs, fragm_sz);
-
+		skb_copy_to_linear_data(fragm, &fragm_hdr, INT_H_SIZE);
+		skb_copy_to_linear_data_offset(fragm, INT_H_SIZE, crs,
+					       fragm_sz);
 		/*  Send queued messages first, if any: */
 
 		l_ptr->stats.sent_fragments++;
@@ -2733,8 +2734,8 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
 		if (pbuf != NULL) {
 			pbuf->next = *pending;
 			*pending = pbuf;
-			memcpy(pbuf->data, (unchar *)imsg, msg_data_sz(fragm));
-
+			skb_copy_to_linear_data(pbuf, imsg,
+						msg_data_sz(fragm));
 			/*  Prepare buffer for subsequent fragments. */
 
 			set_long_msg_seqno(pbuf, long_msg_seq_no);
@@ -2750,7 +2751,8 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
 		u32 fsz = get_fragm_size(pbuf);
 		u32 crs = ((msg_fragm_no(fragm) - 1) * fsz);
 		u32 exp_frags = get_expected_frags(pbuf) - 1;
-		memcpy(pbuf->data + crs, msg_data(fragm), dsz);
+		skb_copy_to_linear_data_offset(pbuf, crs,
+					       msg_data(fragm), dsz);
 		buf_discard(fbuf);
 
 		/* Is message complete? */
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 62d5490..aec7ce7 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -786,15 +786,16 @@ static inline int msg_build(struct tipc_msg *hdr,
 	*buf = buf_acquire(sz);
 	if (!(*buf))
 		return -ENOMEM;
-	memcpy((*buf)->data, (unchar *)hdr, hsz);
+	skb_copy_to_linear_data(*buf, hdr, hsz);
 	for (res = 1, cnt = 0; res && (cnt < num_sect); cnt++) {
 		if (likely(usrmem))
 			res = !copy_from_user((*buf)->data + pos,
 					      msg_sect[cnt].iov_base,
 					      msg_sect[cnt].iov_len);
 		else
-			memcpy((*buf)->data + pos, msg_sect[cnt].iov_base,
-			       msg_sect[cnt].iov_len);
+			skb_copy_to_linear_data_offset(*buf, pos,
+						       msg_sect[cnt].iov_base,
+						       msg_sect[cnt].iov_len);
 		pos += msg_sect[cnt].iov_len;
 	}
 	if (likely(res))
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 5f8217d..bcd5da0 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -464,7 +464,7 @@ int tipc_reject_msg(struct sk_buff *buf, u32 err)
 	msg_set_size(rmsg, data_sz + hdr_sz);
 	msg_set_nametype(rmsg, msg_nametype(msg));
 	msg_set_nameinst(rmsg, msg_nameinst(msg));
-	memcpy(rbuf->data + hdr_sz, msg_data(msg), data_sz);
+	skb_copy_to_linear_data_offset(rbuf, hdr_sz, msg_data(msg), data_sz);
 
 	/* send self-abort message when rejecting on a connected port */
 	if (msg_connected(msg)) {
@@ -1419,7 +1419,7 @@ int tipc_send_buf(u32 ref, struct sk_buff *buf, unsigned int dsz)
 		return -ENOMEM;
 
 	skb_push(buf, hsz);
-	memcpy(buf->data, (unchar *)msg, hsz);
+	skb_copy_to_linear_data(buf, msg, hsz);
 	destnode = msg_destnode(msg);
 	p_ptr->publ.congested = 1;
 	if (!tipc_port_congested(p_ptr)) {
@@ -1555,7 +1555,7 @@ int tipc_forward_buf2name(u32 ref,
 	if (skb_cow(buf, LONG_H_SIZE))
 		return -ENOMEM;
 	skb_push(buf, LONG_H_SIZE);
-	memcpy(buf->data, (unchar *)msg, LONG_H_SIZE);
+	skb_copy_to_linear_data(buf, msg, LONG_H_SIZE);
 	msg_dbg(buf_msg(buf),"PREP:");
 	if (likely(destport || destnode)) {
 		p_ptr->sent++;
@@ -1679,7 +1679,7 @@ int tipc_forward_buf2port(u32 ref,
 		return -ENOMEM;
 
 	skb_push(buf, DIR_MSG_H_SIZE);
-	memcpy(buf->data, (unchar *)msg, DIR_MSG_H_SIZE);
+	skb_copy_to_linear_data(buf, msg, DIR_MSG_H_SIZE);
 	msg_dbg(msg, "buf2port: ");
 	p_ptr->sent++;
 	if (dest->node == tipc_own_addr)
diff --git a/net/wanrouter/wanmain.c b/net/wanrouter/wanmain.c
index c49e223..7a19e0e 100644
--- a/net/wanrouter/wanmain.c
+++ b/net/wanrouter/wanmain.c
@@ -277,8 +277,8 @@ int wanrouter_encapsulate(struct sk_buff *skb, struct net_device *dev,
 		skb_push(skb, 7);
 		skb->data[0] = 0;
 		skb->data[1] = NLPID_SNAP;
-		memcpy(&skb->data[2], wanrouter_oui_ether,
-		       sizeof(wanrouter_oui_ether));
+		skb_copy_to_linear_data_offset(skb, 2, wanrouter_oui_ether,
+					       sizeof(wanrouter_oui_ether));
 		*((unsigned short*)&skb->data[5]) = htons(type);
 		break;
 
diff --git a/net/x25/x25_out.c b/net/x25/x25_out.c
index bb45e21..2b96b52 100644
--- a/net/x25/x25_out.c
+++ b/net/x25/x25_out.c
@@ -89,7 +89,7 @@ int x25_output(struct sock *sk, struct sk_buff *skb)
 
 			/* Duplicate the Header */
 			skb_push(skbn, header_len);
-			memcpy(skbn->data, header, header_len);
+			skb_copy_to_linear_data(skbn, header, header_len);
 
 			if (skb->len > 0) {
 				if (x25->neighbour->extended)
-- 
1.5.0.5

