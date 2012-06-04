From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 3/3] drivers: net: Remove casts to same type
Date: Mon,  4 Jun 2012 15:44:18 -0700
Message-ID: <9e705459c04cd37fc9bcdcde3b9993c491d292cb.1338849367.git.joe@perches.com>
References: <cover.1338849364.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:47365 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761092Ab2FDWoq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2012 18:44:46 -0400
In-Reply-To: <cover.1338849364.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding casts of objects to the same type is unnecessary
and confusing for a human reader.

For example, this cast:

        int y;
        int *p = (int *)&y;

I used the coccinelle script below to find and remove these
unnecessary casts.  I manually removed the conversions this
script produces of casts with __force, __iomem and __user.

@@
type T;
T *p;
@@

-       (T *)p
+       p

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/appletalk/cops.c      |    2 +-
 drivers/net/can/bfin_can.c        |    2 +-
 drivers/net/can/mcp251x.c         |    3 +--
 drivers/net/fddi/defxx.c          |    4 ++--
 drivers/net/fddi/skfp/pmf.c       |    8 ++++----
 drivers/net/hamradio/mkiss.c      |    8 ++++----
 drivers/net/hyperv/netvsc.c       |    2 +-
 drivers/net/irda/ali-ircc.c       |    6 +++---
 drivers/net/irda/au1k_ir.c        |    2 +-
 drivers/net/slip/slip.c           |    4 ++--
 drivers/net/vmxnet3/vmxnet3_drv.c |    2 +-
 drivers/net/wan/x25_asy.c         |    2 +-
 drivers/net/wimax/i2400m/fw.c     |    2 +-
 13 files changed, 23 insertions(+), 24 deletions(-)

diff --git a/drivers/net/appletalk/cops.c b/drivers/net/appletalk/cops.c
index dd5e048..545c09e 100644
--- a/drivers/net/appletalk/cops.c
+++ b/drivers/net/appletalk/cops.c
@@ -936,7 +936,7 @@ static int cops_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
         struct cops_local *lp = netdev_priv(dev);
         struct sockaddr_at *sa = (struct sockaddr_at *)&ifr->ifr_addr;
-        struct atalk_addr *aa = (struct atalk_addr *)&lp->node_addr;
+        struct atalk_addr *aa = &lp->node_addr;
 
         switch(cmd)
         {
diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
index 3f88473..ea31438 100644
--- a/drivers/net/can/bfin_can.c
+++ b/drivers/net/can/bfin_can.c
@@ -597,7 +597,7 @@ static int __devinit bfin_can_probe(struct platform_device *pdev)
 	dev_info(&pdev->dev,
 		"%s device registered"
 		"(&reg_base=%p, rx_irq=%d, tx_irq=%d, err_irq=%d, sclk=%d)\n",
-		DRV_NAME, (void *)priv->membase, priv->rx_irq,
+		DRV_NAME, priv->membase, priv->rx_irq,
 		priv->tx_irq, priv->err_irq, priv->can.clock.freq);
 	return 0;
 
diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index 346785c..9120a36 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -1020,8 +1020,7 @@ static int __devinit mcp251x_can_probe(struct spi_device *spi)
 						      GFP_DMA);
 
 		if (priv->spi_tx_buf) {
-			priv->spi_rx_buf = (u8 *)(priv->spi_tx_buf +
-						  (PAGE_SIZE / 2));
+			priv->spi_rx_buf = (priv->spi_tx_buf + (PAGE_SIZE / 2));
 			priv->spi_rx_dma = (dma_addr_t)(priv->spi_tx_dma +
 							(PAGE_SIZE / 2));
 		} else {
diff --git a/drivers/net/fddi/defxx.c b/drivers/net/fddi/defxx.c
index 4ad80f7..6695a1d 100644
--- a/drivers/net/fddi/defxx.c
+++ b/drivers/net/fddi/defxx.c
@@ -2962,7 +2962,7 @@ static int dfx_rcv_init(DFX_board_t *bp, int get_buffers)
 			bp->descr_block_virt->rcv_data[i+j].long_0 = (u32) (PI_RCV_DESCR_M_SOP |
 				((PI_RCV_DATA_K_SIZE_MAX / PI_ALIGN_K_RCV_DATA_BUFF) << PI_RCV_DESCR_V_SEG_LEN));
 			bp->descr_block_virt->rcv_data[i+j].long_1 = (u32) (bp->rcv_block_phys + (i * PI_RCV_DATA_K_SIZE_MAX));
-			bp->p_rcv_buff_va[i+j] = (char *) (bp->rcv_block_virt + (i * PI_RCV_DATA_K_SIZE_MAX));
+			bp->p_rcv_buff_va[i+j] = (bp->rcv_block_virt + (i * PI_RCV_DATA_K_SIZE_MAX));
 			}
 #endif
 	}
@@ -3030,7 +3030,7 @@ static void dfx_rcv_queue_process(
 #ifdef DYNAMIC_BUFFERS
 		p_buff = (char *) (((struct sk_buff *)bp->p_rcv_buff_va[entry])->data);
 #else
-		p_buff = (char *) bp->p_rcv_buff_va[entry];
+		p_buff = bp->p_rcv_buff_va[entry];
 #endif
 		memcpy(&descr, p_buff + RCV_BUFF_K_DESCR, sizeof(u32));
 
diff --git a/drivers/net/fddi/skfp/pmf.c b/drivers/net/fddi/skfp/pmf.c
index 9ac4665..24d8566 100644
--- a/drivers/net/fddi/skfp/pmf.c
+++ b/drivers/net/fddi/skfp/pmf.c
@@ -1242,7 +1242,7 @@ static int smt_set_para(struct s_smc *smc, struct smt_para *pa, int index,
 			if (len < 8)
 				goto len_error ;
 			if (set)
-				memcpy((char *) to,(char *) from+2,6) ;
+				memcpy(to,from+2,6) ;
 			to += 8 ;
 			from += 8 ;
 			len -= 8 ;
@@ -1251,7 +1251,7 @@ static int smt_set_para(struct s_smc *smc, struct smt_para *pa, int index,
 			if (len < 4)
 				goto len_error ;
 			if (set)
-				memcpy((char *) to,(char *) from,4) ;
+				memcpy(to,from,4) ;
 			to += 4 ;
 			from += 4 ;
 			len -= 4 ;
@@ -1260,7 +1260,7 @@ static int smt_set_para(struct s_smc *smc, struct smt_para *pa, int index,
 			if (len < 8)
 				goto len_error ;
 			if (set)
-				memcpy((char *) to,(char *) from,8) ;
+				memcpy(to,from,8) ;
 			to += 8 ;
 			from += 8 ;
 			len -= 8 ;
@@ -1269,7 +1269,7 @@ static int smt_set_para(struct s_smc *smc, struct smt_para *pa, int index,
 			if (len < 32)
 				goto len_error ;
 			if (set)
-				memcpy((char *) to,(char *) from,32) ;
+				memcpy(to,from,32) ;
 			to += 32 ;
 			from += 32 ;
 			len -= 32 ;
diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index aed1a61..2c0894a 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -485,7 +485,7 @@ static void ax_encaps(struct net_device *dev, unsigned char *icp, int len)
 
 			return;
 		default:
-			count = kiss_esc(p, (unsigned char *)ax->xbuff, len);
+			count = kiss_esc(p, ax->xbuff, len);
 		}
 	} else {
 		unsigned short crc;
@@ -497,7 +497,7 @@ static void ax_encaps(struct net_device *dev, unsigned char *icp, int len)
 		case CRC_MODE_SMACK:
 			*p |= 0x80;
 			crc = swab16(crc16(0, p, len));
-			count = kiss_esc_crc(p, (unsigned char *)ax->xbuff, crc, len+2);
+			count = kiss_esc_crc(p, ax->xbuff, crc, len+2);
 			break;
 		case CRC_MODE_FLEX_TEST:
 			ax->crcmode = CRC_MODE_NONE;
@@ -506,11 +506,11 @@ static void ax_encaps(struct net_device *dev, unsigned char *icp, int len)
 		case CRC_MODE_FLEX:
 			*p |= 0x20;
 			crc = calc_crc_flex(p, len);
-			count = kiss_esc_crc(p, (unsigned char *)ax->xbuff, crc, len+2);
+			count = kiss_esc_crc(p, ax->xbuff, crc, len+2);
 			break;
 
 		default:
-			count = kiss_esc(p, (unsigned char *)ax->xbuff, len);
+			count = kiss_esc(p, ax->xbuff, len);
 		}
   	}
 	spin_unlock_bh(&ax->buflock);
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 8b91947..4363c76 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -614,7 +614,7 @@ retry_send_cmplt:
 static void netvsc_receive_completion(void *context)
 {
 	struct hv_netvsc_packet *packet = context;
-	struct hv_device *device = (struct hv_device *)packet->device;
+	struct hv_device *device = packet->device;
 	struct netvsc_device *net_device;
 	u64 transaction_id = 0;
 	bool fsend_receive_comp = false;
diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index dcc80d6..8487204 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -1017,7 +1017,7 @@ static void ali_ircc_fir_change_speed(struct ali_ircc_cb *priv, __u32 baud)
 {
 		
 	int iobase; 
-	struct ali_ircc_cb *self = (struct ali_ircc_cb *) priv;
+	struct ali_ircc_cb *self = priv;
 	struct net_device *dev;
 
 	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __func__ );
@@ -1052,7 +1052,7 @@ static void ali_ircc_fir_change_speed(struct ali_ircc_cb *priv, __u32 baud)
  */
 static void ali_ircc_sir_change_speed(struct ali_ircc_cb *priv, __u32 speed)
 {
-	struct ali_ircc_cb *self = (struct ali_ircc_cb *) priv;
+	struct ali_ircc_cb *self = priv;
 	unsigned long flags;
 	int iobase; 
 	int fcr;    /* FIFO control reg */
@@ -1121,7 +1121,7 @@ static void ali_ircc_sir_change_speed(struct ali_ircc_cb *priv, __u32 speed)
 static void ali_ircc_change_dongle_speed(struct ali_ircc_cb *priv, int speed)
 {
 	
-	struct ali_ircc_cb *self = (struct ali_ircc_cb *) priv;
+	struct ali_ircc_cb *self = priv;
 	int iobase,dongle_id;
 	int tmp = 0;
 			
diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index fc503aa..e09417d 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -794,7 +794,7 @@ static int __devinit au1k_irda_net_init(struct net_device *dev)
 
 	/* allocate the data buffers */
 	aup->db[0].vaddr =
-		(void *)dma_alloc(MAX_BUF_SIZE * 2 * NUM_IR_DESC, &temp);
+		dma_alloc(MAX_BUF_SIZE * 2 * NUM_IR_DESC, &temp);
 	if (!aup->db[0].vaddr)
 		goto out3;
 
diff --git a/drivers/net/slip/slip.c b/drivers/net/slip/slip.c
index d4c9db3..a34d6bf 100644
--- a/drivers/net/slip/slip.c
+++ b/drivers/net/slip/slip.c
@@ -390,10 +390,10 @@ static void sl_encaps(struct slip *sl, unsigned char *icp, int len)
 #endif
 #ifdef CONFIG_SLIP_MODE_SLIP6
 	if (sl->mode & SL_MODE_SLIP6)
-		count = slip_esc6(p, (unsigned char *) sl->xbuff, len);
+		count = slip_esc6(p, sl->xbuff, len);
 	else
 #endif
-		count = slip_esc(p, (unsigned char *) sl->xbuff, len);
+		count = slip_esc(p, sl->xbuff, len);
 
 	/* Order of next two lines is *very* important.
 	 * When we are sending a little amount of data,
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 3f04ba0..93e0cfb 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1037,7 +1037,7 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 #endif
 	dev_dbg(&adapter->netdev->dev,
 		"txd[%u]: SOP 0x%Lx 0x%x 0x%x\n",
-		(u32)((union Vmxnet3_GenericDesc *)ctx.sop_txd -
+		(u32)(ctx.sop_txd -
 		tq->tx_ring.base), le64_to_cpu(gdesc->txd.addr),
 		le32_to_cpu(gdesc->dword[2]), le32_to_cpu(gdesc->dword[3]));
 
diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index d7a65e1..44db8b7 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -231,7 +231,7 @@ static void x25_asy_encaps(struct x25_asy *sl, unsigned char *icp, int len)
 	}
 
 	p = icp;
-	count = x25_asy_esc(p, (unsigned char *) sl->xbuff, len);
+	count = x25_asy_esc(p, sl->xbuff, len);
 
 	/* Order of next two lines is *very* important.
 	 * When we are sending a little amount of data,
diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index 7cbd7d2..d09e449 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -1268,7 +1268,7 @@ int i2400m_fw_check(struct i2400m *i2400m, const void *bcf, size_t bcf_size)
 		size_t leftover, offset, header_len, size;
 
 		leftover = top - itr;
-		offset = itr - (const void *) bcf;
+		offset = itr - bcf;
 		if (leftover <= sizeof(*bcf_hdr)) {
 			dev_err(dev, "firmware %s: %zu B left at @%zx, "
 				"not enough for BCF header\n",
-- 
1.7.8.111.gad25c.dirty
