From: Joe Perches <joe@perches.com>
Subject: [PATCH 20/35] drivers/isdn: Convert remaining uses of pr_warning to pr_warn
Date: Thu, 16 Feb 2017 23:11:33 -0800
Message-ID: <5b05531314db5d6b9c40e2e082c4f6a495df4ae6.1487314667.git.joe@perches.com>
References: <cover.1487314666.git.joe@perches.com>
Cc: Karsten Keil <isdn@linux-pingi.de>,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1487314666.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To enable eventual removal of pr_warning

This makes pr_warn use consistent for drivers/isdn

Prior to this patch, there were 20 uses of pr_warning and
3 uses of pr_warn in drivers/isdn

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/isdn/gigaset/interface.c        |  2 +-
 drivers/isdn/hardware/mISDN/avmfritz.c  | 17 +++++++++--------
 drivers/isdn/hardware/mISDN/hfcmulti.c  |  8 ++++----
 drivers/isdn/hardware/mISDN/hfcpci.c    |  4 ++--
 drivers/isdn/hardware/mISDN/hfcsusb.c   |  4 ++--
 drivers/isdn/hardware/mISDN/mISDNipac.c |  4 ++--
 drivers/isdn/hardware/mISDN/mISDNisar.c | 10 +++++-----
 drivers/isdn/hardware/mISDN/netjet.c    |  8 ++++----
 drivers/isdn/hardware/mISDN/w6692.c     | 12 ++++++------
 drivers/isdn/mISDN/hwchannel.c          |  8 ++++----
 10 files changed, 39 insertions(+), 38 deletions(-)

diff --git a/drivers/isdn/gigaset/interface.c b/drivers/isdn/gigaset/interface.c
index 600c79b030cd..4a2496d3f4ae 100644
--- a/drivers/isdn/gigaset/interface.c
+++ b/drivers/isdn/gigaset/interface.c
@@ -510,7 +510,7 @@ void gigaset_if_init(struct cardstate *cs)
 	if (!IS_ERR(cs->tty_dev))
 		dev_set_drvdata(cs->tty_dev, cs);
 	else {
-		pr_warning("could not register device to the tty subsystem\n");
+		pr_warn("could not register device to the tty subsystem\n");
 		cs->tty_dev = NULL;
 	}
 	mutex_unlock(&cs->mutex);
diff --git a/drivers/isdn/hardware/mISDN/avmfritz.c b/drivers/isdn/hardware/mISDN/avmfritz.c
index e3fa1cd64470..af88a0a7112c 100644
--- a/drivers/isdn/hardware/mISDN/avmfritz.c
+++ b/drivers/isdn/hardware/mISDN/avmfritz.c
@@ -414,8 +414,8 @@ hdlc_empty_fifo(struct bchannel *bch, int count)
 	} else {
 		cnt = bchannel_get_rxbuf(bch, count);
 		if (cnt < 0) {
-			pr_warning("%s.B%d: No bufferspace for %d bytes\n",
-				   fc->name, bch->nr, count);
+			pr_warn("%s.B%d: No bufferspace for %d bytes\n",
+				fc->name, bch->nr, count);
 			return;
 		}
 		p = skb_put(bch->rx_skb, count);
@@ -551,8 +551,8 @@ HDLC_irq(struct bchannel *bch, u32 stat)
 	}
 	if (stat & HDLC_INT_RPR) {
 		if (stat & HDLC_STAT_RDO) {
-			pr_warning("%s: ch%d stat %x RDO\n",
-				   fc->name, bch->nr, stat);
+			pr_warn("%s: ch%d stat %x RDO\n",
+				fc->name, bch->nr, stat);
 			hdlc->ctrl.sr.xml = 0;
 			hdlc->ctrl.sr.cmd |= HDLC_CMD_RRS;
 			write_ctrl(bch, 1);
@@ -574,8 +574,8 @@ HDLC_irq(struct bchannel *bch, u32 stat)
 				    HDLC_STAT_CRCVFR) {
 					recv_Bchannel(bch, 0, false);
 				} else {
-					pr_warning("%s: got invalid frame\n",
-						   fc->name);
+					pr_warn("%s: got invalid frame\n",
+						fc->name);
 					skb_trim(bch->rx_skb, 0);
 				}
 			}
@@ -587,8 +587,9 @@ HDLC_irq(struct bchannel *bch, u32 stat)
 		 * restart transmitting the whole frame on HDLC
 		 * in transparent mode we send the next data
 		 */
-		pr_warning("%s: ch%d stat %x XDU %s\n", fc->name, bch->nr,
-			   stat, bch->tx_skb ? "tx_skb" : "no tx_skb");
+		pr_warn("%s: ch%d stat %x XDU %s\n",
+			fc->name, bch->nr,
+			stat, bch->tx_skb ? "tx_skb" : "no tx_skb");
 		if (bch->tx_skb && bch->tx_skb->len) {
 			if (!test_bit(FLG_TRANSPARENT, &bch->Flags))
 				bch->tx_idx = 0;
diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index 480c2d7794eb..7749b684acbc 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -2262,8 +2262,8 @@ hfcmulti_rx(struct hfc_multi *hc, int ch)
 	if (bch) {
 		maxlen = bchannel_get_rxbuf(bch, Zsize);
 		if (maxlen < 0) {
-			pr_warning("card%d.B%d: No bufferspace for %d bytes\n",
-				   hc->id + 1, bch->nr, Zsize);
+			pr_warn("card%d.B%d: No bufferspace for %d bytes\n",
+				hc->id + 1, bch->nr, Zsize);
 			return;
 		}
 		sp = &bch->rx_skb;
@@ -2274,8 +2274,8 @@ hfcmulti_rx(struct hfc_multi *hc, int ch)
 		if (*sp == NULL) {
 			*sp = mI_alloc_skb(maxlen, GFP_ATOMIC);
 			if (*sp == NULL) {
-				pr_warning("card%d: No mem for dch rx_skb\n",
-					   hc->id + 1);
+				pr_warn("card%d: No mem for dch rx_skb\n",
+					hc->id + 1);
 				return;
 			}
 		}
diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardware/mISDN/hfcpci.c
index ff48da61c94c..4d4fa6cb6412 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -579,8 +579,8 @@ hfcpci_empty_fifo_trans(struct bchannel *bch, struct bzfifo *rxbz,
 	}
 	maxlen = bchannel_get_rxbuf(bch, fcnt_rx);
 	if (maxlen < 0) {
-		pr_warning("B%d: No bufferspace for %d bytes\n",
-			   bch->nr, fcnt_rx);
+		pr_warn("B%d: No bufferspace for %d bytes\n",
+			bch->nr, fcnt_rx);
 	} else {
 		ptr = skb_put(bch->rx_skb, fcnt_rx);
 		if (le16_to_cpu(*z2r) + fcnt_rx <= B_FIFO_SIZE + B_SUB_VAL)
diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.c b/drivers/isdn/hardware/mISDN/hfcsusb.c
index 114f3bcba1b0..f9eaff9b4803 100644
--- a/drivers/isdn/hardware/mISDN/hfcsusb.c
+++ b/drivers/isdn/hardware/mISDN/hfcsusb.c
@@ -852,8 +852,8 @@ hfcsusb_rx_frame(struct usb_fifo *fifo, __u8 *data, unsigned int len,
 		if (maxlen < 0) {
 			if (rx_skb)
 				skb_trim(rx_skb, 0);
-			pr_warning("%s.B%d: No bufferspace for %d bytes\n",
-				   hw->name, fifo->bch->nr, len);
+			pr_warn("%s.B%d: No bufferspace for %d bytes\n",
+				hw->name, fifo->bch->nr, len);
 			spin_unlock(&hw->lock);
 			return;
 		}
diff --git a/drivers/isdn/hardware/mISDN/mISDNipac.c b/drivers/isdn/hardware/mISDN/mISDNipac.c
index 77dec28ba874..48b4225e9ba1 100644
--- a/drivers/isdn/hardware/mISDN/mISDNipac.c
+++ b/drivers/isdn/hardware/mISDN/mISDNipac.c
@@ -954,8 +954,8 @@ hscx_empty_fifo(struct hscx_hw *hscx, u8 count)
 		hscx_cmdr(hscx, 0x80); /* RMC */
 		if (hscx->bch.rx_skb)
 			skb_trim(hscx->bch.rx_skb, 0);
-		pr_warning("%s.B%d: No bufferspace for %d bytes\n",
-			   hscx->ip->name, hscx->bch.nr, count);
+		pr_warn("%s.B%d: No bufferspace for %d bytes\n",
+			hscx->ip->name, hscx->bch.nr, count);
 		return;
 	}
 	p = skb_put(hscx->bch.rx_skb, count);
diff --git a/drivers/isdn/hardware/mISDN/mISDNisar.c b/drivers/isdn/hardware/mISDN/mISDNisar.c
index feafa91c2ed9..d789378cd879 100644
--- a/drivers/isdn/hardware/mISDN/mISDNisar.c
+++ b/drivers/isdn/hardware/mISDN/mISDNisar.c
@@ -235,7 +235,7 @@ load_firmware(struct isar_hw *isar, const u8 *buf, int size)
 			goto reterror;
 		}
 		if (!poll_mbox(isar, 1000)) {
-			pr_warning("ISAR poll_mbox dkey failed\n");
+			pr_warn("ISAR poll_mbox dkey failed\n");
 			ret = -ETIME;
 			goto reterror;
 		}
@@ -445,8 +445,8 @@ isar_rcv_frame(struct isar_ch *ch)
 	case ISDN_P_B_MODEM_ASYNC:
 		maxlen = bchannel_get_rxbuf(&ch->bch, ch->is->clsb);
 		if (maxlen < 0) {
-			pr_warning("%s.B%d: No bufferspace for %d bytes\n",
-				   ch->is->name, ch->bch.nr, ch->is->clsb);
+			pr_warn("%s.B%d: No bufferspace for %d bytes\n",
+				ch->is->name, ch->bch.nr, ch->is->clsb);
 			ch->is->write_reg(ch->is->hw, ISAR_IIA, 0);
 			break;
 		}
@@ -456,8 +456,8 @@ isar_rcv_frame(struct isar_ch *ch)
 	case ISDN_P_B_HDLC:
 		maxlen = bchannel_get_rxbuf(&ch->bch, ch->is->clsb);
 		if (maxlen < 0) {
-			pr_warning("%s.B%d: No bufferspace for %d bytes\n",
-				   ch->is->name, ch->bch.nr, ch->is->clsb);
+			pr_warn("%s.B%d: No bufferspace for %d bytes\n",
+				ch->is->name, ch->bch.nr, ch->is->clsb);
 			ch->is->write_reg(ch->is->hw, ISAR_IIA, 0);
 			break;
 		}
diff --git a/drivers/isdn/hardware/mISDN/netjet.c b/drivers/isdn/hardware/mISDN/netjet.c
index afde4edef9ae..a21c5bcbf35c 100644
--- a/drivers/isdn/hardware/mISDN/netjet.c
+++ b/drivers/isdn/hardware/mISDN/netjet.c
@@ -393,8 +393,8 @@ read_dma(struct tiger_ch *bc, u32 idx, int cnt)
 	stat = bchannel_get_rxbuf(&bc->bch, cnt);
 	/* only transparent use the count here, HDLC overun is detected later */
 	if (stat == -ENOMEM) {
-		pr_warning("%s.B%d: No memory for %d bytes\n",
-			   card->name, bc->bch.nr, cnt);
+		pr_warn("%s.B%d: No memory for %d bytes\n",
+			card->name, bc->bch.nr, cnt);
 		return;
 	}
 	if (test_bit(FLG_TRANSPARENT, &bc->bch.Flags))
@@ -433,8 +433,8 @@ read_dma(struct tiger_ch *bc, u32 idx, int cnt)
 			recv_Bchannel(&bc->bch, 0, false);
 			stat = bchannel_get_rxbuf(&bc->bch, bc->bch.maxlen);
 			if (stat < 0) {
-				pr_warning("%s.B%d: No memory for %d bytes\n",
-					   card->name, bc->bch.nr, cnt);
+				pr_warn("%s.B%d: No memory for %d bytes\n",
+					card->name, bc->bch.nr, cnt);
 				return;
 			}
 		} else if (stat == -HDLC_CRC_ERROR) {
diff --git a/drivers/isdn/hardware/mISDN/w6692.c b/drivers/isdn/hardware/mISDN/w6692.c
index 3b067ea656bd..9be37546b210 100644
--- a/drivers/isdn/hardware/mISDN/w6692.c
+++ b/drivers/isdn/hardware/mISDN/w6692.c
@@ -485,8 +485,8 @@ W6692_empty_Bfifo(struct w6692_ch *wch, int count)
 		WriteW6692B(wch, W_B_CMDR, W_B_CMDR_RACK | W_B_CMDR_RACT);
 		if (wch->bch.rx_skb)
 			skb_trim(wch->bch.rx_skb, 0);
-		pr_warning("%s.B%d: No bufferspace for %d bytes\n",
-			   card->name, wch->bch.nr, count);
+		pr_warn("%s.B%d: No bufferspace for %d bytes\n",
+			card->name, wch->bch.nr, count);
 		return;
 	}
 	ptr = skb_put(wch->bch.rx_skb, count);
@@ -749,8 +749,8 @@ W6692B_interrupt(struct w6692_hw *card, int ch)
 				 wch->bch.nr, star);
 		}
 		if (star & W_B_STAR_XDOW) {
-			pr_warning("%s: B%d XDOW proto=%x\n", card->name,
-				   wch->bch.nr, wch->bch.state);
+			pr_warn("%s: B%d XDOW proto=%x\n",
+				card->name, wch->bch.nr, wch->bch.state);
 #ifdef ERROR_STATISTIC
 			wch->bch.err_xdu++;
 #endif
@@ -767,8 +767,8 @@ W6692B_interrupt(struct w6692_hw *card, int ch)
 			return; /* handle XDOW only once */
 	}
 	if (stat & W_B_EXI_XDUN) {
-		pr_warning("%s: B%d XDUN proto=%x\n", card->name,
-			   wch->bch.nr, wch->bch.state);
+		pr_warn("%s: B%d XDUN proto=%x\n",
+			card->name, wch->bch.nr, wch->bch.state);
 #ifdef ERROR_STATISTIC
 		wch->bch.err_xdu++;
 #endif
diff --git a/drivers/isdn/mISDN/hwchannel.c b/drivers/isdn/mISDN/hwchannel.c
index 84b4b0f7eb99..a79d7d3d1429 100644
--- a/drivers/isdn/mISDN/hwchannel.c
+++ b/drivers/isdn/mISDN/hwchannel.c
@@ -483,8 +483,8 @@ bchannel_get_rxbuf(struct bchannel *bch, int reqlen)
 	if (bch->rx_skb) {
 		len = skb_tailroom(bch->rx_skb);
 		if (len < reqlen) {
-			pr_warning("B%d no space for %d (only %d) bytes\n",
-				   bch->nr, reqlen, len);
+			pr_warn("B%d no space for %d (only %d) bytes\n",
+				bch->nr, reqlen, len);
 			if (test_bit(FLG_TRANSPARENT, &bch->Flags)) {
 				/* send what we have now and try a new buffer */
 				recv_Bchannel(bch, 0, true);
@@ -517,8 +517,8 @@ bchannel_get_rxbuf(struct bchannel *bch, int reqlen)
 	}
 	bch->rx_skb = mI_alloc_skb(len, GFP_ATOMIC);
 	if (!bch->rx_skb) {
-		pr_warning("B%d receive no memory for %d bytes\n",
-			   bch->nr, len);
+		pr_warn("B%d receive no memory for %d bytes\n",
+			bch->nr, len);
 		len = -ENOMEM;
 	}
 	return len;
-- 
2.10.0.rc2.1.g053435c
