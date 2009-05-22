From: Karsten Keil <keil-shG/GajIFYqbacvFa/9K2g@public.gmane.org>
Subject: [mISDN PATCH v2 17/19] Cleanup debug messages
Date: Fri, 22 May 2009 23:04:56 +0200
Message-ID: <0b1f7ca9c9fbe27c928aeedc58e5abdceeca7888.1243024967.git.kkeil@pingi.linux-pingi.de>
References: <cover.1243024967.git.kkeil@pingi.linux-pingi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
In-Reply-To: <cover.1243024967.git.kkeil-Zw2aQviYsaUCyFmpLCWB8V3+hHH5wKcB@public.gmane.org>
List-Unsubscribe: <https://www.isdn4linux.de/mailman/listinfo/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=unsubscribe>
List-Archive: <http://www.isdn4linux.de/pipermail/i4ldeveloper>
List-Post: <mailto:i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
List-Help: <mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=help>
List-Subscribe: <https://www.isdn4linux.de/mailman/listinfo/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=subscribe>
Sender: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
Errors-To: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch make debug printk's KERN_DEBUG and also fix some
codestyle issues.

Signed-off-by: Karsten Keil <keil-shG/GajIFYqbacvFa/9K2g@public.gmane.org>
---
 drivers/isdn/hardware/mISDN/hfcmulti.c |  159 ++++++++++++++++----------------
 drivers/isdn/hardware/mISDN/hfcpci.c   |   28 +++---
 drivers/isdn/mISDN/dsp_audio.c         |    5 +-
 drivers/isdn/mISDN/dsp_cmx.c           |    7 +-
 drivers/isdn/mISDN/dsp_core.c          |   14 ++--
 drivers/isdn/mISDN/dsp_ecdis.h         |    2 +-
 drivers/isdn/mISDN/dsp_tones.c         |   23 +++--
 drivers/isdn/mISDN/l1oip_core.c        |   30 +++---
 drivers/isdn/mISDN/socket.c            |    2 +-
 drivers/isdn/mISDN/tei.c               |    1 -
 drivers/isdn/mISDN/timerdev.c          |    2 +-
 include/linux/mISDNif.h                |   14 ++--
 12 files changed, 148 insertions(+), 139 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index a4d790b..e1dab30 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -275,7 +275,7 @@ HFC_outb_pcimem(struct hfc_multi *hc, u_char reg, u_char val,
 HFC_outb_pcimem(struct hfc_multi *hc, u_char reg, u_char val)
 #endif
 {
-	writeb(val, (hc->pci_membase)+reg);
+	writeb(val, hc->pci_membase + reg);
 }
 static u_char
 #ifdef HFC_REGISTER_DEBUG
@@ -284,7 +284,7 @@ HFC_inb_pcimem(struct hfc_multi *hc, u_char reg, const char *function, int line)
 HFC_inb_pcimem(struct hfc_multi *hc, u_char reg)
 #endif
 {
-	return readb((hc->pci_membase)+reg);
+	return readb(hc->pci_membase + reg);
 }
 static u_short
 #ifdef HFC_REGISTER_DEBUG
@@ -293,7 +293,7 @@ HFC_inw_pcimem(struct hfc_multi *hc, u_char reg, const char *function, int line)
 HFC_inw_pcimem(struct hfc_multi *hc, u_char reg)
 #endif
 {
-	return readw((hc->pci_membase)+reg);
+	return readw(hc->pci_membase + reg);
 }
 static void
 #ifdef HFC_REGISTER_DEBUG
@@ -302,7 +302,8 @@ HFC_wait_pcimem(struct hfc_multi *hc, const char *function, int line)
 HFC_wait_pcimem(struct hfc_multi *hc)
 #endif
 {
-	while (readb((hc->pci_membase)+R_STATUS) & V_BUSY);
+	while (readb(hc->pci_membase + R_STATUS) & V_BUSY)
+		cpu_relax();
 }
 
 /* HFC_IO_MODE_REGIO */
@@ -314,7 +315,7 @@ HFC_outb_regio(struct hfc_multi *hc, u_char reg, u_char val,
 HFC_outb_regio(struct hfc_multi *hc, u_char reg, u_char val)
 #endif
 {
-	outb(reg, (hc->pci_iobase)+4);
+	outb(reg, hc->pci_iobase + 4);
 	outb(val, hc->pci_iobase);
 }
 static u_char
@@ -324,7 +325,7 @@ HFC_inb_regio(struct hfc_multi *hc, u_char reg, const char *function, int line)
 HFC_inb_regio(struct hfc_multi *hc, u_char reg)
 #endif
 {
-	outb(reg, (hc->pci_iobase)+4);
+	outb(reg, hc->pci_iobase + 4);
 	return inb(hc->pci_iobase);
 }
 static u_short
@@ -334,7 +335,7 @@ HFC_inw_regio(struct hfc_multi *hc, u_char reg, const char *function, int line)
 HFC_inw_regio(struct hfc_multi *hc, u_char reg)
 #endif
 {
-	outb(reg, (hc->pci_iobase)+4);
+	outb(reg, hc->pci_iobase + 4);
 	return inw(hc->pci_iobase);
 }
 static void
@@ -344,8 +345,9 @@ HFC_wait_regio(struct hfc_multi *hc, const char *function, int line)
 HFC_wait_regio(struct hfc_multi *hc)
 #endif
 {
-	outb(R_STATUS, (hc->pci_iobase)+4);
-	while (inb(hc->pci_iobase) & V_BUSY);
+	outb(R_STATUS, hc->pci_iobase + 4);
+	while (inb(hc->pci_iobase) & V_BUSY)
+		cpu_relax();
 }
 
 #ifdef HFC_REGISTER_DEBUG
@@ -364,14 +366,14 @@ HFC_outb_debug(struct hfc_multi *hc, u_char reg, u_char val,
 	if (regname[0] == '\0')
 		strcpy(regname, "register");
 
-	bits[7] = '0'+(!!(val&1));
-	bits[6] = '0'+(!!(val&2));
-	bits[5] = '0'+(!!(val&4));
-	bits[4] = '0'+(!!(val&8));
-	bits[3] = '0'+(!!(val&16));
-	bits[2] = '0'+(!!(val&32));
-	bits[1] = '0'+(!!(val&64));
-	bits[0] = '0'+(!!(val&128));
+	bits[7] = '0' + (!!(val & 1));
+	bits[6] = '0' + (!!(val & 2));
+	bits[5] = '0' + (!!(val & 4));
+	bits[4] = '0' + (!!(val & 8));
+	bits[3] = '0' + (!!(val & 16));
+	bits[2] = '0' + (!!(val & 32));
+	bits[1] = '0' + (!!(val & 64));
+	bits[0] = '0' + (!!(val & 128));
 	printk(KERN_DEBUG
 	    "HFC_outb(chip %d, %02x=%s, 0x%02x=%s); in %s() line %d\n",
 	    hc->id, reg, regname, val, bits, function, line);
@@ -394,14 +396,14 @@ HFC_inb_debug(struct hfc_multi *hc, u_char reg, const char *function, int line)
 	if (regname[0] == '\0')
 		strcpy(regname, "register");
 
-	bits[7] = '0'+(!!(val&1));
-	bits[6] = '0'+(!!(val&2));
-	bits[5] = '0'+(!!(val&4));
-	bits[4] = '0'+(!!(val&8));
-	bits[3] = '0'+(!!(val&16));
-	bits[2] = '0'+(!!(val&32));
-	bits[1] = '0'+(!!(val&64));
-	bits[0] = '0'+(!!(val&128));
+	bits[7] = '0' + (!!(val & 1));
+	bits[6] = '0' + (!!(val & 2));
+	bits[5] = '0' + (!!(val & 4));
+	bits[4] = '0' + (!!(val & 8));
+	bits[3] = '0' + (!!(val & 16));
+	bits[2] = '0' + (!!(val & 32));
+	bits[1] = '0' + (!!(val & 64));
+	bits[0] = '0' + (!!(val & 128));
 	printk(KERN_DEBUG
 	    "HFC_inb(chip %d, %02x=%s) = 0x%02x=%s; in %s() line %d\n",
 	    hc->id, reg, regname, val, bits, function, line);
@@ -481,6 +483,7 @@ write_fifo_pcimem(struct hfc_multi *hc, u_char *data, int len)
 		len--;
 	}
 }
+
 /* read fifo data (REGIO) */
 static void
 read_fifo_regio(struct hfc_multi *hc, u_char *data, int len)
@@ -526,7 +529,6 @@ read_fifo_pcimem(struct hfc_multi *hc, u_char *data, int len)
 	}
 }
 
-
 static void
 enable_hwirq(struct hfc_multi *hc)
 {
@@ -1011,7 +1013,7 @@ plxsd_checksync(struct hfc_multi *hc, int rm)
 	if (hc->syncronized) {
 		if (syncmaster == NULL) {
 			if (debug & DEBUG_HFCMULTI_PLXSD)
-				printk(KERN_WARNING "%s: GOT sync on card %d"
+				printk(KERN_DEBUG "%s: GOT sync on card %d"
 					" (id=%d)\n", __func__, hc->id + 1,
 					hc->id);
 			hfcmulti_resync(hc, hc, rm);
@@ -1019,7 +1021,7 @@ plxsd_checksync(struct hfc_multi *hc, int rm)
 	} else {
 		if (syncmaster == hc) {
 			if (debug & DEBUG_HFCMULTI_PLXSD)
-				printk(KERN_WARNING "%s: LOST sync on card %d"
+				printk(KERN_DEBUG "%s: LOST sync on card %d"
 					" (id=%d)\n", __func__, hc->id + 1,
 					hc->id);
 			hfcmulti_resync(hc, NULL, rm);
@@ -1068,7 +1070,7 @@ release_io_hfcmulti(struct hfc_multi *hc)
 		pv &= ~PLX_DSP_RES_N;
 		writel(pv, plx_acc_32);
 		if (debug & DEBUG_HFCMULTI_INIT)
-			printk(KERN_WARNING "%s: PCM off: PLX_GPIO=%x\n",
+			printk(KERN_DEBUG "%s: PCM off: PLX_GPIO=%x\n",
 				__func__, pv);
 		spin_unlock_irqrestore(&plx_lock, plx_flags);
 	}
@@ -1119,8 +1121,8 @@ init_chip(struct hfc_multi *hc)
 	if (debug & DEBUG_HFCMULTI_INIT)
 		printk(KERN_DEBUG "%s: entered\n", __func__);
 	val = HFC_inb(hc, R_CHIP_ID);
-	if ((val>>4) != 0x8 && (val>>4) != 0xc && (val>>4) != 0xe
-			&& (val>>1) != 0x31) {
+	if ((val >> 4) != 0x8 && (val >> 4) != 0xc && (val >> 4) != 0xe &&
+	    (val >> 1) != 0x31) {
 		printk(KERN_INFO "HFC_multi: unknown CHIP_ID:%x\n", (u_int)val);
 		err = -EIO;
 		goto out;
@@ -1202,7 +1204,7 @@ init_chip(struct hfc_multi *hc)
 		writel(pv, plx_acc_32);
 		spin_unlock_irqrestore(&plx_lock, plx_flags);
 		if (debug & DEBUG_HFCMULTI_INIT)
-			printk(KERN_WARNING "%s: slave/term: PLX_GPIO=%x\n",
+			printk(KERN_DEBUG "%s: slave/term: PLX_GPIO=%x\n",
 				__func__, pv);
 		/*
 		 * If we are the 3rd PLXSD card or higher, we must turn
@@ -1230,8 +1232,9 @@ init_chip(struct hfc_multi *hc)
 			writel(pv, plx_acc_32);
 			spin_unlock_irqrestore(&plx_lock, plx_flags);
 			if (debug & DEBUG_HFCMULTI_INIT)
-			    printk(KERN_WARNING "%s: term off: PLX_GPIO=%x\n",
-					__func__, pv);
+				printk(KERN_DEBUG
+				    "%s: term off: PLX_GPIO=%x\n",
+				    __func__, pv);
 		}
 		spin_unlock_irqrestore(&HFClock, hfc_flags);
 		hc->hw.r_pcm_md0 = V_F0_LEN; /* shift clock for DSP */
@@ -1292,13 +1295,13 @@ init_chip(struct hfc_multi *hc)
 			pv |= PLX_MASTER_EN | PLX_SLAVE_EN_N;
 			pv |= PLX_SYNC_O_EN;
 			if (debug & DEBUG_HFCMULTI_INIT)
-				printk(KERN_WARNING "%s: master: PLX_GPIO=%x\n",
+				printk(KERN_DEBUG "%s: master: PLX_GPIO=%x\n",
 					__func__, pv);
 		} else {
 			pv &= ~(PLX_MASTER_EN | PLX_SLAVE_EN_N);
 			pv &= ~PLX_SYNC_O_EN;
 			if (debug & DEBUG_HFCMULTI_INIT)
-				printk(KERN_WARNING "%s: slave: PLX_GPIO=%x\n",
+				printk(KERN_DEBUG "%s: slave: PLX_GPIO=%x\n",
 					__func__, pv);
 		}
 		writel(pv, plx_acc_32);
@@ -1410,8 +1413,8 @@ controller_fail:
 				writel(pv, plx_acc_32);
 				spin_unlock_irqrestore(&plx_lock, plx_flags);
 				if (debug & DEBUG_HFCMULTI_INIT)
-				    printk(KERN_WARNING "%s: master: PLX_GPIO"
-					"=%x\n", __func__, pv);
+					printk(KERN_DEBUG "%s: master: "
+					    "PLX_GPIO=%x\n", __func__, pv);
 			}
 			hc->hw.r_pcm_md0 |= V_PCM_MD;
 			HFC_outb(hc, R_PCM_MD0, hc->hw.r_pcm_md0 | 0x00);
@@ -1445,7 +1448,7 @@ controller_fail:
 		writel(pv, plx_acc_32);
 		spin_unlock_irqrestore(&plx_lock, plx_flags);
 		if (debug & DEBUG_HFCMULTI_INIT)
-			printk(KERN_WARNING "%s: reset off: PLX_GPIO=%x\n",
+			printk(KERN_DEBUG "%s: reset off: PLX_GPIO=%x\n",
 				__func__, pv);
 	}
 
@@ -1878,7 +1881,7 @@ hfcmulti_dtmf(struct hfc_multi *hc)
 			hc->chan[ch].coeff_count = 0;
 			skb = mI_alloc_skb(512, GFP_ATOMIC);
 			if (!skb) {
-				printk(KERN_WARNING "%s: No memory for skb\n",
+				printk(KERN_DEBUG "%s: No memory for skb\n",
 				    __func__);
 				continue;
 			}
@@ -2104,7 +2107,7 @@ next_frame:
 		printk(KERN_DEBUG "%s(card %d): fifo(%d) has %d bytes space "
 		    "left (z1=%04x, z2=%04x) sending %d of %d bytes %s\n",
 			__func__, hc->id + 1, ch, Zspace, z1, z2, ii-i, len-i,
-			temp ? "HDLC":"TRANS");
+			temp ? "HDLC" : "TRANS");
 
 	/* Have to prep the audio data */
 	hc->write_fifo(hc, d, ii - i);
@@ -2780,13 +2783,13 @@ hfcmulti_interrupt(int intno, void *dev_id)
 			handle_timer_irq(hc);
 		}
 
-		if (r_irq_misc & V_DTMF_IRQ) {
+		if (r_irq_misc & V_DTMF_IRQ)
 			hfcmulti_dtmf(hc);
-		}
+
 		if (r_irq_misc & V_IRQ_PROC) {
 			static int irq_proc_cnt;
 			if (!irq_proc_cnt++)
-				printk(KERN_WARNING "%s: got V_IRQ_PROC -"
+				printk(KERN_DEBUG "%s: got V_IRQ_PROC -"
 				    " this should not happen\n", __func__);
 		}
 
@@ -2936,7 +2939,7 @@ mode_hfcmulti(struct hfc_multi *hc, int ch, int protocol, int slot_tx,
 		else
 			flow_rx = 0xc0; /* ST->(FIFO,PCM) */
 		/* put on slot */
-		routing = bank_rx?0x80:0xc0; /* reversed */
+		routing = bank_rx ? 0x80 : 0xc0; /* reversed */
 		if (conf >= 0 || bank_rx > 1)
 			routing = 0x40; /* loop */
 		if (debug & DEBUG_HFCMULTI_MODE)
@@ -2971,7 +2974,7 @@ mode_hfcmulti(struct hfc_multi *hc, int ch, int protocol, int slot_tx,
 		HFC_wait(hc);
 		if (hc->chan[ch].bch && hc->ctype != HFC_TYPE_E1) {
 			hc->hw.a_st_ctrl0[hc->chan[ch].port] &=
-			    ((ch & 0x3) == 0)? ~V_B1_EN: ~V_B2_EN;
+			    ((ch & 0x3) == 0) ? ~V_B1_EN : ~V_B2_EN;
 			HFC_outb(hc, R_ST_SEL, hc->chan[ch].port);
 			/* undocumented: delay after R_ST_SEL */
 			udelay(1);
@@ -3505,9 +3508,9 @@ handle_bmsg(struct mISDNchannel *ch, struct sk_buff *skb)
 		switch (hh->id) {
 		case HFC_SPL_LOOP_ON: /* set sample loop */
 			if (debug & DEBUG_HFCMULTI_MSG)
-			printk(KERN_DEBUG
-			    "%s: HFC_SPL_LOOP_ON (len = %d)\n",
-			    __func__, skb->len);
+				printk(KERN_DEBUG
+				    "%s: HFC_SPL_LOOP_ON (len = %d)\n",
+				    __func__, skb->len);
 			ret = 0;
 			break;
 		case HFC_SPL_LOOP_OFF: /* set silence */
@@ -3716,8 +3719,7 @@ ph_state_change(struct dchannel *dch)
 	int ch, i;
 
 	if (!dch) {
-		printk(KERN_WARNING "%s: ERROR given dch is NULL\n",
-		    __func__);
+		printk(KERN_WARNING "%s: ERROR given dch is NULL\n", __func__);
 		return;
 	}
 	hc = dch->hw;
@@ -3738,14 +3740,15 @@ ph_state_change(struct dchannel *dch)
 		switch (dch->state) {
 		case (1):
 			if (hc->e1_state != 1) {
-			    for (i = 1; i <= 31; i++) {
-				/* reset fifos on e1 activation */
-				HFC_outb_nodebug(hc, R_FIFO, (i << 1) | 1);
-				HFC_wait_nodebug(hc);
-				HFC_outb_nodebug(hc,
-					R_INC_RES_FIFO, V_RES_F);
-				HFC_wait_nodebug(hc);
-			    }
+				for (i = 1; i <= 31; i++) {
+					/* reset fifos on e1 activation */
+					HFC_outb_nodebug(hc, R_FIFO,
+						(i << 1) | 1);
+					HFC_wait_nodebug(hc);
+					HFC_outb_nodebug(hc, R_INC_RES_FIFO,
+						V_RES_F);
+					HFC_wait_nodebug(hc);
+				}
 			}
 			test_and_set_bit(FLG_ACTIVE, &dch->Flags);
 			_queue_data(&dch->dev.D, PH_ACTIVATE_IND,
@@ -4045,12 +4048,12 @@ open_dchannel(struct hfc_multi *hc, struct dchannel *dch,
 		return -EINVAL;
 	if ((dch->dev.D.protocol != ISDN_P_NONE) &&
 	    (dch->dev.D.protocol != rq->protocol)) {
-	    if (debug & DEBUG_HFCMULTI_MODE)
-		printk(KERN_WARNING "%s: change protocol %x to %x\n",
-		    __func__, dch->dev.D.protocol, rq->protocol);
+		if (debug & DEBUG_HFCMULTI_MODE)
+			printk(KERN_DEBUG "%s: change protocol %x to %x\n",
+			    __func__, dch->dev.D.protocol, rq->protocol);
 	}
-	if ((dch->dev.D.protocol == ISDN_P_TE_S0)
-	 && (rq->protocol != ISDN_P_TE_S0))
+	if ((dch->dev.D.protocol == ISDN_P_TE_S0) &&
+	    (rq->protocol != ISDN_P_TE_S0))
 		l1_event(dch->l1, CLOSE_CHANNEL);
 	if (dch->dev.D.protocol != rq->protocol) {
 		if (rq->protocol == ISDN_P_TE_S0) {
@@ -4127,9 +4130,9 @@ channel_dctrl(struct dchannel *dch, struct mISDN_ctrl_req *cq)
 		wd_cnt = cq->p1 & 0xf;
 		wd_mode = !!(cq->p1 >> 4);
 		if (debug & DEBUG_HFCMULTI_MSG)
-			printk(KERN_DEBUG
-			    "%s: MISDN_CTRL_HFC_WD_INIT mode %s counter 0x%x\n",
-			    __func__, wd_mode ? "AUTO" : "MANUAL", wd_cnt);
+			printk(KERN_DEBUG "%s: MISDN_CTRL_HFC_WD_INIT mode %s"
+			    ", counter 0x%x\n", __func__,
+			    wd_mode ? "AUTO" : "MANUAL", wd_cnt);
 		/* set the watchdog timer */
 		HFC_outb(hc, R_TI_WD, poll_timer | (wd_cnt << 4));
 		hc->hw.r_bert_wd_md = (wd_mode ? V_AUTO_WD_RES : 0);
@@ -4139,8 +4142,8 @@ channel_dctrl(struct dchannel *dch, struct mISDN_ctrl_req *cq)
 		HFC_outb(hc, R_BERT_WD_MD, hc->hw.r_bert_wd_md | V_WD_RES);
 		if (test_bit(HFC_CHIP_PLXSD, &hc->chip)) {
 			/* enable the watchdog output for Speech-Design */
-			HFC_outb(hc, R_GPIO_SEL, V_GPIO_SEL7);
-			HFC_outb(hc, R_GPIO_EN1, V_GPIO_EN15);
+			HFC_outb(hc, R_GPIO_SEL,  V_GPIO_SEL7);
+			HFC_outb(hc, R_GPIO_EN1,  V_GPIO_EN15);
 			HFC_outb(hc, R_GPIO_OUT1, 0);
 			HFC_outb(hc, R_GPIO_OUT1, V_GPIO_OUT15);
 		}
@@ -4319,7 +4322,7 @@ error:
 	}
 
 	if (debug & DEBUG_HFCMULTI_INIT)
-		printk(KERN_WARNING "%s: free irq %d\n", __func__, hc->irq);
+		printk(KERN_DEBUG "%s: free irq %d\n", __func__, hc->irq);
 	if (hc->irq) {
 		free_irq(hc->irq, hc);
 		hc->irq = 0;
@@ -4624,7 +4627,7 @@ release_card(struct hfc_multi *hc)
 	int	ch;
 
 	if (debug & DEBUG_HFCMULTI_INIT)
-		printk(KERN_WARNING "%s: release card (%d) entered\n",
+		printk(KERN_DEBUG "%s: release card (%d) entered\n",
 		    __func__, hc->id);
 
 	/* unregister clock source */
@@ -4653,7 +4656,7 @@ release_card(struct hfc_multi *hc)
 	/* release hardware & irq */
 	if (hc->irq) {
 		if (debug & DEBUG_HFCMULTI_INIT)
-			printk(KERN_WARNING "%s: free irq %d\n",
+			printk(KERN_DEBUG "%s: free irq %d\n",
 			    __func__, hc->irq);
 		free_irq(hc->irq, hc);
 		hc->irq = 0;
@@ -4662,17 +4665,17 @@ release_card(struct hfc_multi *hc)
 	release_io_hfcmulti(hc);
 
 	if (debug & DEBUG_HFCMULTI_INIT)
-		printk(KERN_WARNING "%s: remove instance from list\n",
+		printk(KERN_DEBUG "%s: remove instance from list\n",
 		     __func__);
 	list_del(&hc->list);
 
 	if (debug & DEBUG_HFCMULTI_INIT)
-		printk(KERN_WARNING "%s: delete instance\n", __func__);
+		printk(KERN_DEBUG "%s: delete instance\n", __func__);
 	if (hc == syncmaster)
 		syncmaster = NULL;
 	kfree(hc);
 	if (debug & DEBUG_HFCMULTI_INIT)
-		printk(KERN_WARNING "%s: card successfully removed\n",
+		printk(KERN_DEBUG "%s: card successfully removed\n",
 		    __func__);
 }
 
@@ -4695,7 +4698,7 @@ init_e1_port(struct hfc_multi *hc, struct hm_map *m)
 	    (1 << (ISDN_P_B_HDLC & ISDN_P_B_MASK));
 	dch->dev.D.send = handle_dmsg;
 	dch->dev.D.ctrl = hfcm_dctrl;
-	dch->dev.nrbchan = (hc->dslot)?30:31;
+	dch->dev.nrbchan = (hc->dslot) ? 30 : 31;
 	dch->slot = hc->dslot;
 	hc->chan[hc->dslot].dch = dch;
 	hc->chan[hc->dslot].port = 0;
@@ -4937,7 +4940,7 @@ init_multi_port(struct hfc_multi *hc, int pt)
 	}
 	/* disable E-channel */
 	if (port[Port_cnt] & 0x004) {
-	if (debug & DEBUG_HFCMULTI_INIT)
+		if (debug & DEBUG_HFCMULTI_INIT)
 			printk(KERN_DEBUG
 			    "%s: PROTOCOL disable E-channel: "
 			    "card(%d) port(%d)\n",
@@ -5222,7 +5225,7 @@ static void __devexit hfc_remove_pci(struct pci_dev *pdev)
 		spin_unlock_irqrestore(&HFClock, flags);
 	}  else {
 		if (debug)
-			printk(KERN_WARNING "%s: drvdata allready removed\n",
+			printk(KERN_DEBUG "%s: drvdata allready removed\n",
 			    __func__);
 	}
 }
diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardware/mISDN/hfcpci.c
index 60dc925..776afc8 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -257,7 +257,7 @@ reset_hfcpci(struct hfc_pci *hc)
 	Write_hfc(hc, HFCPCI_INT_M1, hc->hw.int_m1);
 
 	/* Clear already pending ints */
-	if (Read_hfc(hc, HFCPCI_INT_S1));
+	val = Read_hfc(hc, HFCPCI_INT_S1);
 
 	/* set NT/TE mode */
 	hfcpci_setmode(hc);
@@ -499,7 +499,8 @@ receive_dmsg(struct hfc_pci *hc)
 			df->f2 = ((df->f2 + 1) & MAX_D_FRAMES) |
 			    (MAX_D_FRAMES + 1);	/* next buffer */
 			df->za[df->f2 & D_FREG_MASK].z2 =
-			    cpu_to_le16((le16_to_cpu(zp->z2) + rcnt) & (D_FIFO_SIZE - 1));
+			    cpu_to_le16((le16_to_cpu(zp->z2) + rcnt) &
+			    (D_FIFO_SIZE - 1));
 		} else {
 			dch->rx_skb = mI_alloc_skb(rcnt - 3, GFP_ATOMIC);
 			if (!dch->rx_skb) {
@@ -966,6 +967,7 @@ static void
 ph_state_nt(struct dchannel *dch)
 {
 	struct hfc_pci	*hc = dch->hw;
+	u_char	val;
 
 	if (dch->debug)
 		printk(KERN_DEBUG "%s: NT newstate %x\n",
@@ -979,7 +981,7 @@ ph_state_nt(struct dchannel *dch)
 			hc->hw.int_m1 &= ~HFCPCI_INTS_TIMER;
 			Write_hfc(hc, HFCPCI_INT_M1, hc->hw.int_m1);
 			/* Clear already pending ints */
-			if (Read_hfc(hc, HFCPCI_INT_S1));
+			val = Read_hfc(hc, HFCPCI_INT_S1);
 			Write_hfc(hc, HFCPCI_STATES, 4 | HFCPCI_LOAD_STATE);
 			udelay(10);
 			Write_hfc(hc, HFCPCI_STATES, 4);
@@ -1268,8 +1270,7 @@ mode_hfcpci(struct bchannel *bch, int bc, int protocol)
 		rx_slot = (bc>>8) & 0xff;
 		tx_slot = (bc>>16) & 0xff;
 		bc = bc & 0xff;
-	} else if (test_bit(HFC_CFG_PCM, &hc->cfg) &&
-	    (protocol > ISDN_P_NONE))
+	} else if (test_bit(HFC_CFG_PCM, &hc->cfg) && (protocol > ISDN_P_NONE))
 		printk(KERN_WARNING "%s: no pcm channel id but HFC_CFG_PCM\n",
 		    __func__);
 	if (hc->chanlimit > 1) {
@@ -1327,8 +1328,8 @@ mode_hfcpci(struct bchannel *bch, int bc, int protocol)
 	case (ISDN_P_B_RAW):
 		bch->state = protocol;
 		bch->nr = bc;
-		hfcpci_clear_fifo_rx(hc, (fifo2 & 2)?1:0);
-		hfcpci_clear_fifo_tx(hc, (fifo2 & 2)?1:0);
+		hfcpci_clear_fifo_rx(hc, (fifo2 & 2) ? 1 : 0);
+		hfcpci_clear_fifo_tx(hc, (fifo2 & 2) ? 1 : 0);
 		if (bc & 2) {
 			hc->hw.sctrl |= SCTRL_B2_ENA;
 			hc->hw.sctrl_r |= SCTRL_B2_ENA;
@@ -1362,8 +1363,8 @@ mode_hfcpci(struct bchannel *bch, int bc, int protocol)
 	case (ISDN_P_B_HDLC):
 		bch->state = protocol;
 		bch->nr = bc;
-		hfcpci_clear_fifo_rx(hc, (fifo2 & 2)?1:0);
-		hfcpci_clear_fifo_tx(hc, (fifo2 & 2)?1:0);
+		hfcpci_clear_fifo_rx(hc, (fifo2 & 2) ? 1 : 0);
+		hfcpci_clear_fifo_tx(hc, (fifo2 & 2) ? 1 : 0);
 		if (bc & 2) {
 			hc->hw.sctrl |= SCTRL_B2_ENA;
 			hc->hw.sctrl_r |= SCTRL_B2_ENA;
@@ -1457,7 +1458,7 @@ set_hfcpci_rxtest(struct bchannel *bch, int protocol, int chan)
 	switch (protocol) {
 	case (ISDN_P_B_RAW):
 		bch->state = protocol;
-		hfcpci_clear_fifo_rx(hc, (chan & 2)?1:0);
+		hfcpci_clear_fifo_rx(hc, (chan & 2) ? 1 : 0);
 		if (chan & 2) {
 			hc->hw.sctrl_r |= SCTRL_B2_ENA;
 			hc->hw.fifo_en |= HFCPCI_FIFOEN_B2RX;
@@ -1482,7 +1483,7 @@ set_hfcpci_rxtest(struct bchannel *bch, int protocol, int chan)
 		break;
 	case (ISDN_P_B_HDLC):
 		bch->state = protocol;
-		hfcpci_clear_fifo_rx(hc, (chan & 2)?1:0);
+		hfcpci_clear_fifo_rx(hc, (chan & 2) ? 1 : 0);
 		if (chan & 2) {
 			hc->hw.sctrl_r |= SCTRL_B2_ENA;
 			hc->hw.last_bfifo_cnt[1] = 0;
@@ -2047,7 +2048,8 @@ setup_hw(struct hfc_pci *hc)
 		printk(KERN_WARNING "HFC-PCI: No IRQ for PCI card found\n");
 		return 1;
 	}
-	hc->hw.pci_io = (char __iomem *)(unsigned long)hc->pdev->resource[1].start;
+	hc->hw.pci_io =
+		(char __iomem *)(unsigned long)hc->pdev->resource[1].start;
 
 	if (!hc->hw.pci_io) {
 		printk(KERN_WARNING "HFC-PCI: No IO-Mem for PCI card found\n");
@@ -2289,7 +2291,7 @@ hfc_remove_pci(struct pci_dev *pdev)
 		release_card(card);
 	else
 		if (debug)
-			printk(KERN_WARNING "%s: drvdata already removed\n",
+			printk(KERN_DEBUG "%s: drvdata already removed\n",
 			    __func__);
 }
 
diff --git a/drivers/isdn/mISDN/dsp_audio.c b/drivers/isdn/mISDN/dsp_audio.c
index de3795e..9c7c645 100644
--- a/drivers/isdn/mISDN/dsp_audio.c
+++ b/drivers/isdn/mISDN/dsp_audio.c
@@ -210,9 +210,8 @@ dsp_audio_generate_seven(void)
 		j = 0;
 		for (k = 0; k < 256; k++) {
 			if (dsp_audio_alaw_to_s32[k]
-				< dsp_audio_alaw_to_s32[i]) {
-			j++;
-			}
+			    < dsp_audio_alaw_to_s32[i])
+				j++;
 		}
 		sorted_alaw[j] = i;
 	}
diff --git a/drivers/isdn/mISDN/dsp_cmx.c b/drivers/isdn/mISDN/dsp_cmx.c
index 0586618..9c7c0d1 100644
--- a/drivers/isdn/mISDN/dsp_cmx.c
+++ b/drivers/isdn/mISDN/dsp_cmx.c
@@ -238,7 +238,7 @@ dsp_cmx_add_conf_member(struct dsp *dsp, struct dsp_conf *conf)
 
 	member = kzalloc(sizeof(struct dsp_conf_member), GFP_ATOMIC);
 	if (!member) {
-		printk(KERN_ERR "kmalloc struct dsp_conf_member failed\n");
+		printk(KERN_ERR "kzalloc struct dsp_conf_member failed\n");
 		return -ENOMEM;
 	}
 	member->dsp = dsp;
@@ -317,7 +317,7 @@ static struct dsp_conf
 
 	conf = kzalloc(sizeof(struct dsp_conf), GFP_ATOMIC);
 	if (!conf) {
-		printk(KERN_ERR "kmalloc struct dsp_conf failed\n");
+		printk(KERN_ERR "kzalloc struct dsp_conf failed\n");
 		return NULL;
 	}
 	INIT_LIST_HEAD(&conf->mlist);
@@ -1389,7 +1389,8 @@ dsp_cmx_send_member(struct dsp *dsp, int len, s32 *c, int members)
 		while (r != rr && t != tt) {
 #ifdef CMX_TX_DEBUG
 			if (strlen(debugbuf) < 48)
-			    sprintf(debugbuf+strlen(debugbuf), " %02x", p[t]);
+				sprintf(debugbuf+strlen(debugbuf), " %02x",
+				    p[t]);
 #endif
 			*d++ = p[t]; /* write tx_buff */
 			t = (t+1) & CMX_BUFF_MASK;
diff --git a/drivers/isdn/mISDN/dsp_core.c b/drivers/isdn/mISDN/dsp_core.c
index a0e0af8..c357506 100644
--- a/drivers/isdn/mISDN/dsp_core.c
+++ b/drivers/isdn/mISDN/dsp_core.c
@@ -280,7 +280,7 @@ dsp_fill_empty(struct dsp *dsp)
 static int
 dsp_control_req(struct dsp *dsp, struct mISDNhead *hh, struct sk_buff *skb)
 {
-	struct		sk_buff *nskb;
+	struct sk_buff	*nskb;
 	int ret = 0;
 	int cont;
 	u8 *data;
@@ -558,7 +558,7 @@ tone_off:
 			dsp->pipeline.inuse = 1;
 			dsp_cmx_hardware(dsp->conf, dsp);
 			ret = dsp_pipeline_build(&dsp->pipeline,
-				len > 0 ? (char *)data : NULL);
+				len > 0 ? data : NULL);
 			dsp_cmx_hardware(dsp->conf, dsp);
 			dsp_rx_off(dsp);
 		}
@@ -720,7 +720,7 @@ dsp_function(struct mISDNchannel *ch,  struct sk_buff *skb)
 		/* check if dtmf soft decoding is turned on */
 		if (dsp->dtmf.software) {
 			digits = dsp_dtmf_goertzel_decode(dsp, skb->data,
-				skb->len, (dsp_options&DSP_OPT_ULAW)?1:0);
+				skb->len, (dsp_options&DSP_OPT_ULAW) ? 1 : 0);
 		}
 		/* we need to process receive data if software */
 		if (dsp->conf && dsp->conf->software) {
@@ -952,7 +952,7 @@ dsp_ctrl(struct mISDNchannel *ch, u_int cmd, void *arg)
 	int		err = 0;
 
 	if (debug & DEBUG_DSP_CTRL)
-	printk(KERN_DEBUG "%s:(%x)\n", __func__, cmd);
+		printk(KERN_DEBUG "%s:(%x)\n", __func__, cmd);
 
 	switch (cmd) {
 	case OPEN_CHANNEL:
@@ -1175,9 +1175,9 @@ static int dsp_init(void)
 
 	/* init conversion tables */
 	dsp_audio_generate_law_tables();
-	dsp_silence = (dsp_options&DSP_OPT_ULAW)?0xff:0x2a;
-	dsp_audio_law_to_s32 = (dsp_options&DSP_OPT_ULAW)?dsp_audio_ulaw_to_s32:
-		dsp_audio_alaw_to_s32;
+	dsp_silence = (dsp_options&DSP_OPT_ULAW) ? 0xff : 0x2a;
+	dsp_audio_law_to_s32 = (dsp_options&DSP_OPT_ULAW) ?
+		dsp_audio_ulaw_to_s32 : dsp_audio_alaw_to_s32;
 	dsp_audio_generate_s2law_table();
 	dsp_audio_generate_seven();
 	dsp_audio_generate_mix_table();
diff --git a/drivers/isdn/mISDN/dsp_ecdis.h b/drivers/isdn/mISDN/dsp_ecdis.h
index 8a20af4..21dbd15 100644
--- a/drivers/isdn/mISDN/dsp_ecdis.h
+++ b/drivers/isdn/mISDN/dsp_ecdis.h
@@ -91,7 +91,7 @@ int16_t amp)
 					&& det->tone_cycle_duration <= 475*8) {
 					det->good_cycles++;
 					if (det->good_cycles > 2)
-					det->hit = TRUE;
+						det->hit = TRUE;
 				}
 				det->tone_cycle_duration = 0;
 			}
diff --git a/drivers/isdn/mISDN/dsp_tones.c b/drivers/isdn/mISDN/dsp_tones.c
index 7a9af66..1debf53 100644
--- a/drivers/isdn/mISDN/dsp_tones.c
+++ b/drivers/isdn/mISDN/dsp_tones.c
@@ -253,18 +253,24 @@ static struct pattern {
 	{8000, 0, 0, 0, 0, 0, 0, 0, 0, 0} },
 
 	{TONE_GERMAN_DIALPBX,
-	{DATA_GA, DATA_S, DATA_GA, DATA_S, DATA_GA, DATA_S, NULL, NULL, NULL, NULL},
-	{SIZE_GA, SIZE_S, SIZE_GA, SIZE_S, SIZE_GA, SIZE_S, NULL, NULL, NULL, NULL},
+	{DATA_GA, DATA_S, DATA_GA, DATA_S, DATA_GA, DATA_S, NULL, NULL, NULL,
+		NULL},
+	{SIZE_GA, SIZE_S, SIZE_GA, SIZE_S, SIZE_GA, SIZE_S, NULL, NULL, NULL,
+		NULL},
 	{2000, 2000, 2000, 2000, 2000, 12000, 0, 0, 0, 0} },
 
 	{TONE_GERMAN_OLDDIALPBX,
-	{DATA_GO, DATA_S, DATA_GO, DATA_S, DATA_GO, DATA_S, NULL, NULL, NULL, NULL},
-	{SIZE_GO, SIZE_S, SIZE_GO, SIZE_S, SIZE_GO, SIZE_S, NULL, NULL, NULL, NULL},
+	{DATA_GO, DATA_S, DATA_GO, DATA_S, DATA_GO, DATA_S, NULL, NULL, NULL,
+		NULL},
+	{SIZE_GO, SIZE_S, SIZE_GO, SIZE_S, SIZE_GO, SIZE_S, NULL, NULL, NULL,
+		NULL},
 	{2000, 2000, 2000, 2000, 2000, 12000, 0, 0, 0, 0} },
 
 	{TONE_AMERICAN_DIALPBX,
-	{DATA_DT, DATA_S, DATA_DT, DATA_S, DATA_DT, DATA_S, NULL, NULL, NULL, NULL},
-	{SIZE_DT, SIZE_S, SIZE_DT, SIZE_S, SIZE_DT, SIZE_S, NULL, NULL, NULL, NULL},
+	{DATA_DT, DATA_S, DATA_DT, DATA_S, DATA_DT, DATA_S, NULL, NULL, NULL,
+		NULL},
+	{SIZE_DT, SIZE_S, SIZE_DT, SIZE_S, SIZE_DT, SIZE_S, NULL, NULL, NULL,
+		NULL},
 	{2000, 2000, 2000, 2000, 2000, 12000, 0, 0, 0, 0} },
 
 	{TONE_GERMAN_RINGING,
@@ -434,7 +440,7 @@ dsp_tone_hw_message(struct dsp *dsp, u8 *sample, int len)
 
 	/* unlocking is not required, because we don't expect a response */
 	nskb = _alloc_mISDN_skb(PH_CONTROL_REQ,
-		(len)?HFC_SPL_LOOP_ON:HFC_SPL_LOOP_OFF, len, sample,
+		(len) ? HFC_SPL_LOOP_ON : HFC_SPL_LOOP_OFF, len, sample,
 		GFP_ATOMIC);
 	if (nskb) {
 		if (dsp->ch.peer) {
@@ -498,8 +504,7 @@ dsp_tone(struct dsp *dsp, int tone)
 
 	/* we turn off the tone */
 	if (!tone) {
-		if (dsp->features.hfc_loops)
-		if (timer_pending(&tonet->tl))
+		if (dsp->features.hfc_loops && timer_pending(&tonet->tl))
 			del_timer(&tonet->tl);
 		if (dsp->features.hfc_loops)
 			dsp_tone_hw_message(dsp, NULL, 0);
diff --git a/drivers/isdn/mISDN/l1oip_core.c b/drivers/isdn/mISDN/l1oip_core.c
index ea3c3aa..d9cf83b 100644
--- a/drivers/isdn/mISDN/l1oip_core.c
+++ b/drivers/isdn/mISDN/l1oip_core.c
@@ -308,8 +308,8 @@ l1oip_socket_send(struct l1oip *hc, u8 localcodec, u8 channel, u32 chanmask,
 
 	/* assemble frame */
 	*p++ = (L1OIP_VERSION<<6) /* version and coding */
-	     | (hc->pri?0x20:0x00) /* type */
-	     | (hc->id?0x10:0x00) /* id */
+	     | (hc->pri ? 0x20 : 0x00) /* type */
+	     | (hc->id ? 0x10 : 0x00) /* id */
 	     | localcodec;
 	if (hc->id) {
 		*p++ = hc->id>>24; /* id */
@@ -317,7 +317,7 @@ l1oip_socket_send(struct l1oip *hc, u8 localcodec, u8 channel, u32 chanmask,
 		*p++ = hc->id>>8;
 		*p++ = hc->id;
 	}
-	*p++ = (multi == 1)?0x80:0x00 + channel; /* m-flag, channel */
+	*p++ = (multi == 1) ? 0x80 : 0x00 + channel; /* m-flag, channel */
 	if (multi == 1)
 		*p++ = len; /* length */
 	*p++ = timebase>>8; /* time base */
@@ -401,12 +401,12 @@ l1oip_socket_recv(struct l1oip *hc, u8 remotecodec, u8 channel, u16 timebase,
 	}
 
 	/* prepare message */
-	nskb = mI_alloc_skb((remotecodec == 3)?(len<<1):len, GFP_ATOMIC);
+	nskb = mI_alloc_skb((remotecodec == 3) ? (len<<1) : len, GFP_ATOMIC);
 	if (!nskb) {
 		printk(KERN_ERR "%s: No mem for skb.\n", __func__);
 		return;
 	}
-	p = skb_put(nskb, (remotecodec == 3)?(len<<1):len);
+	p = skb_put(nskb, (remotecodec == 3) ? (len<<1) : len);
 
 	if (remotecodec == 1 && ulaw)
 		l1oip_alaw_to_ulaw(buf, len, p);
@@ -458,7 +458,7 @@ l1oip_socket_recv(struct l1oip *hc, u8 remotecodec, u8 channel, u16 timebase,
 		hc->chan[channel].disorder_flag ^= 1;
 		if (nskb)
 #endif
-		queue_ch_frame(&bch->ch, PH_DATA_IND, rx_counter, nskb);
+			queue_ch_frame(&bch->ch, PH_DATA_IND, rx_counter, nskb);
 	}
 }
 
@@ -749,8 +749,8 @@ l1oip_socket_thread(void *data)
 			l1oip_socket_parse(hc, &sin_rx, recvbuf, recvlen);
 		} else {
 			if (debug & DEBUG_L1OIP_SOCKET)
-			    printk(KERN_WARNING "%s: broken pipe on socket\n",
-				__func__);
+				printk(KERN_WARNING
+				    "%s: broken pipe on socket\n", __func__);
 		}
 	}
 
@@ -925,7 +925,7 @@ handle_dmsg(struct mISDNchannel *ch, struct sk_buff *skb)
 		p = skb->data;
 		l = skb->len;
 		while (l) {
-			ll = (l < L1OIP_MAX_PERFRAME)?l:L1OIP_MAX_PERFRAME;
+			ll = (l < L1OIP_MAX_PERFRAME) ? l : L1OIP_MAX_PERFRAME;
 			l1oip_socket_send(hc, 0, dch->slot, 0,
 				hc->chan[dch->slot].tx_counter++, p, ll);
 			p += ll;
@@ -1173,7 +1173,7 @@ handle_bmsg(struct mISDNchannel *ch, struct sk_buff *skb)
 		p = skb->data;
 		l = skb->len;
 		while (l) {
-			ll = (l < L1OIP_MAX_PERFRAME)?l:L1OIP_MAX_PERFRAME;
+			ll = (l < L1OIP_MAX_PERFRAME) ? l : L1OIP_MAX_PERFRAME;
 			l1oip_socket_send(hc, hc->codec, bch->slot, 0,
 				hc->chan[bch->slot].tx_counter, p, ll);
 			hc->chan[bch->slot].tx_counter += ll;
@@ -1331,8 +1331,8 @@ init_card(struct l1oip *hc, int pri, int bundle)
 	spin_lock_init(&hc->socket_lock);
 	hc->idx = l1oip_cnt;
 	hc->pri = pri;
-	hc->d_idx = pri?16:3;
-	hc->b_num = pri?30:2;
+	hc->d_idx = pri ? 16 : 3;
+	hc->b_num = pri ? 30 : 2;
 	hc->bundle = bundle;
 	if (hc->pri)
 		sprintf(hc->name, "l1oip-e1.%d", l1oip_cnt + 1);
@@ -1517,9 +1517,9 @@ l1oip_init(void)
 
 		if (debug & DEBUG_L1OIP_INIT)
 			printk(KERN_DEBUG "%s: interface %d is %s with %s.\n",
-				__func__, l1oip_cnt, pri?"PRI":"BRI",
-				bundle?"bundled IP packet for all B-channels"
-				 :"seperate IP packets for every B-channel");
+			    __func__, l1oip_cnt, pri ? "PRI" : "BRI",
+			    bundle ? "bundled IP packet for all B-channels" :
+			    "seperate IP packets for every B-channel");
 
 		hc = kzalloc(sizeof(struct l1oip), GFP_ATOMIC);
 		if (!hc) {
diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index 2a2c30a..c36f521 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -222,7 +222,7 @@ mISDN_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 	} else { /* use default for L2 messages */
 		if ((sk->sk_protocol == ISDN_P_LAPD_TE) ||
 		    (sk->sk_protocol == ISDN_P_LAPD_NT))
-		    mISDN_HEAD_ID(skb) = _pms(sk)->ch.nr;
+			mISDN_HEAD_ID(skb) = _pms(sk)->ch.nr;
 	}
 
 	if (*debug & DEBUG_SOCKET)
diff --git a/drivers/isdn/mISDN/tei.c b/drivers/isdn/mISDN/tei.c
index 4ebba5c..d5dcf07 100644
--- a/drivers/isdn/mISDN/tei.c
+++ b/drivers/isdn/mISDN/tei.c
@@ -871,7 +871,6 @@ ph_data_ind(struct manager *mgr, struct sk_buff *skb)
 			    __func__, skb->len);
 		goto done;
 	}
-	if (*debug  & DEBUG_L2_TEI)
 
 	if ((skb->data[0] >> 2) != TEI_SAPI) /* not for us */
 		goto done;
diff --git a/drivers/isdn/mISDN/timerdev.c b/drivers/isdn/mISDN/timerdev.c
index bbd99d3..5b7e9bf 100644
--- a/drivers/isdn/mISDN/timerdev.c
+++ b/drivers/isdn/mISDN/timerdev.c
@@ -259,7 +259,7 @@ mISDN_ioctl(struct inode *inode, struct file *filep, unsigned int cmd,
 	return ret;
 }
 
-static struct file_operations mISDN_fops = {
+static const struct file_operations mISDN_fops = {
 	.read		= mISDN_read,
 	.poll		= mISDN_poll,
 	.ioctl		= mISDN_ioctl,
diff --git a/include/linux/mISDNif.h b/include/linux/mISDNif.h
index 0b28fd1..45100b3 100644
--- a/include/linux/mISDNif.h
+++ b/include/linux/mISDNif.h
@@ -292,19 +292,19 @@ struct mISDN_devrename {
 
 /* MPH_INFORMATION_REQ payload */
 struct ph_info_ch {
-        __u32 protocol;
-        __u64 Flags;
+	__u32 protocol;
+	__u64 Flags;
 };
 
 struct ph_info_dch {
-        struct ph_info_ch ch;
-        __u16 state;
-        __u16 num_bch;
+	struct ph_info_ch ch;
+	__u16 state;
+	__u16 num_bch;
 };
 
 struct ph_info {
-        struct ph_info_dch dch;
-        struct ph_info_ch  bch[];
+	struct ph_info_dch dch;
+	struct ph_info_ch  bch[];
 };
 
 /* timer device ioctl */
-- 
1.6.0.2
