From: Joe Perches <joe@perches.com>
Subject: [PATCH] drivers/isdn/hisax: Add printf format/argument verification and fix fallout
Date: Wed, 10 Nov 2010 20:54:58 -0800
Message-ID: <f92d95e7dc0afca09c2d76880b76973e4eafb169.1289451201.git.joe@perches.com>
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4968 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932340Ab0KKEzD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Nov 2010 23:55:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add __attribute__((format... to several functins
Make formats and arguments match.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/isdn/hisax/avm_pci.c   |    2 +-
 drivers/isdn/hisax/callc.c     |    4 ++--
 drivers/isdn/hisax/hfc_2bds0.c |    4 ++--
 drivers/isdn/hisax/hfc_2bs0.c  |    2 +-
 drivers/isdn/hisax/hfc_pci.c   |    4 ++--
 drivers/isdn/hisax/hfc_sx.c    |    6 +++---
 drivers/isdn/hisax/hisax.h     |    2 ++
 drivers/isdn/hisax/ipacx.c     |    2 +-
 drivers/isdn/hisax/isar.c      |    6 +++---
 drivers/isdn/hisax/isdnl1.h    |    1 +
 drivers/isdn/hisax/isdnl3.c    |    2 +-
 drivers/isdn/hisax/netjet.c    |   10 +++++-----
 drivers/isdn/hisax/st5481_d.c  |    6 ++++--
 13 files changed, 28 insertions(+), 23 deletions(-)

diff --git a/drivers/isdn/hisax/avm_pci.c b/drivers/isdn/hisax/avm_pci.c
index fcf4ed1..0e66af1 100644
--- a/drivers/isdn/hisax/avm_pci.c
+++ b/drivers/isdn/hisax/avm_pci.c
@@ -314,7 +314,7 @@ hdlc_fill_fifo(struct BCState *bcs)
 			bcs->hw.hdlc.ctrl.sr.cmd |= HDLC_CMD_XME;
 	}
 	if ((cs->debug & L1_DEB_HSCX) && !(cs->debug & L1_DEB_HSCX_FIFO))
-		debugl1(cs, "hdlc_fill_fifo %d/%ld", count, bcs->tx_skb->len);
+		debugl1(cs, "hdlc_fill_fifo %d/%u", count, bcs->tx_skb->len);
 	p = bcs->tx_skb->data;
 	ptr = (u_int *)p;
 	skb_pull(bcs->tx_skb, count);
diff --git a/drivers/isdn/hisax/callc.c b/drivers/isdn/hisax/callc.c
index f150330..37e685e 100644
--- a/drivers/isdn/hisax/callc.c
+++ b/drivers/isdn/hisax/callc.c
@@ -65,7 +65,7 @@ hisax_findcard(int driverid)
 	return (struct IsdnCardState *) 0;
 }
 
-static void
+static __attribute__((format(printf, 3, 4))) void
 link_debug(struct Channel *chanp, int direction, char *fmt, ...)
 {
 	va_list args;
@@ -1068,7 +1068,7 @@ init_d_st(struct Channel *chanp)
 	return 0;
 }
 
-static void
+static __attribute__((format(printf, 2, 3))) void
 callc_debug(struct FsmInst *fi, char *fmt, ...)
 {
 	va_list args;
diff --git a/drivers/isdn/hisax/hfc_2bds0.c b/drivers/isdn/hisax/hfc_2bds0.c
index 7250f56..a16459a 100644
--- a/drivers/isdn/hisax/hfc_2bds0.c
+++ b/drivers/isdn/hisax/hfc_2bds0.c
@@ -292,7 +292,7 @@ hfc_fill_fifo(struct BCState *bcs)
 	}
 	count = GetFreeFifoBytes_B(bcs);
 	if (cs->debug & L1_DEB_HSCX)
-		debugl1(cs, "hfc_fill_fifo %d count(%ld/%d),%lx",
+		debugl1(cs, "hfc_fill_fifo %d count(%u/%d),%lx",
 			bcs->channel, bcs->tx_skb->len,
 			count, current->state);
 	if (count < bcs->tx_skb->len) {
@@ -719,7 +719,7 @@ hfc_fill_dfifo(struct IsdnCardState *cs)
 	}
 	count = GetFreeFifoBytes_D(cs);
 	if (cs->debug & L1_DEB_ISAC)
-		debugl1(cs, "hfc_fill_Dfifo count(%ld/%d)",
+		debugl1(cs, "hfc_fill_Dfifo count(%u/%d)",
 			cs->tx_skb->len, count);
 	if (count < cs->tx_skb->len) {
 		if (cs->debug & L1_DEB_ISAC)
diff --git a/drivers/isdn/hisax/hfc_2bs0.c b/drivers/isdn/hisax/hfc_2bs0.c
index b1f6481..626f85d 100644
--- a/drivers/isdn/hisax/hfc_2bs0.c
+++ b/drivers/isdn/hisax/hfc_2bs0.c
@@ -282,7 +282,7 @@ hfc_fill_fifo(struct BCState *bcs)
 	    count += cs->hw.hfc.fifosize; 
 	} /* L1_MODE_TRANS */
 	if (cs->debug & L1_DEB_HSCX)
-		debugl1(cs, "hfc_fill_fifo %d count(%ld/%d)",
+		debugl1(cs, "hfc_fill_fifo %d count(%u/%d)",
 			bcs->channel, bcs->tx_skb->len,
 			count);
 	if (count < bcs->tx_skb->len) {
diff --git a/drivers/isdn/hisax/hfc_pci.c b/drivers/isdn/hisax/hfc_pci.c
index 917cc84..3147020 100644
--- a/drivers/isdn/hisax/hfc_pci.c
+++ b/drivers/isdn/hisax/hfc_pci.c
@@ -550,7 +550,7 @@ hfcpci_fill_dfifo(struct IsdnCardState *cs)
 		count += D_FIFO_SIZE;	/* count now contains available bytes */
 
 	if (cs->debug & L1_DEB_ISAC)
-		debugl1(cs, "hfcpci_fill_Dfifo count(%ld/%d)",
+		debugl1(cs, "hfcpci_fill_Dfifo count(%u/%d)",
 			cs->tx_skb->len, count);
 	if (count < cs->tx_skb->len) {
 		if (cs->debug & L1_DEB_ISAC)
@@ -681,7 +681,7 @@ hfcpci_fill_fifo(struct BCState *bcs)
 		count += B_FIFO_SIZE;	/* count now contains available bytes */
 
 	if (cs->debug & L1_DEB_HSCX)
-		debugl1(cs, "hfcpci_fill_fifo %d count(%ld/%d),%lx",
+		debugl1(cs, "hfcpci_fill_fifo %d count(%u/%d),%lx",
 			bcs->channel, bcs->tx_skb->len,
 			count, current->state);
 
diff --git a/drivers/isdn/hisax/hfc_sx.c b/drivers/isdn/hisax/hfc_sx.c
index 5aa138e..1235b71 100644
--- a/drivers/isdn/hisax/hfc_sx.c
+++ b/drivers/isdn/hisax/hfc_sx.c
@@ -179,7 +179,7 @@ write_fifo(struct IsdnCardState *cs, struct sk_buff *skb, u_char fifo, int trans
 	  count += fifo_size;	/* count now contains available bytes */
 
 	if (cs->debug & L1_DEB_ISAC_FIFO)
-	  debugl1(cs, "hfcsx_write_fifo %d count(%ld/%d)",
+	  debugl1(cs, "hfcsx_write_fifo %d count(%u/%d)",
 		  fifo, skb->len, count);
 	if (count < skb->len) {
 	  if (cs->debug & L1_DEB_ISAC_FIFO)
@@ -265,7 +265,7 @@ read_fifo(struct IsdnCardState *cs, u_char fifo, int trans_max)
 	  count++;
 
 	  if (cs->debug & L1_DEB_ISAC_FIFO)
-	    debugl1(cs, "hfcsx_read_fifo %d count %ld)",
+	    debugl1(cs, "hfcsx_read_fifo %d count %u)",
 		    fifo, count);
 
 	  if ((count > fifo_size) || (count < 4)) {
@@ -986,7 +986,7 @@ HFCSX_l1hw(struct PStack *st, int pr, void *arg)
 				default:
 					spin_unlock_irqrestore(&cs->lock, flags);
 					if (cs->debug & L1_DEB_WARN)
-						debugl1(cs, "hfcsx_l1hw loop invalid %4lx", arg);
+						debugl1(cs, "hfcsx_l1hw loop invalid %4lx", (unsigned long)arg);
 					return;
 			}
 			cs->hw.hfcsx.trm |= 0x80;	/* enable IOM-loop */
diff --git a/drivers/isdn/hisax/hisax.h b/drivers/isdn/hisax/hisax.h
index 32ab392..de1c669 100644
--- a/drivers/isdn/hisax/hisax.h
+++ b/drivers/isdn/hisax/hisax.h
@@ -1286,7 +1286,9 @@ int jiftime(char *s, long mark);
 
 int HiSax_command(isdn_ctrl * ic);
 int HiSax_writebuf_skb(int id, int chan, int ack, struct sk_buff *skb);
+__attribute__((format(printf, 3, 4)))
 void HiSax_putstatus(struct IsdnCardState *cs, char *head, char *fmt, ...);
+__attribute__((format(printf, 3, 0)))
 void VHiSax_putstatus(struct IsdnCardState *cs, char *head, char *fmt, va_list args);
 void HiSax_reportcard(int cardnr, int sel);
 int QuickHex(char *txt, u_char * p, int cnt);
diff --git a/drivers/isdn/hisax/ipacx.c b/drivers/isdn/hisax/ipacx.c
index 751b25f..3321041 100644
--- a/drivers/isdn/hisax/ipacx.c
+++ b/drivers/isdn/hisax/ipacx.c
@@ -717,7 +717,7 @@ bch_mode(struct BCState *bcs, int mode, int bc)
 
         bc = bc ? 1 : 0;  // in case bc is greater than 1
 	if (cs->debug & L1_DEB_HSCX)
-		debugl1(cs, "mode_bch() switch B-% mode %d chan %d", hscx, mode, bc);
+		debugl1(cs, "mode_bch() switch B-%d mode %d chan %d", hscx, mode, bc);
 	bcs->mode = mode;
 	bcs->channel = bc;
   
diff --git a/drivers/isdn/hisax/isar.c b/drivers/isdn/hisax/isar.c
index 2e72227..1be4552 100644
--- a/drivers/isdn/hisax/isar.c
+++ b/drivers/isdn/hisax/isar.c
@@ -953,7 +953,7 @@ isar_pump_statev_modem(struct BCState *bcs, u_char devt) {
 			break;
 		case PSEV_GSTN_CLR:
 			if (cs->debug & L1_DEB_HSCX)
-				debugl1(cs, "pump stev GSTN CLEAR", devt);
+				debugl1(cs, "pump stev GSTN CLEAR");
 			break;
 		default:
 			if (cs->debug & L1_DEB_HSCX)
@@ -1268,7 +1268,7 @@ isar_int_main(struct IsdnCardState *cs)
 static void
 ftimer_handler(struct BCState *bcs) {
 	if (bcs->cs->debug)
-		debugl1(bcs->cs, "ftimer flags %04x",
+		debugl1(bcs->cs, "ftimer flags %04lx",
 			bcs->Flag);
 	test_and_clear_bit(BC_FLG_FTI_RUN, &bcs->Flag);
 	if (test_and_clear_bit(BC_FLG_LL_CONN, &bcs->Flag)) {
@@ -1748,7 +1748,7 @@ isar_auxcmd(struct IsdnCardState *cs, isdn_ctrl *ic) {
 	struct BCState *bcs;
 
 	if (cs->debug & L1_DEB_HSCX)
-		debugl1(cs, "isar_auxcmd cmd/ch %x/%d", ic->command, ic->arg);
+		debugl1(cs, "isar_auxcmd cmd/ch %x/%ld", ic->command, ic->arg);
 	switch (ic->command) {
 		case (ISDN_CMD_FAXCMD):
 			bcs = cs->channel[ic->arg].bcs;
diff --git a/drivers/isdn/hisax/isdnl1.h b/drivers/isdn/hisax/isdnl1.h
index 172ad4c..425d861 100644
--- a/drivers/isdn/hisax/isdnl1.h
+++ b/drivers/isdn/hisax/isdnl1.h
@@ -21,6 +21,7 @@
 #define B_XMTBUFREADY	1
 #define B_ACKPENDING	2
 
+__attribute__((format(printf, 2, 3)))
 void debugl1(struct IsdnCardState *cs, char *fmt, ...);
 void DChannel_proc_xmt(struct IsdnCardState *cs);
 void DChannel_proc_rcv(struct IsdnCardState *cs);
diff --git a/drivers/isdn/hisax/isdnl3.c b/drivers/isdn/hisax/isdnl3.c
index fd0b643..ad291f2 100644
--- a/drivers/isdn/hisax/isdnl3.c
+++ b/drivers/isdn/hisax/isdnl3.c
@@ -66,7 +66,7 @@ static char *strL3Event[] =
 	"EV_TIMEOUT",
 };
 
-static void
+static __attribute__((format(printf, 2, 3))) void
 l3m_debug(struct FsmInst *fi, char *fmt, ...)
 {
 	va_list args;
diff --git a/drivers/isdn/hisax/netjet.c b/drivers/isdn/hisax/netjet.c
index 5d7f0f2..644891e 100644
--- a/drivers/isdn/hisax/netjet.c
+++ b/drivers/isdn/hisax/netjet.c
@@ -254,7 +254,7 @@ static int make_raw_data(struct BCState *bcs) {
 		val >>= 1;
 	}
 	if (bcs->cs->debug & L1_DEB_HSCX)
-		debugl1(bcs->cs,"tiger make_raw: in %ld out %d.%d",
+		debugl1(bcs->cs,"tiger make_raw: in %u out %d.%d",
 			bcs->tx_skb->len, s_cnt, bitcnt);
 	if (bitcnt) {
 		while (8>bitcnt++) {
@@ -361,7 +361,7 @@ static int make_raw_data_56k(struct BCState *bcs) {
 		val >>= 1;
 	}
 	if (bcs->cs->debug & L1_DEB_HSCX)
-		debugl1(bcs->cs,"tiger make_raw_56k: in %ld out %d.%d",
+		debugl1(bcs->cs,"tiger make_raw_56k: in %u out %d.%d",
 			bcs->tx_skb->len, s_cnt, bitcnt);
 	if (bitcnt) {
 		while (8>bitcnt++) {
@@ -612,7 +612,7 @@ void netjet_fill_dma(struct BCState *bcs)
 	if (!bcs->tx_skb)
 		return;
 	if (bcs->cs->debug & L1_DEB_HSCX)
-		debugl1(bcs->cs,"tiger fill_dma1: c%d %4x", bcs->channel,
+		debugl1(bcs->cs,"tiger fill_dma1: c%d %4lx", bcs->channel,
 			bcs->Flag);
 	if (test_and_set_bit(BC_FLG_BUSY, &bcs->Flag))
 		return;
@@ -625,7 +625,7 @@ void netjet_fill_dma(struct BCState *bcs)
 			return;		
 	};
 	if (bcs->cs->debug & L1_DEB_HSCX)
-		debugl1(bcs->cs,"tiger fill_dma2: c%d %4x", bcs->channel,
+		debugl1(bcs->cs,"tiger fill_dma2: c%d %4lx", bcs->channel,
 			bcs->Flag);
 	if (test_and_clear_bit(BC_FLG_NOFRAME, &bcs->Flag)) {
 		write_raw(bcs, bcs->hw.tiger.sendp, bcs->hw.tiger.free);
@@ -667,7 +667,7 @@ void netjet_fill_dma(struct BCState *bcs)
 		write_raw(bcs, p, cnt);
 	}
 	if (bcs->cs->debug & L1_DEB_HSCX)
-		debugl1(bcs->cs,"tiger fill_dma3: c%d %4x", bcs->channel,
+		debugl1(bcs->cs,"tiger fill_dma3: c%d %4lx", bcs->channel,
 			bcs->Flag);
 }
 
diff --git a/drivers/isdn/hisax/st5481_d.c b/drivers/isdn/hisax/st5481_d.c
index b7876b1..4408263 100644
--- a/drivers/isdn/hisax/st5481_d.c
+++ b/drivers/isdn/hisax/st5481_d.c
@@ -167,7 +167,8 @@ static struct FsmNode L1FnList[] __initdata =
 	{ST_L1_F8, EV_IND_RSY,           l1_ignore},
 };
 
-static void l1m_debug(struct FsmInst *fi, char *fmt, ...)
+static __attribute__((format(printf, 2, 3)))
+void l1m_debug(struct FsmInst *fi, char *fmt, ...)
 {
 	va_list args;
 	char buf[256];
@@ -269,7 +270,8 @@ static char *strDoutEvent[] =
 	"EV_DOUT_UNDERRUN",
 };
 
-static void dout_debug(struct FsmInst *fi, char *fmt, ...)
+static __attribute__((format(printf, 2, 3)))
+void dout_debug(struct FsmInst *fi, char *fmt, ...)
 {
 	va_list args;
 	char buf[256];
-- 
1.7.3.1.g432b3.dirty

