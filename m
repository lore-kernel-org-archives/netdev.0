From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: [PATCH 2/3] [SK_BUFF]: Use skb_copy_bits where appropriate
Date: Sat, 24 Mar 2007 18:07:54 -0300
Message-ID: <20070324210753.GX17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.233]:33443 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753497AbXCXVIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Mar 2007 17:08:36 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1706211wxd
        for <netdev@vger.kernel.org>; Sat, 24 Mar 2007 14:08:35 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eliminating many more skb->data direct accesses, and skb_copy_bits also handles
non linear sk_buffs.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 arch/ia64/sn/kernel/xpnet.c                   |    3 ++-
 drivers/atm/atmtcp.c                          |    4 ++--
 drivers/atm/nicstar.c                         |    6 +++---
 drivers/bluetooth/bfusb.c                     |    2 +-
 drivers/bluetooth/bpa10x.c                    |    4 ++--
 drivers/bluetooth/dtl1_cs.c                   |    2 +-
 drivers/char/pcmcia/synclink_cs.c             |    2 +-
 drivers/infiniband/hw/cxgb3/iwch_cm.c         |    6 +++---
 drivers/isdn/act2000/module.c                 |    2 +-
 drivers/isdn/gigaset/usb-gigaset.c            |    2 +-
 drivers/isdn/hardware/avm/b1dma.c             |    2 +-
 drivers/isdn/hardware/avm/c4.c                |    2 +-
 drivers/isdn/hisax/elsa_ser.c                 |    5 +++--
 drivers/isdn/hisax/isdnl2.c                   |    2 +-
 drivers/isdn/hysdn/hycapi.c                   |    2 +-
 drivers/isdn/hysdn/hysdn_sched.c              |    5 +++--
 drivers/isdn/i4l/isdn_common.c                |    2 +-
 drivers/isdn/i4l/isdn_ppp.c                   |    4 ++--
 drivers/isdn/isdnloop/isdnloop.c              |    2 +-
 drivers/isdn/pcbit/capi.c                     |   10 +++++-----
 drivers/media/dvb/dvb-core/dvb_net.c          |    4 +++-
 drivers/message/fusion/mptlan.c               |    6 +++---
 drivers/net/3c505.c                           |    2 +-
 drivers/net/3c523.c                           |    2 +-
 drivers/net/7990.c                            |    2 +-
 drivers/net/a2065.c                           |    2 +-
 drivers/net/arcnet/capmode.c                  |    3 ++-
 drivers/net/atari_bionet.c                    |    2 +-
 drivers/net/atari_pamsnet.c                   |    2 +-
 drivers/net/au1000_eth.c                      |    2 +-
 drivers/net/b44.c                             |    5 ++---
 drivers/net/bnx2.c                            |    6 ++----
 drivers/net/cassini.c                         |    4 ++--
 drivers/net/chelsio/sge.c                     |    2 +-
 drivers/net/cxgb3/sge.c                       |    7 ++-----
 drivers/net/dgrs.c                            |    2 +-
 drivers/net/eepro100.c                        |    4 ++--
 drivers/net/ehea/ehea_main.c                  |   10 +++++-----
 drivers/net/fec_8xx/fec_main.c                |    3 ++-
 drivers/net/fs_enet/fs_enet-main.c            |    6 ++++--
 drivers/net/hamradio/dmascc.c                 |    2 +-
 drivers/net/hamradio/hdlcdrv.c                |    2 +-
 drivers/net/hamradio/yam.c                    |    2 +-
 drivers/net/ioc3-eth.c                        |    2 +-
 drivers/net/irda/ali-ircc.c                   |    5 ++---
 drivers/net/irda/au1k_ir.c                    |    2 +-
 drivers/net/irda/donauboe.c                   |    2 +-
 drivers/net/irda/irda-usb.c                   |    4 ++--
 drivers/net/irda/mcs7780.c                    |    4 ++--
 drivers/net/irda/nsc-ircc.c                   |    5 ++---
 drivers/net/irda/pxaficp_ir.c                 |    2 +-
 drivers/net/irda/smsc-ircc2.c                 |    2 +-
 drivers/net/irda/via-ircc.c                   |    4 ++--
 drivers/net/irda/vlsi_ir.c                    |    2 +-
 drivers/net/irda/w83977af_ir.c                |    2 +-
 drivers/net/lance.c                           |    2 +-
 drivers/net/macmace.c                         |    3 +--
 drivers/net/meth.c                            |   10 +++++-----
 drivers/net/myri_sbus.c                       |    2 +-
 drivers/net/netxen/netxen_nic_main.c          |    4 ++--
 drivers/net/ni52.c                            |    2 +-
 drivers/net/ni65.c                            |    5 +++--
 drivers/net/pci-skeleton.c                    |    2 +-
 drivers/net/pcmcia/axnet_cs.c                 |    2 +-
 drivers/net/ppp_synctty.c                     |    3 ++-
 drivers/net/pppoe.c                           |    2 +-
 drivers/net/qla3xxx.c                         |    2 +-
 drivers/net/rrunner.c                         |    2 +-
 drivers/net/sgiseeq.c                         |    2 +-
 drivers/net/skge.c                            |    2 +-
 drivers/net/sky2.c                            |    2 +-
 drivers/net/sun3_82586.c                      |    2 +-
 drivers/net/sun3lance.c                       |    2 +-
 drivers/net/sungem.c                          |    2 +-
 drivers/net/sunhme.c                          |    2 +-
 drivers/net/sunlance.c                        |    2 +-
 drivers/net/sunqe.c                           |    2 +-
 drivers/net/tg3.c                             |    2 +-
 drivers/net/tlan.c                            |    2 +-
 drivers/net/tokenring/3c359.c                 |    6 ++++--
 drivers/net/tokenring/olympic.c               |    8 ++++++--
 drivers/net/tokenring/tms380tr.c              |    2 +-
 drivers/net/tulip/de2104x.c                   |    3 +--
 drivers/net/tulip/dmfe.c                      |    6 ++++--
 drivers/net/tulip/uli526x.c                   |    2 +-
 drivers/net/tulip/xircom_cb.c                 |    6 +++---
 drivers/net/tulip/xircom_tulip_cb.c           |    3 ++-
 drivers/net/tun.c                             |    4 ++--
 drivers/net/via-velocity.c                    |    6 +++---
 drivers/net/wan/lmc/lmc_main.c                |    2 +-
 drivers/net/wan/pc300_drv.c                   |    2 +-
 drivers/net/wan/z85230.c                      |    2 +-
 drivers/net/wireless/atmel.c                  |    4 ++--
 drivers/net/wireless/bcm43xx/bcm43xx_dma.c    |    2 +-
 drivers/net/wireless/hostap/hostap_80211_rx.c |    9 ++++-----
 drivers/net/wireless/hostap/hostap_80211_tx.c |   18 +++++++++---------
 drivers/net/wireless/hostap/hostap_ap.c       |    4 ++--
 drivers/net/wireless/hostap/hostap_hw.c       |    4 ++--
 drivers/net/wireless/ipw2100.c                |    5 +++--
 drivers/net/wireless/ipw2200.c                |    2 +-
 drivers/net/wireless/prism54/islpci_eth.c     |   10 ++++++----
 drivers/net/wireless/ray_cs.c                 |    3 ++-
 drivers/net/wireless/wavelan.c                |    2 +-
 drivers/net/wireless/zd1201.c                 |    4 ++--
 drivers/s390/net/ctcmain.c                    |   10 +++++-----
 drivers/s390/net/lcs.c                        |    2 +-
 drivers/s390/net/netiucv.c                    |    5 +++--
 drivers/s390/net/qeth_eddp.c                  |    2 +-
 drivers/usb/atm/usbatm.c                      |    2 +-
 drivers/usb/net/catc.c                        |    2 +-
 drivers/usb/net/pegasus.c                     |    2 +-
 net/ax25/ax25_out.c                           |    4 ++--
 net/bluetooth/bnep/core.c                     |    2 +-
 net/bluetooth/cmtp/core.c                     |    4 ++--
 net/bluetooth/l2cap.c                         |    6 ++++--
 net/decnet/dn_nsp_in.c                        |    5 +++--
 net/ieee80211/ieee80211_crypt_wep.c           |    2 +-
 net/ieee80211/ieee80211_rx.c                  |    6 +++---
 net/ieee80211/ieee80211_tx.c                  |    8 ++++----
 net/ipv4/ip_output.c                          |    2 +-
 net/ipv6/ip6_output.c                         |    2 +-
 net/irda/irttp.c                              |    4 ++--
 net/netrom/af_netrom.c                        |    3 ++-
 net/netrom/nr_loopback.c                      |    2 +-
 net/netrom/nr_out.c                           |    4 ++--
 net/netrom/nr_subr.c                          |    4 ++--
 net/rose/af_rose.c                            |    4 ++--
 net/x25/af_x25.c                              |    2 +-
 net/x25/x25_in.c                              |    5 +++--
 net/x25/x25_out.c                             |    4 ++--
 130 files changed, 243 insertions(+), 224 deletions(-)

diff --git a/arch/ia64/sn/kernel/xpnet.c b/arch/ia64/sn/kernel/xpnet.c
index 98d7914..3335b8a 100644
--- a/arch/ia64/sn/kernel/xpnet.c
+++ b/arch/ia64/sn/kernel/xpnet.c
@@ -566,7 +566,8 @@ xpnet_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			msg->version = XPNET_VERSION_EMBED;
 			dev_dbg(xpnet, "calling memcpy(0x%p, 0x%p, 0x%lx)\n",
 				&msg->data, skb->data, (size_t) embedded_bytes);
-			memcpy(&msg->data, skb->data, (size_t) embedded_bytes);
+			skb_copy_bits(skb, 0,
+				      &msg->data, (size_t)embedded_bytes);
 		} else {
 			msg->version = XPNET_VERSION;
 		}
diff --git a/drivers/atm/atmtcp.c b/drivers/atm/atmtcp.c
index fc518d8..9e71846 100644
--- a/drivers/atm/atmtcp.c
+++ b/drivers/atm/atmtcp.c
@@ -221,7 +221,7 @@ static int atmtcp_v_send(struct atm_vcc *vcc,struct sk_buff *skb)
 	hdr->vpi = htons(vcc->vpi);
 	hdr->vci = htons(vcc->vci);
 	hdr->length = htonl(skb->len);
-	memcpy(skb_put(new_skb,skb->len),skb->data,skb->len);
+	skb_copy_bits(skb, 0, skb_put(new_skb, skb->len), skb->len);
 	if (vcc->pop) vcc->pop(vcc,skb);
 	else dev_kfree_skb(skb);
 	out_vcc->push(out_vcc,new_skb);
@@ -310,7 +310,7 @@ static int atmtcp_c_send(struct atm_vcc *vcc,struct sk_buff *skb)
 		goto done;
 	}
 	__net_timestamp(new_skb);
-	memcpy(skb_put(new_skb,skb->len),skb->data,skb->len);
+	skb_copy_bits(skb, 0, skb_put(new_skb, skb->len), skb->len);
 	out_vcc->push(out_vcc,new_skb);
 	atomic_inc(&vcc->stats->tx);
 	atomic_inc(&out_vcc->stats->rx);
diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index 26f4b70..ad04df6 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -2395,7 +2395,7 @@ static void dequeue_rx(ns_dev *card, ns_rsqe *rsqe)
                skb->destructor = ns_lb_destructor;
 #endif /* NS_USE_DESTRUCTORS */
                skb_push(skb, NS_SMBUFSIZE);
-               memcpy(skb->data, sb->data, NS_SMBUFSIZE);
+               skb_copy_bits(sb, 0, skb->data, NS_SMBUFSIZE);
                skb_put(skb, len - NS_SMBUFSIZE);
                ATM_SKB(skb)->vcc = vcc;
 	       __net_timestamp(skb);
@@ -2479,7 +2479,7 @@ static void dequeue_rx(ns_dev *card, ns_rsqe *rsqe)
 	 {
             /* Copy the small buffer to the huge buffer */
             sb = (struct sk_buff *) iov->iov_base;
-            memcpy(hb->data, sb->data, iov->iov_len);
+            skb_copy_bits(sb, 0, hb->data, iov->iov_len);
             skb_put(hb, iov->iov_len);
             remaining = len - iov->iov_len;
             iov++;
@@ -2491,7 +2491,7 @@ static void dequeue_rx(ns_dev *card, ns_rsqe *rsqe)
             {
                lb = (struct sk_buff *) iov->iov_base;
                tocopy = min_t(int, remaining, iov->iov_len);
-               memcpy(skb_tail_pointer(hb), lb->data, tocopy);
+               skb_copy_bits(lb, 0, skb_tail_pointer(hb), tocopy);
                skb_put(hb, tocopy);
                iov++;
                remaining -= tocopy;
diff --git a/drivers/bluetooth/bfusb.c b/drivers/bluetooth/bfusb.c
index 4c766f3..e2c89c9 100644
--- a/drivers/bluetooth/bfusb.c
+++ b/drivers/bluetooth/bfusb.c
@@ -527,7 +527,7 @@ static int bfusb_send_frame(struct sk_buff *skb)
 		buf[2] = (size == BFUSB_MAX_BLOCK_SIZE) ? 0 : size;
 
 		memcpy(skb_put(nskb, 3), buf, 3);
-		memcpy(skb_put(nskb, size), skb->data + sent, size);
+		skb_copy_bits(skb, sent, skb_put(nskb, size), size);
 
 		sent  += size;
 		count -= size;
diff --git a/drivers/bluetooth/bpa10x.c b/drivers/bluetooth/bpa10x.c
index 9fca651..05e6647 100644
--- a/drivers/bluetooth/bpa10x.c
+++ b/drivers/bluetooth/bpa10x.c
@@ -231,7 +231,7 @@ static void bpa10x_wakeup(struct bpa10x_data *data)
 		cr = (struct usb_ctrlrequest *) urb->setup_packet;
 		cr->wLength = __cpu_to_le16(skb->len);
 
-		memcpy(urb->transfer_buffer, skb->data, skb->len);
+		skb_copy_bits(skb, 0, urb->transfer_buffer, skb->len);
 		urb->transfer_buffer_length = skb->len;
 
 		err = usb_submit_urb(urb, GFP_ATOMIC);
@@ -250,7 +250,7 @@ static void bpa10x_wakeup(struct bpa10x_data *data)
 		skb = skb_dequeue(&data->tx_queue);
 
 	if (skb) {
-		memcpy(urb->transfer_buffer, skb->data, skb->len);
+		skb_copy_bits(skb, 0, urb->transfer_buffer, skb->len);
 		urb->transfer_buffer_length = skb->len;
 
 		err = usb_submit_urb(urb, GFP_ATOMIC);
diff --git a/drivers/bluetooth/dtl1_cs.c b/drivers/bluetooth/dtl1_cs.c
index 459aa97..1f5978c 100644
--- a/drivers/bluetooth/dtl1_cs.c
+++ b/drivers/bluetooth/dtl1_cs.c
@@ -425,7 +425,7 @@ static int dtl1_hci_send_frame(struct sk_buff *skb)
 		return -ENOMEM;
 
 	skb_reserve(s, NSHL);
-	memcpy(skb_put(s, skb->len), skb->data, skb->len);
+	skb_copy_bits(skb, 0, skb_put(s, skb->len), skb->len);
 	if (skb->len & 0x0001)
 		*skb_put(s, 1) = 0;	/* PAD */
 
diff --git a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
index 8d025e9..243df4c 100644
--- a/drivers/char/pcmcia/synclink_cs.c
+++ b/drivers/char/pcmcia/synclink_cs.c
@@ -4169,7 +4169,7 @@ static int hdlcdev_xmit(struct sk_buff *skb, struct net_device *dev)
 	netif_stop_queue(dev);
 
 	/* copy data to device buffers */
-	memcpy(info->tx_buf, skb->data, skb->len);
+	skb_copy_bits(skb, 0, info->tx_buf, skb->len);
 	info->tx_get = 0;
 	info->tx_put = info->tx_count = skb->len;
 
diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
index 88ae3db..f8df994 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -821,7 +821,7 @@ static void process_mpa_reply(struct iwch_ep *ep, struct sk_buff *skb)
 	/*
 	 * copy the new data into our accumulation buffer.
 	 */
-	memcpy(&(ep->mpa_pkt[ep->mpa_pkt_len]), skb->data, skb->len);
+	skb_copy_bits(skb, 0, &(ep->mpa_pkt[ep->mpa_pkt_len]), skb->len);
 	ep->mpa_pkt_len += skb->len;
 
 	/*
@@ -940,7 +940,7 @@ static void process_mpa_request(struct iwch_ep *ep, struct sk_buff *skb)
 	/*
 	 * Copy the new data into our accumulation buffer.
 	 */
-	memcpy(&(ep->mpa_pkt[ep->mpa_pkt_len]), skb->data, skb->len);
+	skb_copy_bits(skb, 0, &(ep->mpa_pkt[ep->mpa_pkt_len]), skb->len);
 	ep->mpa_pkt_len += skb->len;
 
 	/*
@@ -1619,7 +1619,7 @@ static int terminate(struct t3cdev *tdev, struct sk_buff *skb, void *ctx)
 	PDBG("%s ep %p\n", __FUNCTION__, ep);
 	skb_pull(skb, sizeof(struct cpl_rdma_terminate));
 	PDBG("%s saving %d bytes of term msg\n", __FUNCTION__, skb->len);
-	memcpy(ep->com.qp->attr.terminate_buffer, skb->data, skb->len);
+	skb_copy_bits(skb, 0, ep->com.qp->attr.terminate_buffer, skb->len);
 	ep->com.qp->attr.terminate_msg_len = skb->len;
 	ep->com.qp->attr.is_terminate_local = 0;
 	return CPL_RET_BUF_DONE;
diff --git a/drivers/isdn/act2000/module.c b/drivers/isdn/act2000/module.c
index e3e5c13..2b484dd 100644
--- a/drivers/isdn/act2000/module.c
+++ b/drivers/isdn/act2000/module.c
@@ -442,7 +442,7 @@ act2000_sendbuf(act2000_card *card, int channel, int ack, struct sk_buff *skb)
 			return 0;
 		}
 		skb_reserve(xmit_skb, 19);
-		memcpy(skb_put(xmit_skb, len), skb->data, len);
+		skb_copy_bits(skb, 0, skb_put(xmit_skb, len), len);
 	} else {
 		xmit_skb = skb_clone(skb, GFP_ATOMIC);
 		if (!xmit_skb) {
diff --git a/drivers/isdn/gigaset/usb-gigaset.c b/drivers/isdn/gigaset/usb-gigaset.c
index 04f2ad7..8f90934 100644
--- a/drivers/isdn/gigaset/usb-gigaset.c
+++ b/drivers/isdn/gigaset/usb-gigaset.c
@@ -652,7 +652,7 @@ static int write_modem(struct cardstate *cs)
 	 * transmit data
 	 */
 	count = min(bcs->tx_skb->len, (unsigned) ucs->bulk_out_size);
-	memcpy(ucs->bulk_out_buffer, bcs->tx_skb->data, count);
+	skb_copy_bits(bcs->tx_skb, 0, ucs->bulk_out_buffer, count);
 	skb_pull(bcs->tx_skb, count);
 	atomic_set(&ucs->busy, 1);
 	gig_dbg(DEBUG_OUTPUT, "write_modem: send %d bytes", count);
diff --git a/drivers/isdn/hardware/avm/b1dma.c b/drivers/isdn/hardware/avm/b1dma.c
index 1e2d38e..d8f657b 100644
--- a/drivers/isdn/hardware/avm/b1dma.c
+++ b/drivers/isdn/hardware/avm/b1dma.c
@@ -404,7 +404,7 @@ static void b1dma_dispatch_tx(avmcard *card)
 		printk(KERN_DEBUG "tx: put 0x%x len=%d\n", 
 		       skb->data[2], txlen);
 #endif
-		memcpy(dma->sendbuf.dmabuf, skb->data+2, skb->len-2);
+		skb_copy_bits(skb, 2, dma->sendbuf.dmabuf, skb->len - 2);
 	}
 	txlen = (txlen + 3) & ~3;
 
diff --git a/drivers/isdn/hardware/avm/c4.c b/drivers/isdn/hardware/avm/c4.c
index 6f5efa8..bd23d60 100644
--- a/drivers/isdn/hardware/avm/c4.c
+++ b/drivers/isdn/hardware/avm/c4.c
@@ -457,7 +457,7 @@ static void c4_dispatch_tx(avmcard *card)
 		printk(KERN_DEBUG "%s: tx put 0x%x len=%d\n",
 				card->name, skb->data[2], txlen);
 #endif
-		memcpy(dma->sendbuf.dmabuf, skb->data+2, skb->len-2);
+		skb_copy_bits(skb, 2, dma->sendbuf.dmabuf, skb->len - 2);
 	}
 	txlen = (txlen + 3) & ~3;
 
diff --git a/drivers/isdn/hisax/elsa_ser.c b/drivers/isdn/hisax/elsa_ser.c
index ae377e8..175e89b 100644
--- a/drivers/isdn/hisax/elsa_ser.c
+++ b/drivers/isdn/hisax/elsa_ser.c
@@ -254,14 +254,15 @@ write_modem(struct BCState *bcs) {
 	count = len;
 	if (count > MAX_MODEM_BUF - fp) {
 		count = MAX_MODEM_BUF - fp;
-		memcpy(cs->hw.elsa.transbuf + fp, bcs->tx_skb->data, count);
+		skb_copy_bits(bcs->tx_skb, 0,
+			      cs->hw.elsa.transbuf + fp, count);
 		skb_pull(bcs->tx_skb, count);
 		cs->hw.elsa.transcnt += count;
 		ret = count;
 		count = len - count;
 		fp = 0;
 	}
-	memcpy((cs->hw.elsa.transbuf + fp), bcs->tx_skb->data, count);
+	skb_copy_bits(bcs->tx_skb, 0, cs->hw.elsa.transbuf + fp, count);
 	skb_pull(bcs->tx_skb, count);
 	cs->hw.elsa.transcnt += count;
 	ret += count;
diff --git a/drivers/isdn/hisax/isdnl2.c b/drivers/isdn/hisax/isdnl2.c
index cd3b5ad..7a7ea1e 100644
--- a/drivers/isdn/hisax/isdnl2.c
+++ b/drivers/isdn/hisax/isdnl2.c
@@ -1293,7 +1293,7 @@ l2_pull_iqueue(struct FsmInst *fi, int event, void *arg)
 		oskb = skb;
 		skb = alloc_skb(oskb->len + i, GFP_ATOMIC);
 		memcpy(skb_put(skb, i), header, i);
-		memcpy(skb_put(skb, oskb->len), oskb->data, oskb->len);
+		skb_copy_bits(oskb, 0, skb_put(skb, oskb->len), oskb->len);
 		dev_kfree_skb(oskb);
 	}
 	st->l2.l2l1(st, PH_PULL | INDICATION, skb);
diff --git a/drivers/isdn/hysdn/hycapi.c b/drivers/isdn/hysdn/hycapi.c
index b2ae4ec..662799f 100644
--- a/drivers/isdn/hysdn/hycapi.c
+++ b/drivers/isdn/hysdn/hycapi.c
@@ -398,7 +398,7 @@ static u16 hycapi_send_message(struct capi_ctr *ctrl, struct sk_buff *skb)
 			_len = CAPIMSG_LEN(skb->data);
 			if (_len > 22) {
 				_len2 = _len - 22;
-				memcpy(msghead, skb->data, 22);
+				skb_copy_bits(skb, 0, msghead, 22);
 				memcpy(skb->data + _len2, msghead, 22);
 				skb_pull(skb, _len2);
 				CAPIMSG_SETLEN(skb->data, 22);
diff --git a/drivers/isdn/hysdn/hysdn_sched.c b/drivers/isdn/hysdn/hysdn_sched.c
index b7b5aa4..69afabb 100644
--- a/drivers/isdn/hysdn/hysdn_sched.c
+++ b/drivers/isdn/hysdn/hysdn_sched.c
@@ -113,7 +113,8 @@ hysdn_sched_tx(hysdn_card *card, unsigned char *buf,
 	    (skb = hysdn_tx_netget(card)) != NULL) 
 	{
 		if (skb->len <= maxlen) {
-			memcpy(buf, skb->data, skb->len);	/* copy the packet to the buffer */
+			/* copy the packet to the buffer */
+			skb_copy_bits(skb, 0, buf, skb->len);
 			*len = skb->len;
 			*chan = CHAN_NDIS_DATA;
 			card->net_tx_busy = 1;	/* we are busy sending network data */
@@ -126,7 +127,7 @@ hysdn_sched_tx(hysdn_card *card, unsigned char *buf,
 	    ((skb = hycapi_tx_capiget(card)) != NULL) )
 	{
 		if (skb->len <= maxlen) {
-			memcpy(buf, skb->data, skb->len);
+			skb_copy_bits(skb, 0, buf, skb->len);
 			*len = skb->len;
 			*chan = CHAN_CAPI;
 			hycapi_tx_capiack(card);
diff --git a/drivers/isdn/i4l/isdn_common.c b/drivers/isdn/i4l/isdn_common.c
index 9c926e4..8173a4e 100644
--- a/drivers/isdn/i4l/isdn_common.c
+++ b/drivers/isdn/i4l/isdn_common.c
@@ -829,7 +829,7 @@ isdn_readbchan(int di, int channel, u_char * buf, u_char * fp, int len, wait_que
 				dflag = 0;
 			}
 			count_put = count_pull;
-			memcpy(cp, skb->data, count_put);
+			skb_copy_bits(skb, 0, cp, count_put);
 			cp += count_put;
 			len -= count_put;
 #ifdef CONFIG_ISDN_AUDIO
diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index be91505..5750672 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -1100,7 +1100,7 @@ isdn_ppp_push_higher(isdn_net_dev * net_dev, isdn_net_local * lp, struct sk_buff
 					goto drop_packet;
 				}
 				skb_put(skb, skb_old->len + 128);
-				memcpy(skb->data, skb_old->data, skb_old->len);
+				skb_copy_bits(skb_old, 0, skb->data, skb_old->len);
 				if (net_dev->local->ppp_slot < 0) {
 					printk(KERN_ERR "%s: net_dev->local->ppp_slot(%d) out of range\n",
 						__FUNCTION__, net_dev->local->ppp_slot);
@@ -1902,7 +1902,7 @@ void isdn_ppp_mp_reassembly( isdn_net_dev * net_dev, isdn_net_local * lp,
 		while( from != to ) {
 			unsigned int len = from->len - MP_HEADER_LEN;
 
-			memcpy(skb_put(skb,len), from->data+MP_HEADER_LEN, len);
+			skb_copy_bits(from, MP_HEADER_LEN, skb_put(skb,len), len);
 			frag = from->next;
 			isdn_ppp_mp_free_skb(mp, from);
 			from = frag; 
diff --git a/drivers/isdn/isdnloop/isdnloop.c b/drivers/isdn/isdnloop/isdnloop.c
index e3add27..bdc09f7 100644
--- a/drivers/isdn/isdnloop/isdnloop.c
+++ b/drivers/isdn/isdnloop/isdnloop.c
@@ -415,7 +415,7 @@ isdnloop_sendbuf(int channel, struct sk_buff *skb, isdnloop_card * card)
 		spin_lock_irqsave(&card->isdnloop_lock, flags);
 		nskb = dev_alloc_skb(skb->len);
 		if (nskb) {
-			memcpy(skb_put(nskb, len), skb->data, len);
+			skb_copy_bits(skb, 0, skb_put(nskb, len), len);
 			skb_queue_tail(&card->bqueue[channel], nskb);
 			dev_kfree_skb(skb);
 		} else
diff --git a/drivers/isdn/pcbit/capi.c b/drivers/isdn/pcbit/capi.c
index 47c59e9..1754284 100644
--- a/drivers/isdn/pcbit/capi.c
+++ b/drivers/isdn/pcbit/capi.c
@@ -429,8 +429,8 @@ int capi_decode_conn_ind(struct pcbit_chan * chan,
 		if (!(info->data.setup.CallingPN = kmalloc(len - count + 1, GFP_ATOMIC)))
 			return -1;
        
-		memcpy(info->data.setup.CallingPN, skb->data + count + 1, 
-		       len - count);
+		skb_copy_bits(skb, count + 1,
+			      info->data.setup.CallingPN, len - count);
 		info->data.setup.CallingPN[len - count] = 0;
 
 	}
@@ -457,8 +457,8 @@ int capi_decode_conn_ind(struct pcbit_chan * chan,
 		if (!(info->data.setup.CalledPN = kmalloc(len - count + 1, GFP_ATOMIC)))
 			return -1;
         
-		memcpy(info->data.setup.CalledPN, skb->data + count + 1, 
-		       len - count); 
+		skb_copy_bits(skb, count + 1,
+			      info->data.setup.CalledPN, len - count); 
 		info->data.setup.CalledPN[len - count] = 0;
 
 	}
@@ -539,7 +539,7 @@ int capi_decode_conn_actv_ind(struct pcbit_chan * chan, struct sk_buff *skb)
 
 #ifdef DEBUG
 	if (len > 1 && len < 31) {
-		memcpy(str, skb->data + 2, len - 1);
+		skb_copy_bits(skb, 2, str, len - 1);
 		str[len] = 0;
 		printk(KERN_DEBUG "Connected Party Number: %s\n", str);
 	}
diff --git a/drivers/media/dvb/dvb-core/dvb_net.c b/drivers/media/dvb/dvb-core/dvb_net.c
index 9de177a..18df5be 100644
--- a/drivers/media/dvb/dvb-core/dvb_net.c
+++ b/drivers/media/dvb/dvb-core/dvb_net.c
@@ -697,7 +697,9 @@ static void dvb_net_ule( struct net_device *dev, const u8 *buf, size_t buf_len )
 					}
 					else
 					{
-						memcpy(dest_addr,  priv->ule_skb->data, ETH_ALEN);
+						skb_copy_bits(priv->ule_skb, 0,
+							      dest_addr,
+							      ETH_ALEN);
 						skb_pull(priv->ule_skb, ETH_ALEN);
 					}
 				}
diff --git a/drivers/message/fusion/mptlan.c b/drivers/message/fusion/mptlan.c
index 21fe1b6..3466af2 100644
--- a/drivers/message/fusion/mptlan.c
+++ b/drivers/message/fusion/mptlan.c
@@ -932,7 +932,7 @@ mpt_lan_receive_post_turbo(struct net_device *dev, u32 tmsg)
 		pci_dma_sync_single_for_cpu(mpt_dev->pcidev, priv->RcvCtl[ctx].dma,
 					    priv->RcvCtl[ctx].len, PCI_DMA_FROMDEVICE);
 
-		memcpy(skb_put(skb, len), old_skb->data, len);
+		skb_copy_bits(old_skb, 0, skb_put(skb, len), len);
 
 		pci_dma_sync_single_for_device(mpt_dev->pcidev, priv->RcvCtl[ctx].dma,
 					       priv->RcvCtl[ctx].len, PCI_DMA_FROMDEVICE);
@@ -1093,7 +1093,7 @@ mpt_lan_receive_post_reply(struct net_device *dev,
 						    priv->RcvCtl[ctx].dma,
 						    priv->RcvCtl[ctx].len,
 						    PCI_DMA_FROMDEVICE);
-			memcpy(skb_put(skb, l), old_skb->data, l);
+			skb_copy_bits(old_skb, 0, skb_put(skb, l), l);
 
 			pci_dma_sync_single_for_device(mpt_dev->pcidev,
 						       priv->RcvCtl[ctx].dma,
@@ -1122,7 +1122,7 @@ mpt_lan_receive_post_reply(struct net_device *dev,
 					    priv->RcvCtl[ctx].len,
 					    PCI_DMA_FROMDEVICE);
 
-		memcpy(skb_put(skb, len), old_skb->data, len);
+		skb_copy_bits(old_skb, 0, skb_put(skb, len), len);
 
 		pci_dma_sync_single_for_device(mpt_dev->pcidev,
 					       priv->RcvCtl[ctx].dma,
diff --git a/drivers/net/3c505.c b/drivers/net/3c505.c
index c693b5a..ca3baf6 100644
--- a/drivers/net/3c505.c
+++ b/drivers/net/3c505.c
@@ -1025,7 +1025,7 @@ static int send_packet(struct net_device *dev, struct sk_buff *skb)
 	adapter->current_dma.start_time = jiffies;
 
 	if ((unsigned long)(skb->data + nlen) >= MAX_DMA_ADDRESS || nlen != skb->len) {
-		memcpy(adapter->dma_buffer, skb->data, nlen);
+		skb_copy_bits(skb, 0, adapter->dma_buffer, nlen);
 		memset(adapter->dma_buffer+skb->len, 0, nlen-skb->len);
 		target = isa_virt_to_bus(adapter->dma_buffer);
 	}
diff --git a/drivers/net/3c523.c b/drivers/net/3c523.c
index 6b2036d..7e4392a 100644
--- a/drivers/net/3c523.c
+++ b/drivers/net/3c523.c
@@ -1145,7 +1145,7 @@ static int elmc_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 	if (len != skb->len)
 		memset((char *) p->xmit_cbuffs[p->xmit_count], 0, ETH_ZLEN);
-	memcpy((char *) p->xmit_cbuffs[p->xmit_count], (char *) (skb->data), skb->len);
+	skb_copy_bits(skb, 0, p->xmit_cbuffs[p->xmit_count], skb->len);
 
 #if (NUM_XMIT_BUFFS == 1)
 #ifdef NO_NOPCOMMANDS
diff --git a/drivers/net/7990.c b/drivers/net/7990.c
index c50264a..4861dcf 100644
--- a/drivers/net/7990.c
+++ b/drivers/net/7990.c
@@ -567,7 +567,7 @@ int lance_start_xmit (struct sk_buff *skb, struct net_device *dev)
 
     	if (skb->len < ETH_ZLEN)
     		memset((char *)&ib->tx_buf[entry][0], 0, ETH_ZLEN);
-        memcpy ((char *)&ib->tx_buf [entry][0], skb->data, skblen);
+        skb_copy_bits(skb, 0, &ib->tx_buf[entry][0], skblen);
 
         /* Now, give the packet to the lance */
         ib->btx_ring [entry].tmd1_bits = (LE_T1_POK|LE_T1_OWN);
diff --git a/drivers/net/a2065.c b/drivers/net/a2065.c
index b38fc65..3f7b896 100644
--- a/drivers/net/a2065.c
+++ b/drivers/net/a2065.c
@@ -598,7 +598,7 @@ static int lance_start_xmit (struct sk_buff *skb, struct net_device *dev)
 	ib->btx_ring [entry].length = (-len) | 0xf000;
 	ib->btx_ring [entry].misc = 0;
 
-	memcpy ((char *)&ib->tx_buf [entry][0], skb->data, skblen);
+	skb_copy_bits(skb, 0, &ib->tx_buf [entry][0], skblen);
 
 	/* Clear the slack of the packet, do I need this? */
 	if (len != skblen)
diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index f6a87bd..fe46e80 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -273,7 +273,8 @@ static int ack_tx(struct net_device *dev, int acked)
   /* skb_pull(ackskb, ARC_HDR_SIZE); */
 
 
-  memcpy(ackpkt, lp->outgoing.skb->data, ARC_HDR_SIZE+sizeof(struct arc_cap));
+  skb_copy_bits(lp->outgoing.skb, 0, ackpkt,
+		ARC_HDR_SIZE + sizeof(struct arc_cap));
   ackpkt->soft.cap.proto=0; /* using protocol 0 for acknowledge */
   ackpkt->soft.cap.mes.ack=acked;
 
diff --git a/drivers/net/atari_bionet.c b/drivers/net/atari_bionet.c
index f52e7f2..b27b763 100644
--- a/drivers/net/atari_bionet.c
+++ b/drivers/net/atari_bionet.c
@@ -453,7 +453,7 @@ bionet_send_packet(struct sk_buff *skb, struct net_device *dev) {
 		stdma_lock(bionet_intr, NULL);
 		local_irq_restore(flags);
 		if( !STRAM_ADDR(buf+length-1) ) {
-			memcpy(nic_packet->buffer, skb->data, length);
+			skb_copy_bits(skb, 0, nic_packet->buffer, length);
 			buf = (unsigned long)&((struct nic_pkt_s *)phys_nic_packet)->buffer;
 		}
 
diff --git a/drivers/net/atari_pamsnet.c b/drivers/net/atari_pamsnet.c
index 3b54361..40d3bf1 100644
--- a/drivers/net/atari_pamsnet.c
+++ b/drivers/net/atari_pamsnet.c
@@ -717,7 +717,7 @@ pamsnet_send_packet(struct sk_buff *skb, struct net_device *dev) {
 
 		local_irq_restore(flags);
 		if( !STRAM_ADDR(buf+length-1) ) {
-			memcpy(nic_packet->buffer, skb->data, length);
+			skb_copy_bits(skb, 0, nic_packet->buffer, length);
 			buf = (unsigned long)phys_nic_packet;
 		}
 
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 97b55f2..d44eaed 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -1125,7 +1125,7 @@ static int au1000_tx(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	pDB = aup->tx_db_inuse[aup->tx_head];
-	memcpy((void *)pDB->vaddr, skb->data, skb->len);
+	skb_copy_bits(skb, 0, pDB->vaddr, skb->len);
 	if (skb->len < ETH_ZLEN) {
 		for (i=skb->len; i<ETH_ZLEN; i++) {
 			((char *)pDB->vaddr)[i] = 0;
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 6a86693..9d8ff37 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -828,8 +828,7 @@ static int b44_rx(struct b44 *bp, int budget)
 			skb_reserve(copy_skb, 2);
 			skb_put(copy_skb, len);
 			/* DMA sync done above, copy just the actual packet */
-			memcpy(copy_skb->data, skb->data+bp->rx_offset, len);
-
+			skb_copy_bits(skb, bp->rx_offset, copy_skb->data, len);
 			skb = copy_skb;
 		}
 		skb->ip_summed = CHECKSUM_NONE;
@@ -1006,7 +1005,7 @@ static int b44_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			goto err_out;
 		}
 
-		memcpy(skb_put(bounce_skb, len), skb->data, skb->len);
+		skb_copy_bits(skb, 0, skb_put(bounce_skb, len), skb->len);
 		dev_kfree_skb_any(skb);
 		skb = bounce_skb;
 	}
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 5658b46..09bc42e 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1884,10 +1884,8 @@ bnx2_rx_int(struct bnx2 *bp, int budget)
 				goto reuse_rx;
 
 			/* aligned copy */
-			memcpy(new_skb->data,
-				skb->data + bp->rx_offset - 2,
-				len + 2);
-
+			skb_copy_bits(skb, bp->rx_offset - 2,
+				      new_skb->data, len + 2);
 			skb_reserve(new_skb, 2);
 			skb_put(new_skb, len);
 
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index bd3ab64..0e996cf 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -2846,8 +2846,8 @@ static inline int cas_xmit_tx_ringN(struct cas *cp, int ring,
 			      ctrl | TX_DESC_SOF, 0);
 		entry = TX_DESC_NEXT(ring, entry);
 
-		memcpy(tx_tiny_buf(cp, ring, entry), skb->data +
-		       len - tabort, tabort);
+		skb_copy_bits(skb, len - tabort,
+			      tx_tiny_buf(cp, ring, entry), tabort);
 		mapping = tx_tiny_map(cp, ring, entry, tentry);
 		cas_write_txd(cp, ring, entry, mapping, tabort, ctrl,
 			      (nr_frags == 0));
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index 43e92f9..dd0d239 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1062,7 +1062,7 @@ static inline struct sk_buff *get_packet(struct pci_dev *pdev,
 					    pci_unmap_addr(ce, dma_addr),
 					    pci_unmap_len(ce, dma_len),
 					    PCI_DMA_FROMDEVICE);
-		memcpy(skb->data, ce->skb->data, len);
+		skb_copy_bits(ce->skb, 0, skb->data, len);
 		pci_dma_sync_single_for_device(pdev,
 					       pci_unmap_addr(ce, dma_addr),
 					       pci_unmap_len(ce, dma_len),
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index c5f8402..e266112 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -912,10 +912,7 @@ static void write_tx_pkt_wr(struct adapter *adap, struct sk_buff *skb,
 
 		if (skb->len <= WR_LEN - sizeof(*cpl)) {
 			q->sdesc[pidx].skb = NULL;
-			if (!skb->data_len)
-				memcpy(&d->flit[2], skb->data, skb->len);
-			else
-				skb_copy_bits(skb, 0, &d->flit[2], skb->len);
+			skb_copy_bits(skb, 0, &d->flit[2], skb->len);
 
 			flits = (skb->len + 7) / 8 + 2;
 			cpl->wr.wr_hi = htonl(V_WR_BCNTLFLT(skb->len & 7) |
@@ -1771,7 +1768,7 @@ static struct sk_buff *get_packet(struct adapter *adap, struct sge_fl *fl,
 			__skb_put(skb, len);
 			pci_dma_sync_single_for_cpu(adap->pdev, mapping, len,
 						    PCI_DMA_FROMDEVICE);
-			memcpy(skb->data, sd->t.skb->data, len);
+			skb_copy_bits(sd->t.skb, 0, skb->data, len);
 			pci_dma_sync_single_for_device(adap->pdev, mapping, len,
 						       PCI_DMA_FROMDEVICE);
 		} else if (!drop_thres)
diff --git a/drivers/net/dgrs.c b/drivers/net/dgrs.c
index d223c38..0bda462 100644
--- a/drivers/net/dgrs.c
+++ b/drivers/net/dgrs.c
@@ -741,7 +741,7 @@ static int dgrs_start_xmit(struct sk_buff *skb, struct net_device *devN)
 		}
 
 		amt = min_t(unsigned int, len, rbdp->size - count);
-		memcpy( (char *) S2H(rbdp->buf) + count, skb->data + i, amt);
+		skb_copy_bits(skb, i, S2H(rbdp->buf) + count, amt);
 		i += amt;
 		count += amt;
 		len -= amt;
diff --git a/drivers/net/eepro100.c b/drivers/net/eepro100.c
index db658bc..24873f4 100644
--- a/drivers/net/eepro100.c
+++ b/drivers/net/eepro100.c
@@ -1804,8 +1804,8 @@ speedo_rx(struct net_device *dev)
 				eth_copy_and_sum(skb, sp->rx_skbuff[entry]->data, pkt_len, 0);
 				skb_put(skb, pkt_len);
 #else
-				memcpy(skb_put(skb, pkt_len), sp->rx_skbuff[entry]->data,
-					   pkt_len);
+				skb_copy_bits(sp->rx_skbuff[entry], 0,
+					      skb_put(skb, pkt_len), pkt_len);
 #endif
 				pci_dma_sync_single_for_device(sp->pdev, sp->rx_ring_dma[entry],
 											   sizeof(struct RxFD) + pkt_len,
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 63732d2..629385d 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -1306,7 +1306,7 @@ static void write_swqe2_TSO(struct sk_buff *skb,
 
 	if (skb_data_size >= headersize) {
 		/* copy immediate data */
-		memcpy(imm_data, skb->data, headersize);
+		skb_copy_bits(skb, 0, imm_data, headersize);
 		swqe->immediate_data_length = headersize;
 
 		if (skb_data_size > headersize) {
@@ -1337,7 +1337,7 @@ static void write_swqe2_nonTSO(struct sk_buff *skb,
 	 */
 	if (skb_data_size >= SWQE2_MAX_IMM) {
 		/* copy immediate data */
-		memcpy(imm_data, skb->data, SWQE2_MAX_IMM);
+		skb_copy_bits(skb, 0, imm_data, SWQE2_MAX_IMM);
 
 		swqe->immediate_data_length = SWQE2_MAX_IMM;
 
@@ -1350,7 +1350,7 @@ static void write_swqe2_nonTSO(struct sk_buff *skb,
 			swqe->descriptors++;
 		}
 	} else {
-		memcpy(imm_data, skb->data, skb_data_size);
+		skb_copy_bits(skb, 0, imm_data, skb_data_size);
 		swqe->immediate_data_length = skb_data_size;
 	}
 }
@@ -1772,10 +1772,10 @@ static void ehea_xmit3(struct sk_buff *skb, struct net_device *dev,
 	/* copy (immediate) data */
 	if (nfrags == 0) {
 		/* data is in a single piece */
-		memcpy(imm_data, skb->data, skb->len);
+		skb_copy_bits(skb, 0, imm_data, skb->len);
 	} else {
 		/* first copy data from the skb->data buffer ... */
-		memcpy(imm_data, skb->data, skb->len - skb->data_len);
+		skb_copy_bits(skb, 0, imm_data, skb->len - skb->data_len);
 		imm_data += skb->len - skb->data_len;
 
 		/* ... then copy data from the fragments */
diff --git a/drivers/net/fec_8xx/fec_main.c b/drivers/net/fec_8xx/fec_main.c
index 698dba8..1c55f91 100644
--- a/drivers/net/fec_8xx/fec_main.c
+++ b/drivers/net/fec_8xx/fec_main.c
@@ -551,7 +551,8 @@ static int fec_enet_rx_common(struct net_device *dev, int *budget)
 				skbn = dev_alloc_skb(pkt_len + 2);
 				if (skbn != NULL) {
 					skb_reserve(skbn, 2);	/* align IP header */
-					memcpy(skbn->data, skb->data, pkt_len);
+					skb_copy_bits(skb, 0,
+						      skbn->data, pkt_len);
 					/* swap */
 					skbt = skb;
 					skb = skbn;
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 9f6ef31..1eee68e 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -160,7 +160,8 @@ static int fs_enet_rx_napi(struct net_device *dev, int *budget)
 				skbn = dev_alloc_skb(pkt_len + 2);
 				if (skbn != NULL) {
 					skb_reserve(skbn, 2);	/* align IP header */
-					memcpy(skbn->data, skb->data, pkt_len);
+					skb_copy_bits(skb, 0,
+						      skbn->data, pkt_len);
 					/* swap */
 					skbt = skb;
 					skb = skbn;
@@ -293,7 +294,8 @@ static int fs_enet_rx_non_napi(struct net_device *dev)
 				skbn = dev_alloc_skb(pkt_len + 2);
 				if (skbn != NULL) {
 					skb_reserve(skbn, 2);	/* align IP header */
-					memcpy(skbn->data, skb->data, pkt_len);
+					skb_copy_bits(skb, 0,
+						      skbn->data, pkt_len);
 					/* swap */
 					skbt = skb;
 					skb = skbn;
diff --git a/drivers/net/hamradio/dmascc.c b/drivers/net/hamradio/dmascc.c
index 0fbb414..bd797ca 100644
--- a/drivers/net/hamradio/dmascc.c
+++ b/drivers/net/hamradio/dmascc.c
@@ -930,7 +930,7 @@ static int scc_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 	/* Transfer data to DMA buffer */
 	i = priv->tx_head;
-	memcpy(priv->tx_buf[i], skb->data + 1, skb->len - 1);
+	skb_copy_bits(skb, 1, priv->tx_buf[i], skb->len - 1);
 	priv->tx_len[i] = skb->len - 1;
 
 	/* Clear interrupts while we touch our circular buffers */
diff --git a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
index f5a17ad..f667efe 100644
--- a/drivers/net/hamradio/hdlcdrv.c
+++ b/drivers/net/hamradio/hdlcdrv.c
@@ -317,7 +317,7 @@ void hdlcdrv_transmitter(struct net_device *dev, struct hdlcdrv_state *s)
 				dev_kfree_skb_irq(skb);
 				break;
 			}
-			memcpy(s->hdlctx.buffer, skb->data+1, pkt_len);
+			skb_copy_bits(skb, 1, s->hdlctx.buffer, pkt_len);
 			dev_kfree_skb_irq(skb);
 			s->hdlctx.bp = s->hdlctx.buffer;
 			append_crc_ccitt(s->hdlctx.buffer, pkt_len);
diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index ee3ea4f..05f971a 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -638,7 +638,7 @@ static void yam_tx_byte(struct net_device *dev, struct yam_port *yp)
         			dev_kfree_skb_any(skb);
 				break;
 			}
-			memcpy(yp->tx_buf, skb->data + 1, yp->tx_len);
+			skb_copy_bits(skb->data, 1, yp->tx_buf, yp->tx_len);
 			dev_kfree_skb_any(skb);
 			yp->tx_count = 0;
 			yp->tx_crcl = 0x21;
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index bc62e77..686b5c9 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -1443,7 +1443,7 @@ static int ioc3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (len <= 104) {
 		/* Short packet, let's copy it directly into the ring.  */
-		memcpy(desc->data, skb->data, skb->len);
+		skb_copy_bits(skb, 0, desc->data, skb->len);
 		if (len < ETH_ZLEN) {
 			/* Very short packet, pad with zeros at the end. */
 			memset(desc->data + len, 0, ETH_ZLEN - len);
diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index 0f10758..7b2c5ee 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -1472,9 +1472,8 @@ static int ali_ircc_fir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	self->stats.tx_bytes += skb->len;
 
-	memcpy(self->tx_fifo.queue[self->tx_fifo.free].start, skb->data, 
-	       skb->len);
-	
+	skb_copy_bits(skb, 0, self->tx_fifo.queue[self->tx_fifo.free].start,
+		      skb->len);
 	self->tx_fifo.len++;
 	self->tx_fifo.free++;
 
diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index 27afd0f..6adb7ae 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -526,7 +526,7 @@ static int au1k_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 	
 	if (aup->speed == 4000000) {
 		/* FIR */
-		memcpy((void *)pDB->vaddr, skb->data, skb->len);
+		skb_copy_bits(skb, 0, pDB->vaddr, skb->len);
 		ptxd->count_0 = skb->len & 0xff;
 		ptxd->count_1 = (skb->len >> 8) & 0xff;
 
diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index ddfa6c3..1a9d574 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -1119,7 +1119,7 @@ dumpbufs(skb->data,skb->len,'>');
   else
     {
       len = skb->len;
-      memcpy (self->tx_bufs[self->txs], skb->data, len);
+      skb_copy_bits(skb, 0, self->tx_bufs[self->txs], len);
     }
   self->ring->tx[self->txs].len = len & 0x0fff;
 
diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index cd8decb..09d531b 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -441,7 +441,7 @@ static int irda_usb_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 		goto drop;
 	}
 
-	memcpy(self->tx_buff + self->header_length, skb->data, skb->len);
+	skb_copy_bits(skb, 0, self->tx_buff + self->header_length, skb->len);
 
 	/* Change setting for next frame */
 	if (self->capability & IUC_STIR421X) {
@@ -902,7 +902,7 @@ static void irda_usb_receive(struct urb *urb)
 
 	if(docopy) {
 		/* Copy packet, so we can recycle the original */
-		memcpy(newskb->data, skb->data, urb->actual_length);
+		skb_copy_bits(skb, 0, newskb->data, urb->actual_length);
 		/* Deliver this new skb */
 		dataskb = newskb;
 		/* And hook the old skb to the URB
diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
index 3ff1f4b..a066042 100644
--- a/drivers/net/irda/mcs7780.c
+++ b/drivers/net/irda/mcs7780.c
@@ -353,7 +353,7 @@ static unsigned mcs_wrap_fir_skb(const struct sk_buff *skb, __u8 *buf)
 	buf[0] = len & 0xff;
 	buf[1] = (len >> 8) & 0xff;
 	/* copy the data into the tx buffer. */
-	memcpy(buf+2, skb->data, skb->len);
+	skb_copy_bits(skb, 0, buf + 2, skb->len);
 	/* put the fcs in the last four bytes in little endian order. */
 	buf[len - 4] = fcs & 0xff;
 	buf[len - 3] = (fcs >> 8) & 0xff;
@@ -377,7 +377,7 @@ static unsigned mcs_wrap_mir_skb(const struct sk_buff *skb, __u8 *buf)
 	buf[0] = len & 0xff;
 	buf[1] = (len >> 8) & 0xff;
 	/* copy the data */
-	memcpy(buf+2, skb->data, skb->len);
+	skb_copy_bits(skb, 0, buf + 2, skb->len);
 	/* put the fcs in last two bytes in little endian order. */
 	buf[len - 2] = fcs & 0xff;
 	buf[len - 1] = (fcs >> 8) & 0xff;
diff --git a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
index 8ce7dad..ca14b27 100644
--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -1466,9 +1466,8 @@ static int nsc_ircc_hard_xmit_fir(struct sk_buff *skb, struct net_device *dev)
 
 	self->stats.tx_bytes += skb->len;
 
-	memcpy(self->tx_fifo.queue[self->tx_fifo.free].start, skb->data, 
-	       skb->len);
-	
+	skb_copy_bits(skb, 0, self->tx_fifo.queue[self->tx_fifo.free].start,
+		      skb->len);
 	self->tx_fifo.len++;
 	self->tx_fifo.free++;
 
diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/net/irda/pxaficp_ir.c
index 1e9d474..186f5df 100644
--- a/drivers/net/irda/pxaficp_ir.c
+++ b/drivers/net/irda/pxaficp_ir.c
@@ -464,7 +464,7 @@ static int pxa_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 		unsigned long mtt = irda_get_mtt(skb);
 
 		si->dma_tx_buff_len = skb->len;
-		memcpy(si->dma_tx_buff, skb->data, skb->len);
+		skb_copy_bits(skb, 0, si->dma_tx_buff, skb->len);
 
 		if (mtt)
 			while ((unsigned)(OSCR - si->last_oscr)/4 < mtt)
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index e845386..3399532 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -1162,7 +1162,7 @@ static int smsc_ircc_hard_xmit_fir(struct sk_buff *skb, struct net_device *dev)
 		self->new_speed = speed;
 	}
 
-	memcpy(self->tx_buff.head, skb->data, skb->len);
+	skb_copy_bits(skb, 0, self->tx_buff.head, skb->len);
 
 	self->tx_buff.len = skb->len;
 	self->tx_buff.data = self->tx_buff.head;
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index 5ff4163..aaa1802 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -925,8 +925,8 @@ static int via_ircc_hard_xmit_fir(struct sk_buff *skb,
 
 	self->tx_fifo.tail += skb->len;
 	self->stats.tx_bytes += skb->len;
-	memcpy(self->tx_fifo.queue[self->tx_fifo.free].start, skb->data,
-	       skb->len);
+	skb_copy_bits(skb, 0,
+		      self->tx_fifo.queue[self->tx_fifo.free].start, skb->len);
 	self->tx_fifo.len++;
 	self->tx_fifo.free++;
 //F01   if (self->tx_fifo.len == 1) {
diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index 79b407f..c657554 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -993,7 +993,7 @@ static int vlsi_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 			goto drop;
 		}
 		else
-			memcpy(rd->buf, skb->data, len);
+			skb_copy_bits(skb, 0, rd->buf, len);
 	}
 
 	rd->skb = skb;			/* remember skb for tx-complete stats */
diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index bee4451..28837c6 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -529,7 +529,7 @@ int w83977af_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Decide if we should use PIO or DMA transfer */
 	if (self->io.speed > PIO_MAX_SPEED) {
 		self->tx_buff.data = self->tx_buff.head;
-		memcpy(self->tx_buff.data, skb->data, skb->len);
+		skb_copy_bits(skb, 0, self->tx_buff.data, skb->len);
 		self->tx_buff.len = skb->len;
 		
 		mtt = irda_get_mtt(skb);
diff --git a/drivers/net/lance.c b/drivers/net/lance.c
index 11cbcb9..f3f3fad 100644
--- a/drivers/net/lance.c
+++ b/drivers/net/lance.c
@@ -988,7 +988,7 @@ static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (lance_debug > 5)
 			printk("%s: bouncing a high-memory packet (%#x).\n",
 				   dev->name, (u32)isa_virt_to_bus(skb->data));
-		memcpy(&lp->tx_bounce_buffs[entry], skb->data, skb->len);
+		skb_copy_bits(skb, 0, &lp->tx_bounce_buffs[entry], skb->len);
 		lp->tx_ring[entry].base =
 			((u32)isa_virt_to_bus((lp->tx_bounce_buffs + entry)) & 0xffffff) | 0x83000000;
 		dev_kfree_skb(skb);
diff --git a/drivers/net/macmace.c b/drivers/net/macmace.c
index 8c07ffc..6533af8 100644
--- a/drivers/net/macmace.c
+++ b/drivers/net/macmace.c
@@ -420,8 +420,7 @@ static int mace_xmit_start(struct sk_buff *skb, struct net_device *dev)
 	mp->stats.tx_bytes += skb->len;
 
 	/* We need to copy into our xmit buffer to take care of alignment and caching issues */
-
-	memcpy((void *) mp->tx_ring, skb->data, skb->len);
+	skb_copy_bits(skb, 0, mp->tx_ring, skb->len);
 
 	/* load the Tx DMA and fire it off */
 
diff --git a/drivers/net/meth.c b/drivers/net/meth.c
index fafe678..d6014c8 100644
--- a/drivers/net/meth.c
+++ b/drivers/net/meth.c
@@ -608,7 +608,7 @@ static void meth_tx_short_prepare(struct meth_private *priv,
 
 	desc->header.raw = METH_TX_CMD_INT_EN | (len-1) | ((128-len) << 16);
 	/* maybe I should set whole thing to 0 first... */
-	memcpy(desc->data.dt + (120 - len), skb->data, skb->len);
+	skb_copy_bits(skb, 0, desc->data.dt + (120 - len), skb->len);
 	if (skb->len < len)
 		memset(desc->data.dt + 120 - len + skb->len, 0, len-skb->len);
 }
@@ -626,8 +626,8 @@ static void meth_tx_1page_prepare(struct meth_private *priv,
 
 	/* unaligned part */
 	if (unaligned_len) {
-		memcpy(desc->data.dt + (120 - unaligned_len),
-		       skb->data, unaligned_len);
+		skb_copy_bits(skb, 0, desc->data.dt + (120 - unaligned_len),
+			      unaligned_len);
 		desc->header.raw |= (128 - unaligned_len) << 16;
 	}
 
@@ -652,8 +652,8 @@ static void meth_tx_2page_prepare(struct meth_private *priv,
 	desc->header.raw = METH_TX_CMD_INT_EN | TX_CATBUF1 | TX_CATBUF2| (skb->len - 1);
 	/* unaligned part */
 	if (unaligned_len){
-		memcpy(desc->data.dt + (120 - unaligned_len),
-		       skb->data, unaligned_len);
+		skb_copy_bits(skb, 0, desc->data.dt + (120 - unaligned_len),
+			      unaligned_len);
 		desc->header.raw |= (128 - unaligned_len) << 16;
 	}
 
diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index e1f16fb..1f3316b 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -502,7 +502,7 @@ static void myri_rx(struct myri_eth *mp, struct net_device *dev)
 			copy_skb->dev = dev;
 			DRX(("resv_and_put "));
 			skb_put(copy_skb, len);
-			memcpy(copy_skb->data, skb->data, len);
+			skb_copy_bits(skb, 0, copy_skb->data, len);
 
 			/* Reuse original ring buffer. */
 			DRX(("reuse "));
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index b488e94..30a55dd 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -920,8 +920,8 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 			/* copy the next 64 bytes - should be enough except
 			 * for pathological case
 			 */
-			memcpy((void *)hwdesc, (void *)(skb->data) +
-			       first_hdr_len, hdr_len - first_hdr_len);
+			skb_copy_bits(skb, first_hdr_len, hwdesc,
+				      hdr_len - first_hdr_len);
 			producer = get_next_index(producer, max_tx_desc_count);
 		}
 	}
diff --git a/drivers/net/ni52.c b/drivers/net/ni52.c
index 70b6812..5bf54de 100644
--- a/drivers/net/ni52.c
+++ b/drivers/net/ni52.c
@@ -1182,7 +1182,7 @@ static int ni52_send_packet(struct sk_buff *skb, struct net_device *dev)
 	else
 #endif
 	{
-		memcpy((char *)p->xmit_cbuffs[p->xmit_count],(char *)(skb->data),skb->len);
+		skb_copy_bits(skb, 0, p->xmit_cbuffs[p->xmit_count], skb->len);
 		len = skb->len;
 		if (len < ETH_ZLEN) {
 			len = ETH_ZLEN;
diff --git a/drivers/net/ni65.c b/drivers/net/ni65.c
index 782201d..6a1cb38 100644
--- a/drivers/net/ni65.c
+++ b/drivers/net/ni65.c
@@ -1176,8 +1176,9 @@ static int ni65_send_packet(struct sk_buff *skb, struct net_device *dev)
 		if( (unsigned long) (skb->data + skb->len) > 0x1000000) {
 #endif
 
-			memcpy((char *) p->tmdbounce[p->tmdbouncenum] ,(char *)skb->data,
-							 (skb->len > T_BUF_SIZE) ? T_BUF_SIZE : skb->len);
+			skb_copy_bits(skb, 0, p->tmdbounce[p->tmdbouncenum],
+				      skb->len > T_BUF_SIZE ? T_BUF_SIZE :
+							      skb->len);
 			if (len > skb->len)
 				memset((char *)p->tmdbounce[p->tmdbouncenum]+skb->len, 0, len-skb->len);
 			dev_kfree_skb (skb);
diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index 06fc283..f628b3a 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -1344,7 +1344,7 @@ static int netdrv_start_xmit (struct sk_buff *skb, struct net_device *dev)
 
 	tp->tx_info[entry].skb = skb;
 	/* tp->tx_info[entry].mapping = 0; */
-	memcpy (tp->tx_buf[entry], skb->data, skb->len);
+	skb_copy_bits(skb, 0, tp->tx_buf[entry], skb->len);
 
 	/* Note: the chip doesn't have auto-pad! */
 	NETDRV_W32 (TxStatus0 + (entry * sizeof(u32)),
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index fabbe95..0ba765a 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -1136,7 +1136,7 @@ static int ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		ei_block_output(dev, length, skb->data, output_page);
 	else {
 		memset(packet, 0, ETH_ZLEN);
-		memcpy(packet, skb->data, skb->len);
+		skb_copy_bits(skb, 0, packet, skb->len);
 		ei_block_output(dev, length, packet, output_page);
 	}
 	
diff --git a/drivers/net/ppp_synctty.c b/drivers/net/ppp_synctty.c
index b6f0e9a..6aa9021 100644
--- a/drivers/net/ppp_synctty.c
+++ b/drivers/net/ppp_synctty.c
@@ -594,7 +594,8 @@ ppp_sync_txmunge(struct syncppp *ap, struct sk_buff *skb)
 				return NULL;
 			}
 			skb_reserve(npkt,2);
-			memcpy(skb_put(npkt,skb->len), skb->data, skb->len);
+			skb_copy_bits(skb, 0,
+				      skb_put(npkt, skb->len), skb->len);
 			kfree_skb(skb);
 			skb = npkt;
 		}
diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index e947906..6f01a9a 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -869,7 +869,7 @@ static int __pppoe_xmit(struct sock *sk, struct sk_buff *skb)
 			goto abort;
 
 		skb_reserve(skb2, dev->hard_header_len + sizeof(struct pppoe_hdr));
-		memcpy(skb_put(skb2, skb->len), skb->data, skb->len);
+		skb_copy_bits(skb, 0, skb_put(skb2, skb->len), skb->len);
 	} else {
 		/* Make a clone so as to not disturb the original skb,
 		 * give dev_queue_xmit something it can free.
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 9b416bd..cb07529 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -1909,7 +1909,7 @@ static void ql_process_macip_rx_intr(struct ql3_adapter *qdev,
 		 * Copy the ethhdr from first buffer to second. This
 		 * is necessary for 3022 IP completions.
 		 */
-		memcpy(skb_push(skb2, size), skb1->data + VLAN_ID_LEN, size);
+		skb_copy_bits(skb1, VLAN_ID_LEN, skb_push(skb2, size), size);
 	} else {
 		u16 checksum = le16_to_cpu(ib_ip_rsp_ptr->checksum);
 		if (checksum & 
diff --git a/drivers/net/rrunner.c b/drivers/net/rrunner.c
index 3a4fce3..2e0ee0b 100644
--- a/drivers/net/rrunner.c
+++ b/drivers/net/rrunner.c
@@ -1451,7 +1451,7 @@ static int rr_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 		skb_reserve(new_skb, 8);
 		skb_put(new_skb, len);
-		memcpy(new_skb->data, skb->data, len);
+		skb_copy_bits(skb, 0, new_skb->data, len);
 		dev_kfree_skb(skb);
 		skb = new_skb;
 	}
diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
index 5a89191..6546657 100644
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -534,7 +534,7 @@ static int sgiseeq_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 *    entry and the HPC got to the end of the chain before we
 	 *    added this new entry and restarted it.
 	 */
-	memcpy((char *)(long)td->buf_vaddr, skb->data, skblen);
+	skb_copy_bits(skb, 0, (char *)(long)td->buf_vaddr, skblen);
 	if (len != skblen)
 		memset((char *)(long)td->buf_vaddr + skb->len, 0, len-skblen);
 	td->tdma.cntinfo = (len & HPCDMA_BCNT) |
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 13ffaee..84e460f 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -2919,7 +2919,7 @@ static struct sk_buff *skge_rx_get(struct net_device *dev,
 		pci_dma_sync_single_for_cpu(skge->hw->pdev,
 					    pci_unmap_addr(e, mapaddr),
 					    len, PCI_DMA_FROMDEVICE);
-		memcpy(skb->data, e->skb->data, len);
+		skb_copy_bits(e->skb, 0, skb->data, len);
 		pci_dma_sync_single_for_device(skge->hw->pdev,
 					       pci_unmap_addr(e, mapaddr),
 					       len, PCI_DMA_FROMDEVICE);
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index f6b771b..4a688f6 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1959,7 +1959,7 @@ static struct sk_buff *receive_copy(struct sky2_port *sky2,
 		skb_reserve(skb, 2);
 		pci_dma_sync_single_for_cpu(sky2->hw->pdev, re->data_addr,
 					    length, PCI_DMA_FROMDEVICE);
-		memcpy(skb->data, re->skb->data, length);
+		skb_copy_bits(re->skb, 0, skb->data, length);
 		skb->ip_summed = re->skb->ip_summed;
 		skb->csum = re->skb->csum;
 		pci_dma_sync_single_for_device(sky2->hw->pdev, re->data_addr,
diff --git a/drivers/net/sun3_82586.c b/drivers/net/sun3_82586.c
index 5bcc749..be3e666 100644
--- a/drivers/net/sun3_82586.c
+++ b/drivers/net/sun3_82586.c
@@ -1026,7 +1026,7 @@ static int sun3_82586_send_packet(struct sk_buff *skb, struct net_device *dev)
 			memset((char *)p->xmit_cbuffs[p->xmit_count], 0, ETH_ZLEN);
 			len = ETH_ZLEN;
 		}
-		memcpy((char *)p->xmit_cbuffs[p->xmit_count],(char *)(skb->data),skb->len);
+		skb_copy_bits(skb, 0, p->xmit_cbuffs[p->xmit_count], skb->len);
 
 #if (NUM_XMIT_BUFFS == 1)
 #	ifdef NO_NOPCOMMANDS
diff --git a/drivers/net/sun3lance.c b/drivers/net/sun3lance.c
index 788b7eb..ab96c05 100644
--- a/drivers/net/sun3lance.c
+++ b/drivers/net/sun3lance.c
@@ -615,7 +615,7 @@ static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
 	head->length = (-len) | 0xf000;
 	head->misc = 0;
 
-	memcpy( PKTBUF_ADDR(head), (void *)skb->data, skb->len );
+	skb_copy_bits(skb, 0, PKTBUF_ADDR(head), skb->len);
 	if (len != skb->len)
 		memset(PKTBUF_ADDR(head) + skb->len, 0, len-skb->len);
 
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index ddeb2db..70c8c56 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -848,7 +848,7 @@ static int gem_rx(struct gem *gp, int work_to_do)
 			skb_reserve(copy_skb, 2);
 			skb_put(copy_skb, len);
 			pci_dma_sync_single_for_cpu(gp->pdev, dma_addr, len, PCI_DMA_FROMDEVICE);
-			memcpy(copy_skb->data, skb->data, len);
+			skb_copy_bits(skb, 0, copy_skb->data, len);
 			pci_dma_sync_single_for_device(gp->pdev, dma_addr, len, PCI_DMA_FROMDEVICE);
 
 			/* We'll reuse the original ring buffer. */
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index 9643fdd..d53a158 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -2061,7 +2061,7 @@ static void happy_meal_rx(struct happy_meal *hp, struct net_device *dev)
 			skb_reserve(copy_skb, 2);
 			skb_put(copy_skb, len);
 			hme_dma_sync_for_cpu(hp, dma_addr, len, DMA_FROMDEVICE);
-			memcpy(copy_skb->data, skb->data, len);
+			skb_copy_bits(skb, 0, copy_skb->data, len);
 			hme_dma_sync_for_device(hp, dma_addr, len, DMA_FROMDEVICE);
 
 			/* Reuse original ring buffer. */
diff --git a/drivers/net/sunlance.c b/drivers/net/sunlance.c
index 79ef2ca..5ad1271 100644
--- a/drivers/net/sunlance.c
+++ b/drivers/net/sunlance.c
@@ -1143,7 +1143,7 @@ static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		struct lance_init_block *ib = lp->init_block_mem;
 		ib->btx_ring [entry].length = (-len) | 0xf000;
 		ib->btx_ring [entry].misc = 0;
-		memcpy((char *)&ib->tx_buf [entry][0], skb->data, skblen);
+		skb_copy_bits(skb, 0, &ib->tx_buf [entry][0], skblen);
 		if (len != skblen)
 			memset((char *) &ib->tx_buf [entry][skblen], 0, len - skblen);
 		ib->btx_ring [entry].tmd1_bits = (LE_T1_POK | LE_T1_OWN);
diff --git a/drivers/net/sunqe.c b/drivers/net/sunqe.c
index 3998c5b..39af1d0 100644
--- a/drivers/net/sunqe.c
+++ b/drivers/net/sunqe.c
@@ -592,7 +592,7 @@ static int qe_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Avoid a race... */
 	qep->qe_block->qe_txd[entry].tx_flags = TXD_UPDATE;
 
-	memcpy(txbuf, skb->data, len);
+	skb_copy_bits(skb, 0, txbuf, len);
 
 	qep->qe_block->qe_txd[entry].tx_addr = txbuf_dvma;
 	qep->qe_block->qe_txd[entry].tx_flags =
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index f4399fa..5794617 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3350,7 +3350,7 @@ static int tg3_rx(struct tg3 *tp, int budget)
 			skb_reserve(copy_skb, 2);
 			skb_put(copy_skb, len);
 			pci_dma_sync_single_for_cpu(tp->pdev, dma_addr, len, PCI_DMA_FROMDEVICE);
-			memcpy(copy_skb->data, skb->data, len);
+			skb_copy_bits(skb, 0, copy_skb->data, len);
 			pci_dma_sync_single_for_device(tp->pdev, dma_addr, len, PCI_DMA_FROMDEVICE);
 
 			/* We'll reuse the original ring buffer. */
diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index 2ede3f5..fae267d 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -1112,7 +1112,7 @@ static int TLan_StartTx( struct sk_buff *skb, struct net_device *dev )
 
 	if ( bbuf ) {
 		tail_buffer = priv->txBuffer + ( priv->txTail * TLAN_MAX_FRAME_SIZE );
-		memcpy( tail_buffer, skb->data, skb->len );
+		skb_copy_bits(skb, 0, tail_buffer, skb->len);
 	} else {
 		tail_list->buffer[0].address = pci_map_single(priv->pciDev, skb->data, skb->len, PCI_DMA_TODEVICE);
 		TLan_StoreSKB(tail_list, skb);
diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index d293423..1b29669 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -937,14 +937,16 @@ static void xl_rx(struct net_device *dev)
 				copy_len = xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfraglen & 0x7FFF ; 
 				frame_length -= copy_len ;  
 				pci_dma_sync_single_for_cpu(xl_priv->pdev,xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfragaddr,xl_priv->pkt_buf_sz,PCI_DMA_FROMDEVICE) ;
-				memcpy(skb_put(skb,copy_len), xl_priv->rx_ring_skb[xl_priv->rx_ring_tail]->data, copy_len) ; 
+				skb_copy_bits(xl_priv->rx_ring_skb[xl_priv->rx_ring_tail], 0,
+					      skb_put(skb,copy_len), copy_len) ; 
 				pci_dma_sync_single_for_device(xl_priv->pdev,xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfragaddr,xl_priv->pkt_buf_sz,PCI_DMA_FROMDEVICE) ;
 				adv_rx_ring(dev) ; 
 			} 
 
 			/* Now we have found the last fragment */
 			pci_dma_sync_single_for_cpu(xl_priv->pdev,xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfragaddr,xl_priv->pkt_buf_sz,PCI_DMA_FROMDEVICE) ;
-			memcpy(skb_put(skb,copy_len), xl_priv->rx_ring_skb[xl_priv->rx_ring_tail]->data, frame_length) ; 
+			skb_copy_bits(xl_priv->rx_ring_skb[xl_priv->rx_ring_tail], 0,
+				      skb_put(skb,copy_len), frame_length) ; 
 /*			memcpy(skb_put(skb,frame_length), bus_to_virt(xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfragaddr), frame_length) ; */
 			pci_dma_sync_single_for_device(xl_priv->pdev,xl_priv->xl_rx_ring[xl_priv->rx_ring_tail].upfragaddr,xl_priv->pkt_buf_sz,PCI_DMA_FROMDEVICE) ;
 			adv_rx_ring(dev) ; 
diff --git a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olympic.c
index a620658..52263b6 100644
--- a/drivers/net/tokenring/olympic.c
+++ b/drivers/net/tokenring/olympic.c
@@ -845,7 +845,9 @@ static void olympic_rx(struct net_device *dev)
 							pci_dma_sync_single_for_cpu(olympic_priv->pdev,
 								le32_to_cpu(olympic_priv->olympic_rx_ring[rx_ring_last_received].buffer),
 								olympic_priv->pkt_buf_sz,PCI_DMA_FROMDEVICE) ; 
-							memcpy(skb_put(skb,length-4),olympic_priv->rx_ring_skb[rx_ring_last_received]->data,length-4) ; 
+							skb_copy_bits(olympic_priv->rx_ring_skb[rx_ring_last_received], 0,
+								      skb_put(skb,length - 4),
+								      length - 4) ; 
 							pci_dma_sync_single_for_device(olympic_priv->pdev,
 								le32_to_cpu(olympic_priv->olympic_rx_ring[rx_ring_last_received].buffer),
 								olympic_priv->pkt_buf_sz,PCI_DMA_FROMDEVICE) ;
@@ -862,7 +864,9 @@ static void olympic_rx(struct net_device *dev)
 								olympic_priv->pkt_buf_sz,PCI_DMA_FROMDEVICE) ; 
 							rx_desc = &(olympic_priv->olympic_rx_ring[rx_ring_last_received]);
 							cpy_length = (i == 1 ? frag_len : le32_to_cpu(rx_desc->res_length)); 
-							memcpy(skb_put(skb, cpy_length), olympic_priv->rx_ring_skb[rx_ring_last_received]->data, cpy_length) ;
+							skb_copy_bits(olympic_priv->rx_ring_skb[rx_ring_last_received], 0,
+								      skb_put(skb, cpy_length),
+								      cpy_length);
 							pci_dma_sync_single_for_device(olympic_priv->pdev,
 								le32_to_cpu(olympic_priv->olympic_rx_ring[rx_ring_last_received].buffer),
 								olympic_priv->pkt_buf_sz,PCI_DMA_FROMDEVICE) ;
diff --git a/drivers/net/tokenring/tms380tr.c b/drivers/net/tokenring/tms380tr.c
index de6f727..d061907 100644
--- a/drivers/net/tokenring/tms380tr.c
+++ b/drivers/net/tokenring/tms380tr.c
@@ -644,7 +644,7 @@ static int tms380tr_hardware_send_packet(struct sk_buff *skb, struct net_device
 		dmabuf  = 0;
 		i 	= tp->TplFree->TPLIndex;
 		buf 	= tp->LocalTxBuffers[i];
-		memcpy(buf, skb->data, length);
+		skb_copy_bits(skb, 0, buf, length);
 		newbuf 	= ((char *)buf - (char *)tp) + tp->dmabuffer;
 	}
 	else {
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index 8a7effa..8832b56 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -449,8 +449,7 @@ static void de_rx (struct de_private *de)
 		} else {
 			pci_dma_sync_single_for_cpu(de->pdev, mapping, len, PCI_DMA_FROMDEVICE);
 			skb_reserve(copy_skb, RX_OFFSET);
-			memcpy(skb_put(copy_skb, len), skb->data, len);
-
+			skb_copy_bits(skb, 0, skb_put(copy_skb, len), len);
 			pci_dma_sync_single_for_device(de->pdev, mapping, len, PCI_DMA_FROMDEVICE);
 
 			/* We'll reuse the original ring buffer. */
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index a5e0237..4975c4e 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -682,7 +682,7 @@ static int dmfe_start_xmit(struct sk_buff *skb, struct DEVICE *dev)
 
 	/* transmit this packet */
 	txptr = db->tx_insert_ptr;
-	memcpy(txptr->tx_buf_ptr, skb->data, skb->len);
+	skb_copy_bits(skb, 0, txptr->tx_buf_ptr, skb->len);
 	txptr->tdes1 = cpu_to_le32(0xe1000000 | skb->len);
 
 	/* Point to next transmit free descriptor */
@@ -989,7 +989,9 @@ static void dmfe_rx_packet(struct DEVICE *dev, struct dmfe_board_info * db)
 						skb = newskb;
 						/* size less than COPY_SIZE, allocate a rxlen SKB */
 						skb_reserve(skb, 2); /* 16byte align */
-						memcpy(skb_put(skb, rxlen), rxptr->rx_skb_ptr->data, rxlen);
+						skb_copy_bits(rxptr->rx_skb_ptr, 0,
+							      skb_put(skb, rxlen),
+							      rxlen);
 						dmfe_reuse_skb(db, rxptr->rx_skb_ptr);
 					} else
 						skb_put(skb, rxlen);
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index e46f4cb..d712f06 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -583,7 +583,7 @@ static int uli526x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* transmit this packet */
 	txptr = db->tx_insert_ptr;
-	memcpy(txptr->tx_buf_ptr, skb->data, skb->len);
+	skb_copy_bits(skb, 0, txptr->tx_buf_ptr, skb->len);
 	txptr->tdes1 = cpu_to_le32(0xe1000000 | skb->len);
 
 	/* Point to next transmit free descriptor */
diff --git a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
index 1fe3734..1d9528f 100644
--- a/drivers/net/tulip/xircom_cb.c
+++ b/drivers/net/tulip/xircom_cb.c
@@ -411,9 +411,9 @@ static int xircom_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			   sometimes sends more than you ask it to. */
 
 			memset(&card->tx_buffer[bufferoffsets[desc]/4],0,1536);
-			memcpy(&(card->tx_buffer[bufferoffsets[desc]/4]),skb->data,skb->len);
-
-
+			skb_copy_bits(skb, 0,
+				      &(card->tx_buffer[bufferoffsets[desc] / 4]),
+				      skb->len);
 			/* FIXME: The specification tells us that the length we send HAS to be a multiple of
 			   4 bytes. */
 
diff --git a/drivers/net/tulip/xircom_tulip_cb.c b/drivers/net/tulip/xircom_tulip_cb.c
index 3f24c82..7d2848f 100644
--- a/drivers/net/tulip/xircom_tulip_cb.c
+++ b/drivers/net/tulip/xircom_tulip_cb.c
@@ -915,7 +915,8 @@ xircom_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	tp->tx_skbuff[entry] = skb;
 	if (tp->chip_id == X3201_3) {
-		memcpy(tp->tx_aligned_skbuff[entry]->data,skb->data,skb->len);
+		skb_copy_bits(skb, 0,
+			      tp->tx_aligned_skbuff[entry]->data, skb->len);
 		tp->tx_ring[entry].buffer1 = virt_to_bus(tp->tx_aligned_skbuff[entry]->data);
 	} else
 		tp->tx_ring[entry].buffer1 = virt_to_bus(skb->data);
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 288d855..6aa0d02 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -386,8 +386,8 @@ static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
 		 *   - we are multicast promiscous.
 		 *   - we belong to the multicast group.
 		 */
-		memcpy(addr, skb->data,
-		       min_t(size_t, sizeof addr, skb->len));
+		skb_copy_bits(skb, 0,
+			      addr, min_t(size_t, sizeof addr, skb->len));
 		bit_nr = ether_crc(sizeof addr, addr) >> 26;
 		if ((tun->if_flags & IFF_PROMISC) ||
 				memcmp(addr, tun->dev_addr, sizeof addr) == 0 ||
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 422eaf8..645baa9 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1339,7 +1339,7 @@ static inline int velocity_rx_copy(struct sk_buff **rx_skb, int pkt_size,
 			if (vptr->flags & VELOCITY_FLAGS_IP_ALIGN)
 				skb_reserve(new_skb, 2);
 
-			memcpy(new_skb->data, rx_skb[0]->data, pkt_size);
+			skb_copy_bits(rx_skb[0], 0, new_skb->data, pkt_size);
 			*rx_skb = new_skb;
 			ret = 0;
 		}
@@ -1927,7 +1927,7 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (pktlen < ETH_ZLEN) {
 		/* Cannot occur until ZC support */
 		pktlen = ETH_ZLEN;
-		memcpy(tdinfo->buf, skb->data, skb->len);
+		skb_copy_bits(skb, 0, tdinfo->buf, skb->len);
 		memset(tdinfo->buf + skb->len, 0, ETH_ZLEN - skb->len);
 		tdinfo->skb = skb;
 		tdinfo->skb_dma[0] = tdinfo->buf_dma;
@@ -1943,7 +1943,7 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 		int nfrags = skb_shinfo(skb)->nr_frags;
 		tdinfo->skb = skb;
 		if (nfrags > 6) {
-			memcpy(tdinfo->buf, skb->data, skb->len);
+			skb_copy_bits(skb, 0, tdinfo->buf, skb->len);
 			tdinfo->skb_dma[0] = tdinfo->buf_dma;
 			td_ptr->tdesc0.pktsize =
 			td_ptr->td_buf[0].pa_low = cpu_to_le32(tdinfo->skb_dma[0]);
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index a576113..d1061ce 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -1702,7 +1702,7 @@ static int lmc_rx (struct net_device *dev) /*fold00*/
             if(!nsb) {
                 goto give_it_anyways;
             }
-            memcpy(skb_put(nsb, len), skb->data, len);
+            skb_copy_bits(skb, 0, skb_put(nsb, len), len);
             
             nsb->protocol = lmc_proto_type(sc, skb);
             skb_reset_mac_header(nsb);
diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index edbc555..7ea7b94 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -1765,7 +1765,7 @@ cpc_trace(struct net_device *dev, struct sk_buff *skb_main, char rx_tx)
 	skb->data[7] = ']';
 	skb->data[8] = ':';
 	skb->data[9] = ' ';
-	memcpy(&skb->data[10], skb_main->data, skb_main->len);
+	skb_copy_bits(skb_main, 0, &skb->data[10], skb_main->len);
 
 	netif_rx(skb);
 }
diff --git a/drivers/net/wan/z85230.c b/drivers/net/wan/z85230.c
index 8b4540b..5b1730a 100644
--- a/drivers/net/wan/z85230.c
+++ b/drivers/net/wan/z85230.c
@@ -1782,7 +1782,7 @@ int z8530_queue_xmit(struct z8530_channel *c, struct sk_buff *skb)
 		 */
 		c->tx_next_ptr=c->tx_dma_buf[c->tx_dma_used];
 		c->tx_dma_used^=1;	/* Flip temp buffer */
-		memcpy(c->tx_next_ptr, skb->data, skb->len);
+		skb_copy_bits(skb, 0, c->tx_next_ptr, skb->len);
 	}
 	else
 		c->tx_next_ptr=skb->data;	
diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index 1c17cbe..968f88b 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -827,14 +827,14 @@ static int start_tx(struct sk_buff *skb, struct net_device *dev)
 	if (priv->wep_is_on)
 		frame_ctl |= IEEE80211_FCTL_PROTECTED;
 	if (priv->operating_mode == IW_MODE_ADHOC) {
-		memcpy(&header.addr1, skb->data, 6);
+		skb_copy_bits(skb, 0, &header.addr1, 6);
 		memcpy(&header.addr2, dev->dev_addr, 6);
 		memcpy(&header.addr3, priv->BSSID, 6);
 	} else {
 		frame_ctl |= IEEE80211_FCTL_TODS;
 		memcpy(&header.addr1, priv->CurrentBSSID, 6);
 		memcpy(&header.addr2, dev->dev_addr, 6);
-		memcpy(&header.addr3, skb->data, 6);
+		skb_copy_bits(skb, 0, &header.addr3, 6);
 	}
 
 	if (priv->use_wpa)
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_dma.c b/drivers/net/wireless/bcm43xx/bcm43xx_dma.c
index 6e0dc76..ff04513 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_dma.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_dma.c
@@ -998,7 +998,7 @@ static void dma_tx_fragment(struct bcm43xx_dmaring *ring,
 			assert(0);
 			return;
 		}
-		memcpy(skb_put(bounce_skb, skb->len), skb->data, skb->len);
+		skb_copy_bits(skb, 0, skb_put(bounce_skb, skb->len), skb->len);
 		dev_kfree_skb_any(skb);
 		skb = bounce_skb;
 	}
diff --git a/drivers/net/wireless/hostap/hostap_80211_rx.c b/drivers/net/wireless/hostap/hostap_80211_rx.c
index 35a3a50..2a770b9 100644
--- a/drivers/net/wireless/hostap/hostap_80211_rx.c
+++ b/drivers/net/wireless/hostap/hostap_80211_rx.c
@@ -933,12 +933,12 @@ void hostap_80211_rx(struct net_device *dev, struct sk_buff *skb,
 		if (frag == 0) {
 			/* copy first fragment (including full headers) into
 			 * beginning of the fragment cache skb */
-			memcpy(skb_put(frag_skb, flen), skb->data, flen);
+			skb_copy_bits(skb, 0, skb_put(frag_skb, flen), flen);
 		} else {
 			/* append frame payload to the end of the fragment
 			 * cache skb */
-			memcpy(skb_put(frag_skb, flen), skb->data + hdrlen,
-			       flen);
+			skb_copy_bits(skb, hdrlen,
+				      skb_put(frag_skb, flen), flen);
 		}
 		dev_kfree_skb(skb);
 		skb = NULL;
@@ -1044,8 +1044,7 @@ void hostap_80211_rx(struct net_device *dev, struct sk_buff *skb,
 	    skb->len >= ETH_HLEN + ETH_ALEN) {
 		/* Non-standard frame: get addr4 from its bogus location after
 		 * the payload */
-		memcpy(skb->data + ETH_ALEN,
-		       skb->data + skb->len - ETH_ALEN, ETH_ALEN);
+		skb_copy_bits(skb, skb->len - ETH_ALEN, skb->data + ETH_ALEN, ETH_ALEN);
 		skb_trim(skb, skb->len - ETH_ALEN);
 	}
 
diff --git a/drivers/net/wireless/hostap/hostap_80211_tx.c b/drivers/net/wireless/hostap/hostap_80211_tx.c
index 159baef..7bc152e 100644
--- a/drivers/net/wireless/hostap/hostap_80211_tx.c
+++ b/drivers/net/wireless/hostap/hostap_80211_tx.c
@@ -146,7 +146,7 @@ int hostap_data_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			fc |= IEEE80211_FCTL_FROMDS | IEEE80211_FCTL_TODS;
 			/* From&To DS: Addr1 = RA, Addr2 = TA, Addr3 = DA,
 			 * Addr4 = SA */
-			memcpy(&hdr.addr4, skb->data + ETH_ALEN, ETH_ALEN);
+			skb_copy_bits(skb, ETH_ALEN, &hdr.addr4, ETH_ALEN);
 			hdr_len += ETH_ALEN;
 		} else {
 			/* bogus 4-addr format to workaround Prism2 station
@@ -159,7 +159,7 @@ int hostap_data_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			/* SA from skb->data + ETH_ALEN will be added after
 			 * frame payload; use hdr.addr4 as a temporary buffer
 			 */
-			memcpy(&hdr.addr4, skb->data + ETH_ALEN, ETH_ALEN);
+			skb_copy_bits(skb, ETH_ALEN, &hdr.addr4, ETH_ALEN);
 			need_tailroom += ETH_ALEN;
 		}
 
@@ -174,24 +174,24 @@ int hostap_data_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		else
 			memcpy(&hdr.addr1, local->bssid, ETH_ALEN);
 		memcpy(&hdr.addr2, dev->dev_addr, ETH_ALEN);
-		memcpy(&hdr.addr3, skb->data, ETH_ALEN);
+		skb_copy_bits(skb, 0, &hdr.addr3, ETH_ALEN);
 	} else if (local->iw_mode == IW_MODE_MASTER && !to_assoc_ap) {
 		fc |= IEEE80211_FCTL_FROMDS;
 		/* From DS: Addr1 = DA, Addr2 = BSSID, Addr3 = SA */
-		memcpy(&hdr.addr1, skb->data, ETH_ALEN);
+		skb_copy_bits(skb, 0, &hdr.addr1, ETH_ALEN);
 		memcpy(&hdr.addr2, dev->dev_addr, ETH_ALEN);
-		memcpy(&hdr.addr3, skb->data + ETH_ALEN, ETH_ALEN);
+		skb_copy_bits(skb, ETH_ALEN, &hdr.addr3, ETH_ALEN);
 	} else if (local->iw_mode == IW_MODE_INFRA || to_assoc_ap) {
 		fc |= IEEE80211_FCTL_TODS;
 		/* To DS: Addr1 = BSSID, Addr2 = SA, Addr3 = DA */
 		memcpy(&hdr.addr1, to_assoc_ap ?
 		       local->assoc_ap_addr : local->bssid, ETH_ALEN);
-		memcpy(&hdr.addr2, skb->data + ETH_ALEN, ETH_ALEN);
-		memcpy(&hdr.addr3, skb->data, ETH_ALEN);
+		skb_copy_bits(skb, ETH_ALEN, &hdr.addr2, ETH_ALEN);
+		skb_copy_bits(skb, 0, &hdr.addr3, ETH_ALEN);
 	} else if (local->iw_mode == IW_MODE_ADHOC) {
 		/* not From/To DS: Addr1 = DA, Addr2 = SA, Addr3 = BSSID */
-		memcpy(&hdr.addr1, skb->data, ETH_ALEN);
-		memcpy(&hdr.addr2, skb->data + ETH_ALEN, ETH_ALEN);
+		skb_copy_bits(skb, 0, &hdr.addr1, ETH_ALEN);
+		skb_copy_bits(skb, ETH_ALEN, &hdr.addr2, ETH_ALEN);
 		memcpy(&hdr.addr3, local->bssid, ETH_ALEN);
 	}
 
diff --git a/drivers/net/wireless/hostap/hostap_ap.c b/drivers/net/wireless/hostap/hostap_ap.c
index 797d950..0eb7c37 100644
--- a/drivers/net/wireless/hostap/hostap_ap.c
+++ b/drivers/net/wireless/hostap/hostap_ap.c
@@ -1277,8 +1277,8 @@ static char * ap_auth_make_challenge(struct ap_data *ap)
 		return NULL;
 	}
 
-	memcpy(tmpbuf, skb->data + ap->crypt->extra_mpdu_prefix_len,
-	       WLAN_AUTH_CHALLENGE_LEN);
+	skb_copy_bits(skb, ap->crypt->extra_mpdu_prefix_len, tmpbuf,
+		      WLAN_AUTH_CHALLENGE_LEN);
 	dev_kfree_skb(skb);
 
 	return tmpbuf;
diff --git a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
index 9003ff7..3a986fd 100644
--- a/drivers/net/wireless/hostap/hostap_hw.c
+++ b/drivers/net/wireless/hostap/hostap_hw.c
@@ -1838,13 +1838,13 @@ static int prism2_tx_80211(struct sk_buff *skb, struct net_device *dev)
 
 	/* skb->data starts with txdesc->frame_control */
 	hdr_len = 24;
-	memcpy(&txdesc.frame_control, skb->data, hdr_len);
+	skb_copy_bits(skb, 0, &txdesc.frame_control, hdr_len);
  	fc = le16_to_cpu(txdesc.frame_control);
 	if (WLAN_FC_GET_TYPE(fc) == IEEE80211_FTYPE_DATA &&
 	    (fc & IEEE80211_FCTL_FROMDS) && (fc & IEEE80211_FCTL_TODS) &&
 	    skb->len >= 30) {
 		/* Addr4 */
-		memcpy(txdesc.addr4, skb->data + hdr_len, ETH_ALEN);
+		skb_copy_bits(skb, hdr_len, txdesc.addr4, ETH_ALEN);
 		hdr_len += ETH_ALEN;
 	}
 
diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index ad6e4a4..841b038 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -2416,8 +2416,9 @@ static void isr_rx(struct ipw2100_priv *priv, int i,
 #ifdef IPW2100_RX_DEBUG
 	/* Make a copy of the frame so we can dump it to the logs if
 	 * ieee80211_rx fails */
-	memcpy(packet_data, packet->skb->data,
-	       min_t(u32, status->frame_size, IPW_RX_NIC_BUFFER_LENGTH));
+	skb_copy_bits(packet->skb, 0, packet_data,
+		      min_t(u32, status->frame_size,
+				 IPW_RX_NIC_BUFFER_LENGTH));
 #endif
 
 	if (!ieee80211_rx(priv->ieee, packet->skb, stats)) {
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index b04c56a..5b3dcdb 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -10355,7 +10355,7 @@ static void ipw_handle_promiscuous_tx(struct ipw_priv *priv,
 
 		rt_hdr->it_len = dst->len;
 
-		memcpy(skb_put(dst, len), src->data, len);
+		skb_copy_bits(src, 0, skb_put(dst, len), len);
 
 		if (!ieee80211_rx(priv->prom_priv->ieee, dst, &dummystats))
 			dev_kfree_skb_any(dst);
diff --git a/drivers/net/wireless/prism54/islpci_eth.c b/drivers/net/wireless/prism54/islpci_eth.c
index 6ebfff0..94c38e2 100644
--- a/drivers/net/wireless/prism54/islpci_eth.c
+++ b/drivers/net/wireless/prism54/islpci_eth.c
@@ -162,13 +162,14 @@ islpci_eth_transmit(struct sk_buff *skb, struct net_device *ndev)
 
 			skb_put(newskb, init_wds ? skb->len + 6 : skb->len);
 			if (init_wds) {
-				memcpy(newskb->data + 6, skb->data, skb->len);
+				skb_copy_bits(skb, 0,
+					      newskb->data + 6, skb->len);
 				memcpy(newskb->data, wds_mac, 6);
 #ifdef ISLPCI_ETH_DEBUG
 				printk("islpci_eth_transmit:wds_mac\n");
 #endif
 			} else
-				memcpy(newskb->data, skb->data, skb->len);
+				skb_copy_bits(skb, 0, newskb->data, skb->len);
 
 #if VERBOSE > SHOW_ERROR_MESSAGES
 			DEBUG(SHOW_TRACING, "memcpy %p %p %i wds %i\n",
@@ -394,8 +395,9 @@ islpci_eth_receive(islpci_private *priv)
 			/* Update spy records */
 			wireless_spy_update(ndev, annex->addr2, &wstats);
 
-			memcpy(skb->data + sizeof (struct rfmon_header),
-			       skb->data, 2 * ETH_ALEN);
+			skb_copy_bits(skb, 0,
+				      skb->data + sizeof(struct rfmon_header),
+				      2 * ETH_ALEN);
 			skb_pull(skb, sizeof (struct rfmon_header));
 		}
 		skb->protocol = eth_type_trans(skb, ndev);
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 9633b04..2dfe9a0 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -2242,7 +2242,8 @@ static void rx_data(struct net_device *dev, struct rcs __iomem *prcs, unsigned i
     rx_ptr += copy_from_rx_buff(local, rx_ptr, pkt_addr & RX_BUFF_END, rx_len);
     /* Get source address */
 #ifdef WIRELESS_SPY
-    memcpy(linksrcaddr, ((struct mac_header *)skb->data)->addr_2, ETH_ALEN);
+    skb_copy_bits(skb, offsetof(struct mac_header, addr_2),
+		  linksrcaddr, ETH_ALEN);
 #endif
     /* Now, deal with encapsulation/translation/sniffer */
     if (!sniffer) {
diff --git a/drivers/net/wireless/wavelan.c b/drivers/net/wireless/wavelan.c
index 2bf77b1..b6e5501 100644
--- a/drivers/net/wireless/wavelan.c
+++ b/drivers/net/wireless/wavelan.c
@@ -2938,7 +2938,7 @@ static int wavelan_packet_xmit(struct sk_buff *skb, struct net_device * dev)
 	 * need to pad. Jean II */
 	if (skb->len < ETH_ZLEN) {
 		memset(data, 0, ETH_ZLEN);
-		memcpy(data, skb->data, skb->len);
+		skb_copy_bits(skb, 0, data, skb->len);
 		/* Write packet on the card */
 		if(wv_packet_write(dev, data, ETH_ZLEN))
 			return 1;	/* We failed */
diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index 1fe013a..6b491a4 100644
--- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -807,10 +807,10 @@ static int zd1201_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	txbuf[4] = 0x00;
 	txbuf[5] = 0x00;
 
-	memcpy(txbuf+6, skb->data+12, skb->len-12);
+	skb_copy_bits(skb, 12, txbuf + 6, skb->len - 12);
 	if (pad)
 		txbuf[skb->len-12+6]=0;
-	memcpy(txbuf+skb->len-12+6+pad, skb->data, 12);
+	skb_copy_bits(skb, 0, txbuf + skb->len - 12 + 6 + pad, 12);
 	*(__be16*)&txbuf[skb->len+6+pad] = htons(skb->len-12+6);
 	txbuf[txbuflen-1] = 0;
 
diff --git a/drivers/s390/net/ctcmain.c b/drivers/s390/net/ctcmain.c
index 54e3f80..768d6a4 100644
--- a/drivers/s390/net/ctcmain.c
+++ b/drivers/s390/net/ctcmain.c
@@ -472,7 +472,7 @@ ctc_unpack_skb(struct channel *ch, struct sk_buff *pskb)
 			privptr->stats.rx_dropped++;
 			return;
 		}
-		memcpy(skb_put(skb, pskb->len), pskb->data, pskb->len);
+		skb_copy_bits(pskb, 0, skb_put(skb, pskb->len), pskb->len);
 		skb_reset_mac_header(skb);
 		skb->dev = pskb->dev;
 		skb->protocol = pskb->protocol;
@@ -716,8 +716,8 @@ ch_action_txdone(fsm_instance * fi, int event, void *arg)
 		*((__u16 *) skb_put(ch->trans_skb, 2)) = ch->collect_len + 2;
 		i = 0;
 		while ((skb = skb_dequeue(&ch->collect_queue))) {
-			memcpy(skb_put(ch->trans_skb, skb->len), skb->data,
-			       skb->len);
+			skb_copy_bits(skb, 0, skb_put(ch->trans_skb, skb->len),
+				      skb->len);
 			privptr->stats.tx_packets++;
 			privptr->stats.tx_bytes += skb->len - LL_HEADER_LENGTH;
 			atomic_dec(&skb->users);
@@ -2268,8 +2268,8 @@ transmit_skb(struct channel *ch, struct sk_buff *skb)
 			skb_reset_tail_pointer(ch->trans_skb);
 			ch->trans_skb->len = 0;
 			ch->ccw[1].count = skb->len;
-			memcpy(skb_put(ch->trans_skb, skb->len), skb->data,
-			       skb->len);
+			skb_copy_bits(skb, 0, skb_put(ch->trans_skb, skb->len),
+				      skb->len);
 			atomic_dec(&skb->users);
 			dev_kfree_skb_irq(skb);
 			ccw_idx = 0;
diff --git a/drivers/s390/net/lcs.c b/drivers/s390/net/lcs.c
index 1c23e18..bf0300c 100644
--- a/drivers/s390/net/lcs.c
+++ b/drivers/s390/net/lcs.c
@@ -1576,7 +1576,7 @@ __lcs_start_xmit(struct lcs_card *card, struct sk_buff *skb,
 	header->offset = card->tx_buffer->count;
 	header->type = card->lan_type;
 	header->slot = card->portno;
-	memcpy(header + 1, skb->data, skb->len);
+	skb_copy_bits(skb, 0, header + 1, skb->len);
 	spin_unlock(&card->lock);
 	card->stats.tx_bytes += skb->len;
 	card->stats.tx_packets++;
diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index cd42bd5..9c37cce 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -645,7 +645,7 @@ static void netiucv_unpack_skb(struct iucv_connection *conn,
 			privptr->stats.rx_dropped++;
 			return;
 		}
-		memcpy(skb_put(skb, pskb->len), pskb->data, pskb->len);
+		skb_copy_bits(pskb, 0, skb_put(skb, pskb->len), pskb->len);
 		skb_reset_mac_header(skb);
 		skb->dev = pskb->dev;
 		skb->protocol = pskb->protocol;
@@ -744,7 +744,8 @@ static void conn_action_txdone(fsm_instance *fi, int event, void *arg)
 		header.next = conn->tx_buff->len + skb->len + NETIUCV_HDRLEN;
 		memcpy(skb_put(conn->tx_buff, NETIUCV_HDRLEN), &header,
 		       NETIUCV_HDRLEN);
-		memcpy(skb_put(conn->tx_buff, skb->len), skb->data, skb->len);
+		skb_copy_bits(skb, 0,
+			      skb_put(conn->tx_buff, skb->len), skb->len);
 		txbytes += skb->len;
 		txpackets++;
 		stat_maxcq++;
diff --git a/drivers/s390/net/qeth_eddp.c b/drivers/s390/net/qeth_eddp.c
index 5890bb5..ced7a40 100644
--- a/drivers/s390/net/qeth_eddp.c
+++ b/drivers/s390/net/qeth_eddp.c
@@ -267,7 +267,7 @@ qeth_eddp_copy_data_tcp(char *dst, struct qeth_eddp_data *eddp, int len,
 
 	QETH_DBF_TEXT(trace, 5, "eddpcdtc");
 	if (skb_shinfo(eddp->skb)->nr_frags == 0) {
-		memcpy(dst, eddp->skb->data + eddp->skb_offset, len);
+		skb_copy_bits(eddp->skb, eddp->skb_offset, dst, len);
 		*hcsum = csum_partial(eddp->skb->data + eddp->skb_offset, len,
 				      *hcsum);
 		eddp->skb_offset += len;
diff --git a/drivers/usb/atm/usbatm.c b/drivers/usb/atm/usbatm.c
index a076f73..ba36acd 100644
--- a/drivers/usb/atm/usbatm.c
+++ b/drivers/usb/atm/usbatm.c
@@ -484,7 +484,7 @@ static unsigned int usbatm_write_cells(struct usbatm_data *instance,
 		ptr[4] = 0xec;
 		ptr += ATM_CELL_HEADER;
 
-		memcpy(ptr, skb->data, data_len);
+		skb_copy_bits(skb, 0, ptr, data_len);
 		ptr += data_len;
 		__skb_pull(skb, data_len);
 
diff --git a/drivers/usb/net/catc.c b/drivers/usb/net/catc.c
index d82022d..9aa9f53 100644
--- a/drivers/usb/net/catc.c
+++ b/drivers/usb/net/catc.c
@@ -418,7 +418,7 @@ static int catc_hard_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	catc->tx_ptr = (((catc->tx_ptr - 1) >> 6) + 1) << 6;
 	tx_buf = catc->tx_buf[catc->tx_idx] + catc->tx_ptr;
 	*((u16*)tx_buf) = (catc->is_f5u011) ? cpu_to_be16((u16)skb->len) : cpu_to_le16((u16)skb->len);
-	memcpy(tx_buf + 2, skb->data, skb->len);
+	skb_copy_bits(skb, 0, tx_buf + 2, skb->len);
 	catc->tx_ptr += skb->len + 2;
 
 	if (!test_and_set_bit(TX_RUNNING, &catc->flags))
diff --git a/drivers/usb/net/pegasus.c b/drivers/usb/net/pegasus.c
index 01a3a1e..df6b045 100644
--- a/drivers/usb/net/pegasus.c
+++ b/drivers/usb/net/pegasus.c
@@ -882,7 +882,7 @@ static int pegasus_start_xmit(struct sk_buff *skb, struct net_device *net)
 	netif_stop_queue(net);
 
 	((__le16 *) pegasus->tx_buff)[0] = cpu_to_le16(l16);
-	memcpy(pegasus->tx_buff + 2, skb->data, skb->len);
+	skb_copy_bits(skb, 0, pegasus->tx_buff + 2, skb->len);
 	usb_fill_bulk_urb(pegasus->tx_urb, pegasus->usb,
 			  usb_sndbulkpipe(pegasus->usb, 2),
 			  pegasus->tx_buff, count,
diff --git a/net/ax25/ax25_out.c b/net/ax25/ax25_out.c
index e66953c..4138c17 100644
--- a/net/ax25/ax25_out.c
+++ b/net/ax25/ax25_out.c
@@ -150,7 +150,7 @@ void ax25_output(ax25_cb *ax25, int paclen, struct sk_buff *skb)
 				skb_reserve(skbn, frontlen + 2);
 				skb_set_network_header(skbn,
 						      skb_network_offset(skb));
-				memcpy(skb_put(skbn, len), skb->data, len);
+				skb_copy_bits(skb, 0, skb_put(skbn, len), len);
 				p = skb_push(skbn, 2);
 
 				*p++ = AX25_P_SEGMENT;
@@ -164,7 +164,7 @@ void ax25_output(ax25_cb *ax25, int paclen, struct sk_buff *skb)
 				skb_reserve(skbn, frontlen + 1);
 				skb_set_network_header(skbn,
 						      skb_network_offset(skb));
-				memcpy(skb_put(skbn, len), skb->data, len);
+				skb_copy_bits(skb, 0, skb_put(skbn, len), len);
 				p = skb_push(skbn, 1);
 				*p = AX25_P_TEXT;
 			}
diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
index 97156c4..3fff725 100644
--- a/net/bluetooth/bnep/core.c
+++ b/net/bluetooth/bnep/core.c
@@ -382,7 +382,7 @@ static inline int bnep_rx_frame(struct bnep_session *s, struct sk_buff *skb)
 		break;
 	}
 
-	memcpy(__skb_put(nskb, skb->len), skb->data, skb->len);
+	skb_copy_bits(skb, 0, __skb_put(nskb, skb->len), skb->len);
 	kfree_skb(skb);
 
 	s->stats.rx_packets++;
diff --git a/net/bluetooth/cmtp/core.c b/net/bluetooth/cmtp/core.c
index 3933608..fad5fc2 100644
--- a/net/bluetooth/cmtp/core.c
+++ b/net/bluetooth/cmtp/core.c
@@ -124,7 +124,7 @@ static inline void cmtp_add_msgpart(struct cmtp_session *session, int id, const
 	}
 
 	if (skb && (skb->len > 0))
-		memcpy(skb_put(nskb, skb->len), skb->data, skb->len);
+		skb_copy_bits(skb, 0, skb_put(nskb, skb->len), skb->len);
 
 	memcpy(skb_put(nskb, count), buf, count);
 
@@ -256,7 +256,7 @@ static void cmtp_process_transmit(struct cmtp_session *session)
 			hdr[2] = size >> 8;
 		}
 
-		memcpy(skb_put(nskb, size), skb->data, size);
+		skb_copy_bits(skb, 0, skb_put(nskb, size), size);
 		skb_pull(skb, size);
 
 		if (skb->len > 0) {
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 162eab6..d27b67e 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -2107,7 +2107,8 @@ static int l2cap_recv_acldata(struct hci_conn *hcon, struct sk_buff *skb, u16 fl
 		if (!(conn->rx_skb = bt_skb_alloc(len, GFP_ATOMIC)))
 			goto drop;
 
-		memcpy(skb_put(conn->rx_skb, skb->len), skb->data, skb->len);
+		skb_copy_bits(skb, 0, skb_put(conn->rx_skb, skb->len),
+			      skb->len);
 		conn->rx_len = len - skb->len;
 	} else {
 		BT_DBG("Cont: frag len %d (expecting %d)", skb->len, conn->rx_len);
@@ -2128,7 +2129,8 @@ static int l2cap_recv_acldata(struct hci_conn *hcon, struct sk_buff *skb, u16 fl
 			goto drop;
 		}
 
-		memcpy(skb_put(conn->rx_skb, skb->len), skb->data, skb->len);
+		skb_copy_bits(skb, 0, skb_put(conn->rx_skb, skb->len),
+			      skb->len);
 		conn->rx_len -= skb->len;
 
 		if (!conn->rx_len) {
diff --git a/net/decnet/dn_nsp_in.c b/net/decnet/dn_nsp_in.c
index d9498a1..1f2467b 100644
--- a/net/decnet/dn_nsp_in.c
+++ b/net/decnet/dn_nsp_in.c
@@ -362,7 +362,8 @@ static void dn_nsp_conn_conf(struct sock *sk, struct sk_buff *skb)
 			u16 dlen = *skb->data;
 			if ((dlen <= 16) && (dlen <= skb->len)) {
 				scp->conndata_in.opt_optl = dn_htons(dlen);
-				memcpy(scp->conndata_in.opt_data, skb->data + 1, dlen);
+				skb_copy_bits(skb, 1,
+					      scp->conndata_in.opt_data, dlen);
 			}
 		}
 		dn_nsp_send_link(sk, DN_NOCHANGE, 0);
@@ -406,7 +407,7 @@ static void dn_nsp_disc_init(struct sock *sk, struct sk_buff *skb)
 		u16 dlen = *skb->data;
 		if ((dlen <= 16) && (dlen <= skb->len)) {
 			scp->discdata_in.opt_optl = dn_htons(dlen);
-			memcpy(scp->discdata_in.opt_data, skb->data + 1, dlen);
+			skb_copy_bits(skb, 1, scp->discdata_in.opt_data, dlen);
 		}
 	}
 
diff --git a/net/ieee80211/ieee80211_crypt_wep.c b/net/ieee80211/ieee80211_crypt_wep.c
index ec6d885..a4fe435 100644
--- a/net/ieee80211/ieee80211_crypt_wep.c
+++ b/net/ieee80211/ieee80211_crypt_wep.c
@@ -152,7 +152,7 @@ static int prism2_wep_encrypt(struct sk_buff *skb, int hdr_len, void *priv)
 		return -1;
 
 	/* Copy the IV into the first 3 bytes of the key */
-	memcpy(key, skb->data + hdr_len, 3);
+	skb_copy_bits(skb, hdr_len, key, 3);
 
 	/* Copy rest of the WEP key (the secret part) */
 	memcpy(key + 3, wep->key, wep->key_len);
diff --git a/net/ieee80211/ieee80211_rx.c b/net/ieee80211/ieee80211_rx.c
index 59a765c..74195e1 100644
--- a/net/ieee80211/ieee80211_rx.c
+++ b/net/ieee80211/ieee80211_rx.c
@@ -606,12 +606,12 @@ int ieee80211_rx(struct ieee80211_device *ieee, struct sk_buff *skb,
 		if (frag == 0) {
 			/* copy first fragment (including full headers) into
 			 * beginning of the fragment cache skb */
-			memcpy(skb_put(frag_skb, flen), skb->data, flen);
+			skb_copy_bits(skb, 0, skb_put(frag_skb, flen), flen);
 		} else {
 			/* append frame payload to the end of the fragment
 			 * cache skb */
-			memcpy(skb_put(frag_skb, flen), skb->data + hdrlen,
-			       flen);
+			skb_copy_bits(skb, hdrlen,
+				      skb_put(frag_skb, flen), flen);
 		}
 		dev_kfree_skb_any(skb);
 		skb = NULL;
diff --git a/net/ieee80211/ieee80211_tx.c b/net/ieee80211/ieee80211_tx.c
index 62a8a2b..4165a98 100644
--- a/net/ieee80211/ieee80211_tx.c
+++ b/net/ieee80211/ieee80211_tx.c
@@ -309,8 +309,8 @@ int ieee80211_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	/* Save source and destination addresses */
-	memcpy(dest, skb->data, ETH_ALEN);
-	memcpy(src, skb->data + ETH_ALEN, ETH_ALEN);
+	skb_copy_bits(skb, 0, dest, ETH_ALEN);
+	skb_copy_bits(skb, ETH_ALEN, src, ETH_ALEN);
 
 	if (host_encrypt || host_build_iv)
 		fc = IEEE80211_FTYPE_DATA | IEEE80211_STYPE_DATA |
@@ -363,7 +363,7 @@ int ieee80211_xmit(struct sk_buff *skb, struct net_device *dev)
 		snapped = 1;
 		ieee80211_copy_snap(skb_put(skb_new, SNAP_SIZE + sizeof(u16)),
 				    ether_type);
-		memcpy(skb_put(skb_new, skb->len), skb->data, skb->len);
+		skb_copy_bits(skb, 0, skb_put(skb_new, skb->len), skb->len);
 		res = crypt->ops->encrypt_msdu(skb_new, hdr_len, crypt->priv);
 		if (res < 0) {
 			IEEE80211_ERROR("msdu encryption failed\n");
@@ -492,7 +492,7 @@ int ieee80211_xmit(struct sk_buff *skb, struct net_device *dev)
 			bytes -= SNAP_SIZE + sizeof(u16);
 		}
 
-		memcpy(skb_put(skb_frag, bytes), skb->data, bytes);
+		skb_copy_bits(skb, 0, skb_put(skb_frag, bytes), bytes);
 
 		/* Advance the SKB... */
 		skb_pull(skb, bytes);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 875da38..c73cd72 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -596,7 +596,7 @@ slow_path:
 		 *	Copy the packet header into the new buffer.
 		 */
 
-		memcpy(skb_network_header(skb2), skb->data, hlen);
+		skb_copy_bits(skb, 0, skb_network_header(skb2), hlen);
 
 		/*
 		 *	Copy a block of the IP datagram.
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index e2b8db6..c2da2b5 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -746,7 +746,7 @@ slow_path:
 		/*
 		 *	Copy the packet header into the new buffer.
 		 */
-		memcpy(skb_network_header(frag), skb->data, hlen);
+		skb_copy_bits(skb, 0, skb_network_header(frag), hlen);
 
 		/*
 		 *	Build fragment header.
diff --git a/net/irda/irttp.c b/net/irda/irttp.c
index a7486b3..0561def 100644
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -314,8 +314,8 @@ static inline void irttp_fragment_skb(struct tsap_cb *self,
 		skb_reserve(frag, self->max_header_size);
 
 		/* Copy data from the original skb into this fragment. */
-		memcpy(skb_put(frag, self->max_seg_size), skb->data,
-		       self->max_seg_size);
+		skb_copy_bits(skb, 0, skb_put(frag, self->max_seg_size),
+			      self->max_seg_size);
 
 		/* Insert TTP header, with the more bit set */
 		frame = skb_push(frag, TTP_HEADER);
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 053fa26..4062df9 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1160,7 +1160,8 @@ static int nr_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	if (sax != NULL) {
 		sax->sax25_family = AF_NETROM;
-		memcpy(sax->sax25_call.ax25_call, skb->data + 7, AX25_ADDR_LEN);
+		skb_copy_bits(skb, 7, sax->sax25_call.ax25_call,
+			      AX25_ADDR_LEN);
 	}
 
 	msg->msg_namelen = sizeof(*sax);
diff --git a/net/netrom/nr_loopback.c b/net/netrom/nr_loopback.c
index 99fdab1..21f0385 100644
--- a/net/netrom/nr_loopback.c
+++ b/net/netrom/nr_loopback.c
@@ -34,7 +34,7 @@ int nr_loopback_queue(struct sk_buff *skb)
 	struct sk_buff *skbn;
 
 	if ((skbn = alloc_skb(skb->len, GFP_ATOMIC)) != NULL) {
-		memcpy(skb_put(skbn, skb->len), skb->data, skb->len);
+		skb_copy_bits(skb, 0, skb_put(skbn, skb->len), skb->len);
 		skb_reset_transport_header(skbn);
 
 		skb_queue_tail(&loopback_queue, skbn);
diff --git a/net/netrom/nr_out.c b/net/netrom/nr_out.c
index 0cbfb61..d5f5462 100644
--- a/net/netrom/nr_out.c
+++ b/net/netrom/nr_out.c
@@ -40,7 +40,7 @@ void nr_output(struct sock *sk, struct sk_buff *skb)
 
 	if (skb->len - NR_TRANSPORT_LEN > NR_MAX_PACKET_SIZE) {
 		/* Save a copy of the Transport Header */
-		memcpy(transport, skb->data, NR_TRANSPORT_LEN);
+		skb_copy_bits(skb, 0, transport, NR_TRANSPORT_LEN);
 		skb_pull(skb, NR_TRANSPORT_LEN);
 
 		frontlen = skb_headroom(skb);
@@ -54,7 +54,7 @@ void nr_output(struct sock *sk, struct sk_buff *skb)
 			len = (NR_MAX_PACKET_SIZE > skb->len) ? skb->len : NR_MAX_PACKET_SIZE;
 
 			/* Copy the user data */
-			memcpy(skb_put(skbn, len), skb->data, len);
+			skb_copy_bits(skb, 0, skb_put(skbn, len), len);
 			skb_pull(skb, len);
 
 			/* Duplicate the Transport Header */
diff --git a/net/netrom/nr_subr.c b/net/netrom/nr_subr.c
index 07b694d..038cb35 100644
--- a/net/netrom/nr_subr.c
+++ b/net/netrom/nr_subr.c
@@ -226,13 +226,13 @@ void __nr_transmit_reply(struct sk_buff *skb, int mine, unsigned char cmdflags)
 
 	dptr = skb_put(skbn, NR_NETWORK_LEN + NR_TRANSPORT_LEN);
 
-	memcpy(dptr, skb->data + 7, AX25_ADDR_LEN);
+	skb_copy_bits(skb, 7, dptr, AX25_ADDR_LEN);
 	dptr[6] &= ~AX25_CBIT;
 	dptr[6] &= ~AX25_EBIT;
 	dptr[6] |= AX25_SSSID_SPARE;
 	dptr += AX25_ADDR_LEN;
 
-	memcpy(dptr, skb->data + 0, AX25_ADDR_LEN);
+	skb_copy_bits(skb, 0, dptr, AX25_ADDR_LEN);
 	dptr[6] &= ~AX25_CBIT;
 	dptr[6] |= AX25_EBIT;
 	dptr[6] |= AX25_SSSID_SPARE;
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 1511697..bf84f5c 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1156,7 +1156,7 @@ static int rose_sendmsg(struct kiocb *iocb, struct socket *sock,
 		int lg;
 
 		/* Save a copy of the Header */
-		memcpy(header, skb->data, ROSE_MIN_LEN);
+		skb_copy_bits(skb, 0, header, ROSE_MIN_LEN);
 		skb_pull(skb, ROSE_MIN_LEN);
 
 		frontlen = skb_headroom(skb);
@@ -1176,7 +1176,7 @@ static int rose_sendmsg(struct kiocb *iocb, struct socket *sock,
 			lg = (ROSE_PACLEN > skb->len) ? skb->len : ROSE_PACLEN;
 
 			/* Copy the user data */
-			memcpy(skb_put(skbn, lg), skb->data, lg);
+			skb_copy_bits(skb, 0, skb_put(skbn, lg), lg);
 			skb_pull(skb, lg);
 
 			/* Duplicate the Header */
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index adcda8e..0fa68e6 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -951,7 +951,7 @@ int x25_rx_call_request(struct sk_buff *skb, struct x25_neigh *nb,
 	 *	Incoming Call User Data.
 	 */
 	if (skb->len >= 0) {
-		memcpy(makex25->calluserdata.cuddata, skb->data, skb->len);
+		skb_copy_bits(skb, 0, makex25->calluserdata.cuddata, skb->len);
 		makex25->calluserdata.cudlength = skb->len;
 	}
 
diff --git a/net/x25/x25_in.c b/net/x25/x25_in.c
index b2bbe55..bca9fef 100644
--- a/net/x25/x25_in.c
+++ b/net/x25/x25_in.c
@@ -112,8 +112,9 @@ static int x25_state1_machine(struct sock *sk, struct sk_buff *skb, int frametyp
 			 *	Copy any Call User Data.
 			 */
 			if (skb->len >= 0) {
-				memcpy(x25->calluserdata.cuddata, skb->data,
-				       skb->len);
+				skb_copy_bits(skb, 0,
+					      x25->calluserdata.cuddata,
+					      skb->len);
 				x25->calluserdata.cudlength = skb->len;
 			}
 			if (!sock_flag(sk, SOCK_DEAD))
diff --git a/net/x25/x25_out.c b/net/x25/x25_out.c
index 6f57378..f3a22d9 100644
--- a/net/x25/x25_out.c
+++ b/net/x25/x25_out.c
@@ -61,7 +61,7 @@ int x25_output(struct sock *sk, struct sk_buff *skb)
 
 	if (skb->len - header_len > max_len) {
 		/* Save a copy of the Header */
-		memcpy(header, skb->data, header_len);
+		skb_copy_bits(skb, 0, header, header_len);
 		skb_pull(skb, header_len);
 
 		frontlen = skb_headroom(skb);
@@ -84,7 +84,7 @@ int x25_output(struct sock *sk, struct sk_buff *skb)
 			len = max_len > skb->len ? skb->len : max_len;
 
 			/* Copy the user data */
-			memcpy(skb_put(skbn, len), skb->data, len);
+			skb_copy_bits(skb, 0, skb_put(skbn, len), len);
 			skb_pull(skb, len);
 
 			/* Duplicate the Header */
-- 
1.5.0.3

