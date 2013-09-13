From: akpm@linux-foundation.org
Subject: [patch 4/4] isdn: clean up debug format string usage
Date: Fri, 13 Sep 2013 14:52:04 -0700
Message-ID: <20130913215204.CD6C031C1FB@corp2gmr1-1.hot.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ASCII
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	keescook@chromium.org, isdn@linux-pingi.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f202.google.com ([209.85.216.202]:43960 "EHLO
	mail-qc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755360Ab3IMVwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 17:52:06 -0400
Received: by mail-qc0-f202.google.com with SMTP id r5so228584qcx.1
        for <netdev@vger.kernel.org>; Fri, 13 Sep 2013 14:52:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kees Cook <keescook@chromium.org>
Subject: isdn: clean up debug format string usage

Avoid unneeded local string buffers for constructing debug output.  Also
cleans up debug calls that contain a single parameter so that they cannot
be accidentally parsed as format strings.

Signed-off-by: Kees Cook <keescook@chromium.org>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/hisax/amd7930_fn.c |    4 +-
 drivers/isdn/hisax/avm_pci.c    |    4 +-
 drivers/isdn/hisax/config.c     |    2 -
 drivers/isdn/hisax/diva.c       |    4 +-
 drivers/isdn/hisax/elsa.c       |    2 -
 drivers/isdn/hisax/elsa_ser.c   |    2 -
 drivers/isdn/hisax/hfc_pci.c    |    2 -
 drivers/isdn/hisax/hfc_sx.c     |    2 -
 drivers/isdn/hisax/hscx_irq.c   |    4 +-
 drivers/isdn/hisax/icc.c        |    4 +-
 drivers/isdn/hisax/ipacx.c      |    8 ++--
 drivers/isdn/hisax/isac.c       |    4 +-
 drivers/isdn/hisax/isar.c       |    6 +--
 drivers/isdn/hisax/jade.c       |   18 +++-------
 drivers/isdn/hisax/jade_irq.c   |    4 +-
 drivers/isdn/hisax/l3_1tr6.c    |   50 ++++++++++--------------------
 drivers/isdn/hisax/netjet.c     |    2 -
 drivers/isdn/hisax/q931.c       |    6 +--
 drivers/isdn/hisax/w6692.c      |    8 ++--
 19 files changed, 57 insertions(+), 79 deletions(-)

diff -puN drivers/isdn/hisax/amd7930_fn.c~isdn-clean-up-debug-format-string-usage drivers/isdn/hisax/amd7930_fn.c
--- a/drivers/isdn/hisax/amd7930_fn.c~isdn-clean-up-debug-format-string-usage
+++ a/drivers/isdn/hisax/amd7930_fn.c
@@ -314,7 +314,7 @@ Amd7930_empty_Dfifo(struct IsdnCardState
 
 							t += sprintf(t, "Amd7930: empty_Dfifo cnt: %d |", cs->rcvidx);
 							QuickHex(t, cs->rcvbuf, cs->rcvidx);
-							debugl1(cs, cs->dlog);
+							debugl1(cs, "%s", cs->dlog);
 						}
 						/* moves received data in sk-buffer */
 						memcpy(skb_put(skb, cs->rcvidx), cs->rcvbuf, cs->rcvidx);
@@ -406,7 +406,7 @@ Amd7930_fill_Dfifo(struct IsdnCardState
 
 		t += sprintf(t, "Amd7930: fill_Dfifo cnt: %d |", count);
 		QuickHex(t, deb_ptr, count);
-		debugl1(cs, cs->dlog);
+		debugl1(cs, "%s", cs->dlog);
 	}
 	/* AMD interrupts on */
 	AmdIrqOn(cs);
diff -puN drivers/isdn/hisax/avm_pci.c~isdn-clean-up-debug-format-string-usage drivers/isdn/hisax/avm_pci.c
--- a/drivers/isdn/hisax/avm_pci.c~isdn-clean-up-debug-format-string-usage
+++ a/drivers/isdn/hisax/avm_pci.c
@@ -285,7 +285,7 @@ hdlc_empty_fifo(struct BCState *bcs, int
 		t += sprintf(t, "hdlc_empty_fifo %c cnt %d",
 			     bcs->channel ? 'B' : 'A', count);
 		QuickHex(t, p, count);
-		debugl1(cs, bcs->blog);
+		debugl1(cs, "%s", bcs->blog);
 	}
 }
 
@@ -345,7 +345,7 @@ hdlc_fill_fifo(struct BCState *bcs)
 		t += sprintf(t, "hdlc_fill_fifo %c cnt %d",
 			     bcs->channel ? 'B' : 'A', count);
 		QuickHex(t, p, count);
-		debugl1(cs, bcs->blog);
+		debugl1(cs, "%s", bcs->blog);
 	}
 }
 
diff -puN drivers/isdn/hisax/config.c~isdn-clean-up-debug-format-string-usage drivers/isdn/hisax/config.c
--- a/drivers/isdn/hisax/config.c~isdn-clean-up-debug-format-string-usage
+++ a/drivers/isdn/hisax/config.c
@@ -1896,7 +1896,7 @@ static void EChannel_proc_rcv(struct his
 				ptr--;
 				*ptr++ = '\n';
 				*ptr = 0;
-				HiSax_putstatus(cs, NULL, cs->dlog);
+				HiSax_putstatus(cs, NULL, "%s", cs->dlog);
 			} else
 				HiSax_putstatus(cs, "LogEcho: ",
 						"warning Frame too big (%d)",
diff -puN drivers/isdn/hisax/diva.c~isdn-clean-up-debug-format-string-usage drivers/isdn/hisax/diva.c
--- a/drivers/isdn/hisax/diva.c~isdn-clean-up-debug-format-string-usage
+++ a/drivers/isdn/hisax/diva.c
@@ -427,7 +427,7 @@ Memhscx_empty_fifo(struct BCState *bcs,
 		t += sprintf(t, "hscx_empty_fifo %c cnt %d",
 			     bcs->hw.hscx.hscx ? 'B' : 'A', count);
 		QuickHex(t, ptr, count);
-		debugl1(cs, bcs->blog);
+		debugl1(cs, "%s", bcs->blog);
 	}
 }
 
@@ -469,7 +469,7 @@ Memhscx_fill_fifo(struct BCState *bcs)
 		t += sprintf(t, "hscx_fill_fifo %c cnt %d",
 			     bcs->hw.hscx.hscx ? 'B' : 'A', count);
 		QuickHex(t, ptr, count);
-		debugl1(cs, bcs->blog);
+		debugl1(cs, "%s", bcs->blog);
 	}
 }
 
diff -puN drivers/isdn/hisax/elsa.c~isdn-clean-up-debug-format-string-usage drivers/isdn/hisax/elsa.c
--- a/drivers/isdn/hisax/elsa.c~isdn-clean-up-debug-format-string-usage
+++ a/drivers/isdn/hisax/elsa.c
@@ -535,7 +535,7 @@ check_arcofi(struct IsdnCardState *cs)
 		t = tmp;
 		t += sprintf(tmp, "Arcofi data");
 		QuickHex(t, p, cs->dc.isac.mon_rxp);
-		debugl1(cs, tmp);
+		debugl1(cs, "%s", tmp);
 		if ((cs->dc.isac.mon_rxp == 2) && (cs->dc.isac.mon_rx[0] == 0xa0)) {
 			switch (cs->dc.isac.mon_rx[1]) {
 			case 0x80:
diff -puN drivers/isdn/hisax/elsa_ser.c~isdn-clean-up-debug-format-string-usage drivers/isdn/hisax/elsa_ser.c
--- a/drivers/isdn/hisax/elsa_ser.c~isdn-clean-up-debug-format-string-usage
+++ a/drivers/isdn/hisax/elsa_ser.c
@@ -344,7 +344,7 @@ static inline void receive_chars(struct
 
 		t += sprintf(t, "modem read cnt %d", cs->hw.elsa.rcvcnt);
 		QuickHex(t, cs->hw.elsa.rcvbuf, cs->hw.elsa.rcvcnt);
-		debugl1(cs, tmp);
+		debugl1(cs, "%s", tmp);
 	}
 	cs->hw.elsa.rcvcnt = 0;
 }
diff -puN drivers/isdn/hisax/hfc_pci.c~isdn-clean-up-debug-format-string-usage drivers/isdn/hisax/hfc_pci.c
--- a/drivers/isdn/hisax/hfc_pci.c~isdn-clean-up-debug-format-string-usage
+++ a/drivers/isdn/hisax/hfc_pci.c
@@ -901,7 +901,7 @@ Begin:
 					ptr--;
 					*ptr++ = '\n';
 					*ptr = 0;
-					HiSax_putstatus(cs, NULL, cs->dlog);
+					HiSax_putstatus(cs, NULL, "%s", cs->dlog);
 				} else
 					HiSax_putstatus(cs, "LogEcho: ", "warning Frame too big (%d)", total - 3);
 			}
diff -puN drivers/isdn/hisax/hfc_sx.c~isdn-clean-up-debug-format-string-usage drivers/isdn/hisax/hfc_sx.c
--- a/drivers/isdn/hisax/hfc_sx.c~isdn-clean-up-debug-format-string-usage
+++ a/drivers/isdn/hisax/hfc_sx.c
@@ -674,7 +674,7 @@ receive_emsg(struct IsdnCardState *cs)
 					ptr--;
 					*ptr++ = '\n';
 					*ptr = 0;
-					HiSax_putstatus(cs, NULL, cs->dlog);
+					HiSax_putstatus(cs, NULL, "%s", cs->dlog);
 				} else
 					HiSax_putstatus(cs, "LogEcho: ", "warning Frame too big (%d)", skb->len);
 			}
diff -puN drivers/isdn/hisax/hscx_irq.c~isdn-clean-up-debug-format-string-usage drivers/isdn/hisax/hscx_irq.c
--- a/drivers/isdn/hisax/hscx_irq.c~isdn-clean-up-debug-format-string-usage
+++ a/drivers/isdn/hisax/hscx_irq.c
@@ -75,7 +75,7 @@ hscx_empty_fifo(struct BCState *bcs, int
 		t += sprintf(t, "hscx_empty_fifo %c cnt %d",
 			     bcs->hw.hscx.hscx ? 'B' : 'A', count);
 		QuickHex(t, ptr, count);
-		debugl1(cs, bcs->blog);
+		debugl1(cs, "%s", bcs->blog);
 	}
 }
 
@@ -115,7 +115,7 @@ hscx_fill_fifo(struct BCState *bcs)
 		t += sprintf(t, "hscx_fill_fifo %c cnt %d",
 			     bcs->hw.hscx.hscx ? 'B' : 'A', count);
 		QuickHex(t, ptr, count);
-		debugl1(cs, bcs->blog);
+		debugl1(cs, "%s", bcs->blog);
 	}
 }
 
diff -puN drivers/isdn/hisax/icc.c~isdn-clean-up-debug-format-string-usage drivers/isdn/hisax/icc.c
--- a/drivers/isdn/hisax/icc.c~isdn-clean-up-debug-format-string-usage
+++ a/drivers/isdn/hisax/icc.c
@@ -134,7 +134,7 @@ icc_empty_fifo(struct IsdnCardState *cs,
 
 		t += sprintf(t, "icc_empty_fifo cnt %d", count);
 		QuickHex(t, ptr, count);
-		debugl1(cs, cs->dlog);
+		debugl1(cs, "%s", cs->dlog);
 	}
 }
 
@@ -176,7 +176,7 @@ icc_fill_fifo(struct IsdnCardState *cs)
 
 		t += sprintf(t, "icc_fill_fifo cnt %d", count);
 		QuickHex(t, ptr, count);
-		debugl1(cs, cs->dlog);
+		debugl1(cs, "%s", cs->dlog);
 	}
 }
 
diff -puN drivers/isdn/hisax/ipacx.c~isdn-clean-up-debug-format-string-usage drivers/isdn/hisax/ipacx.c
--- a/drivers/isdn/hisax/ipacx.c~isdn-clean-up-debug-format-string-usage
+++ a/drivers/isdn/hisax/ipacx.c
@@ -260,7 +260,7 @@ dch_empty_fifo(struct IsdnCardState *cs,
 
 		t += sprintf(t, "dch_empty_fifo() cnt %d", count);
 		QuickHex(t, ptr, count);
-		debugl1(cs, cs->dlog);
+		debugl1(cs, "%s", cs->dlog);
 	}
 }
 
@@ -307,7 +307,7 @@ dch_fill_fifo(struct IsdnCardState *cs)
 
 		t += sprintf(t, "dch_fill_fifo() cnt %d", count);
 		QuickHex(t, ptr, count);
-		debugl1(cs, cs->dlog);
+		debugl1(cs, "%s", cs->dlog);
 	}
 }
 
@@ -539,7 +539,7 @@ bch_empty_fifo(struct BCState *bcs, int
 
 		t += sprintf(t, "bch_empty_fifo() B-%d cnt %d", hscx, count);
 		QuickHex(t, ptr, count);
-		debugl1(cs, bcs->blog);
+		debugl1(cs, "%s", bcs->blog);
 	}
 }
 
@@ -582,7 +582,7 @@ bch_fill_fifo(struct BCState *bcs)
 
 		t += sprintf(t, "chb_fill_fifo() B-%d cnt %d", hscx, count);
 		QuickHex(t, ptr, count);
-		debugl1(cs, bcs->blog);
+		debugl1(cs, "%s", bcs->blog);
 	}
 }
 
diff -puN drivers/isdn/hisax/isac.c~isdn-clean-up-debug-format-string-usage drivers/isdn/hisax/isac.c
--- a/drivers/isdn/hisax/isac.c~isdn-clean-up-debug-format-string-usage
+++ a/drivers/isdn/hisax/isac.c
@@ -137,7 +137,7 @@ isac_empty_fifo(struct IsdnCardState *cs
 
 		t += sprintf(t, "isac_empty_fifo cnt %d", count);
 		QuickHex(t, ptr, count);
-		debugl1(cs, cs->dlog);
+		debugl1(cs, "%s", cs->dlog);
 	}
 }
 
@@ -179,7 +179,7 @@ isac_fill_fifo(struct IsdnCardState *cs)
 
 		t += sprintf(t, "isac_fill_fifo cnt %d", count);
 		QuickHex(t, ptr, count);
-		debugl1(cs, cs->dlog);
+		debugl1(cs, "%s", cs->dlog);
 	}
 }
 
diff -puN drivers/isdn/hisax/isar.c~isdn-clean-up-debug-format-string-usage drivers/isdn/hisax/isar.c
--- a/drivers/isdn/hisax/isar.c~isdn-clean-up-debug-format-string-usage
+++ a/drivers/isdn/hisax/isar.c
@@ -74,7 +74,7 @@ sendmsg(struct IsdnCardState *cs, u_char
 				t = tmp;
 				t += sprintf(t, "sendmbox cnt %d", len);
 				QuickHex(t, &msg[len-i], (i > 64) ? 64 : i);
-				debugl1(cs, tmp);
+				debugl1(cs, "%s", tmp);
 				i -= 64;
 			}
 		}
@@ -105,7 +105,7 @@ rcv_mbox(struct IsdnCardState *cs, struc
 				t = tmp;
 				t += sprintf(t, "rcv_mbox cnt %d", ireg->clsb);
 				QuickHex(t, &msg[ireg->clsb - i], (i > 64) ? 64 : i);
-				debugl1(cs, tmp);
+				debugl1(cs, "%s", tmp);
 				i -= 64;
 			}
 		}
@@ -1248,7 +1248,7 @@ isar_int_main(struct IsdnCardState *cs)
 			tp += sprintf(debbuf, "msg iis(%x) msb(%x)",
 				      ireg->iis, ireg->cmsb);
 			QuickHex(tp, (u_char *)ireg->par, ireg->clsb);
-			debugl1(cs, debbuf);
+			debugl1(cs, "%s", debbuf);
 		}
 		break;
 	case ISAR_IIS_INVMSG:
diff -puN drivers/isdn/hisax/jade.c~isdn-clean-up-debug-format-string-usage drivers/isdn/hisax/jade.c
--- a/drivers/isdn/hisax/jade.c~isdn-clean-up-debug-format-string-usage
+++ a/drivers/isdn/hisax/jade.c
@@ -81,10 +81,7 @@ modejade(struct BCState *bcs, int mode,
 	int jade = bcs->hw.hscx.hscx;
 
 	if (cs->debug & L1_DEB_HSCX) {
-		char tmp[40];
-		sprintf(tmp, "jade %c mode %d ichan %d",
-			'A' + jade, mode, bc);
-		debugl1(cs, tmp);
+		debugl1(cs, "jade %c mode %d ichan %d", 'A' + jade, mode, bc);
 	}
 	bcs->mode = mode;
 	bcs->channel = bc;
@@ -257,23 +254,18 @@ void
 clear_pending_jade_ints(struct IsdnCardState *cs)
 {
 	int val;
-	char tmp[64];
 
 	cs->BC_Write_Reg(cs, 0, jade_HDLC_IMR, 0x00);
 	cs->BC_Write_Reg(cs, 1, jade_HDLC_IMR, 0x00);
 
 	val = cs->BC_Read_Reg(cs, 1, jade_HDLC_ISR);
-	sprintf(tmp, "jade B ISTA %x", val);
-	debugl1(cs, tmp);
+	debugl1(cs, "jade B ISTA %x", val);
 	val = cs->BC_Read_Reg(cs, 0, jade_HDLC_ISR);
-	sprintf(tmp, "jade A ISTA %x", val);
-	debugl1(cs, tmp);
+	debugl1(cs, "jade A ISTA %x", val);
 	val = cs->BC_Read_Reg(cs, 1, jade_HDLC_STAR);
-	sprintf(tmp, "jade B STAR %x", val);
-	debugl1(cs, tmp);
+	debugl1(cs, "jade B STAR %x", val);
 	val = cs->BC_Read_Reg(cs, 0, jade_HDLC_STAR);
-	sprintf(tmp, "jade A STAR %x", val);
-	debugl1(cs, tmp);
+	debugl1(cs, "jade A STAR %x", val);
 	/* Unmask ints */
 	cs->BC_Write_Reg(cs, 0, jade_HDLC_IMR, 0xF8);
 	cs->BC_Write_Reg(cs, 1, jade_HDLC_IMR, 0xF8);
diff -puN drivers/isdn/hisax/jade_irq.c~isdn-clean-up-debug-format-string-usage drivers/isdn/hisax/jade_irq.c
--- a/drivers/isdn/hisax/jade_irq.c~isdn-clean-up-debug-format-string-usage
+++ a/drivers/isdn/hisax/jade_irq.c
@@ -65,7 +65,7 @@ jade_empty_fifo(struct BCState *bcs, int
 		t += sprintf(t, "jade_empty_fifo %c cnt %d",
 			     bcs->hw.hscx.hscx ? 'B' : 'A', count);
 		QuickHex(t, ptr, count);
-		debugl1(cs, bcs->blog);
+		debugl1(cs, "%s", bcs->blog);
 	}
 }
 
@@ -105,7 +105,7 @@ jade_fill_fifo(struct BCState *bcs)
 		t += sprintf(t, "jade_fill_fifo %c cnt %d",
 			     bcs->hw.hscx.hscx ? 'B' : 'A', count);
 		QuickHex(t, ptr, count);
-		debugl1(cs, bcs->blog);
+		debugl1(cs, "%s", bcs->blog);
 	}
 }
 
diff -puN drivers/isdn/hisax/l3_1tr6.c~isdn-clean-up-debug-format-string-usage drivers/isdn/hisax/l3_1tr6.c
--- a/drivers/isdn/hisax/l3_1tr6.c~isdn-clean-up-debug-format-string-usage
+++ a/drivers/isdn/hisax/l3_1tr6.c
@@ -63,7 +63,7 @@ l3_1tr6_error(struct l3_process *pc, u_c
 {
 	dev_kfree_skb(skb);
 	if (pc->st->l3.debug & L3_DEB_WARN)
-		l3_debug(pc->st, msg);
+		l3_debug(pc->st, "%s", msg);
 	l3_1tr6_release_req(pc, 0, NULL);
 }
 
@@ -161,7 +161,6 @@ l3_1tr6_setup(struct l3_process *pc, u_c
 {
 	u_char *p;
 	int bcfound = 0;
-	char tmp[80];
 	struct sk_buff *skb = arg;
 
 	/* Channel Identification */
@@ -214,10 +213,9 @@ l3_1tr6_setup(struct l3_process *pc, u_c
 	/* Signal all services, linklevel takes care of Service-Indicator */
 	if (bcfound) {
 		if ((pc->para.setup.si1 != 7) && (pc->st->l3.debug & L3_DEB_WARN)) {
-			sprintf(tmp, "non-digital call: %s -> %s",
+			l3_debug(pc->st, "non-digital call: %s -> %s",
 				pc->para.setup.phone,
 				pc->para.setup.eazmsn);
-			l3_debug(pc->st, tmp);
 		}
 		newl3state(pc, 6);
 		pc->st->l3.l3l4(pc->st, CC_SETUP | INDICATION, pc);
@@ -301,7 +299,7 @@ l3_1tr6_info(struct l3_process *pc, u_ch
 {
 	u_char *p;
 	int i, tmpcharge = 0;
-	char a_charge[8], tmp[32];
+	char a_charge[8];
 	struct sk_buff *skb = arg;
 
 	p = skb->data;
@@ -316,8 +314,8 @@ l3_1tr6_info(struct l3_process *pc, u_ch
 			pc->st->l3.l3l4(pc->st, CC_CHARGE | INDICATION, pc);
 		}
 		if (pc->st->l3.debug & L3_DEB_CHARGE) {
-			sprintf(tmp, "charging info %d", pc->para.chargeinfo);
-			l3_debug(pc->st, tmp);
+			l3_debug(pc->st, "charging info %d",
+				 pc->para.chargeinfo);
 		}
 	} else if (pc->st->l3.debug & L3_DEB_CHARGE)
 		l3_debug(pc->st, "charging info not found");
@@ -399,7 +397,7 @@ l3_1tr6_disc(struct l3_process *pc, u_ch
 	struct sk_buff *skb = arg;
 	u_char *p;
 	int i, tmpcharge = 0;
-	char a_charge[8], tmp[32];
+	char a_charge[8];
 
 	StopAllL3Timer(pc);
 	p = skb->data;
@@ -414,8 +412,8 @@ l3_1tr6_disc(struct l3_process *pc, u_ch
 			pc->st->l3.l3l4(pc->st, CC_CHARGE | INDICATION, pc);
 		}
 		if (pc->st->l3.debug & L3_DEB_CHARGE) {
-			sprintf(tmp, "charging info %d", pc->para.chargeinfo);
-			l3_debug(pc->st, tmp);
+			l3_debug(pc->st, "charging info %d",
+				 pc->para.chargeinfo);
 		}
 	} else if (pc->st->l3.debug & L3_DEB_CHARGE)
 		l3_debug(pc->st, "charging info not found");
@@ -746,7 +744,6 @@ up1tr6(struct PStack *st, int pr, void *
 	int i, mt, cr;
 	struct l3_process *proc;
 	struct sk_buff *skb = arg;
-	char tmp[80];
 
 	switch (pr) {
 	case (DL_DATA | INDICATION):
@@ -762,26 +759,23 @@ up1tr6(struct PStack *st, int pr, void *
 	}
 	if (skb->len < 4) {
 		if (st->l3.debug & L3_DEB_PROTERR) {
-			sprintf(tmp, "up1tr6 len only %d", skb->len);
-			l3_debug(st, tmp);
+			l3_debug(st, "up1tr6 len only %d", skb->len);
 		}
 		dev_kfree_skb(skb);
 		return;
 	}
 	if ((skb->data[0] & 0xfe) != PROTO_DIS_N0) {
 		if (st->l3.debug & L3_DEB_PROTERR) {
-			sprintf(tmp, "up1tr6%sunexpected discriminator %x message len %d",
+			l3_debug(st, "up1tr6%sunexpected discriminator %x message len %d",
 				(pr == (DL_DATA | INDICATION)) ? " " : "(broadcast) ",
 				skb->data[0], skb->len);
-			l3_debug(st, tmp);
 		}
 		dev_kfree_skb(skb);
 		return;
 	}
 	if (skb->data[1] != 1) {
 		if (st->l3.debug & L3_DEB_PROTERR) {
-			sprintf(tmp, "up1tr6 CR len not 1");
-			l3_debug(st, tmp);
+			l3_debug(st, "up1tr6 CR len not 1");
 		}
 		dev_kfree_skb(skb);
 		return;
@@ -791,9 +785,8 @@ up1tr6(struct PStack *st, int pr, void *
 	if (skb->data[0] == PROTO_DIS_N0) {
 		dev_kfree_skb(skb);
 		if (st->l3.debug & L3_DEB_STATE) {
-			sprintf(tmp, "up1tr6%s N0 mt %x unhandled",
+			l3_debug(st, "up1tr6%s N0 mt %x unhandled",
 				(pr == (DL_DATA | INDICATION)) ? " " : "(broadcast) ", mt);
-			l3_debug(st, tmp);
 		}
 	} else if (skb->data[0] == PROTO_DIS_N1) {
 		if (!(proc = getl3proc(st, cr))) {
@@ -801,8 +794,7 @@ up1tr6(struct PStack *st, int pr, void *
 				if (cr < 128) {
 					if (!(proc = new_l3_process(st, cr))) {
 						if (st->l3.debug & L3_DEB_PROTERR) {
-							sprintf(tmp, "up1tr6 no roc mem");
-							l3_debug(st, tmp);
+							l3_debug(st, "up1tr6 no roc mem");
 						}
 						dev_kfree_skb(skb);
 						return;
@@ -821,8 +813,7 @@ up1tr6(struct PStack *st, int pr, void *
 			} else {
 				if (!(proc = new_l3_process(st, cr))) {
 					if (st->l3.debug & L3_DEB_PROTERR) {
-						sprintf(tmp, "up1tr6 no roc mem");
-						l3_debug(st, tmp);
+						l3_debug(st, "up1tr6 no roc mem");
 					}
 					dev_kfree_skb(skb);
 					return;
@@ -837,18 +828,16 @@ up1tr6(struct PStack *st, int pr, void *
 		if (i == ARRAY_SIZE(datastln1)) {
 			dev_kfree_skb(skb);
 			if (st->l3.debug & L3_DEB_STATE) {
-				sprintf(tmp, "up1tr6%sstate %d mt %x unhandled",
+				l3_debug(st, "up1tr6%sstate %d mt %x unhandled",
 					(pr == (DL_DATA | INDICATION)) ? " " : "(broadcast) ",
 					proc->state, mt);
-				l3_debug(st, tmp);
 			}
 			return;
 		} else {
 			if (st->l3.debug & L3_DEB_STATE) {
-				sprintf(tmp, "up1tr6%sstate %d mt %x",
+				l3_debug(st, "up1tr6%sstate %d mt %x",
 					(pr == (DL_DATA | INDICATION)) ? " " : "(broadcast) ",
 					proc->state, mt);
-				l3_debug(st, tmp);
 			}
 			datastln1[i].rout(proc, pr, skb);
 		}
@@ -861,7 +850,6 @@ down1tr6(struct PStack *st, int pr, void
 	int i, cr;
 	struct l3_process *proc;
 	struct Channel *chan;
-	char tmp[80];
 
 	if ((DL_ESTABLISH | REQUEST) == pr) {
 		l3_msg(st, pr, NULL);
@@ -888,15 +876,13 @@ down1tr6(struct PStack *st, int pr, void
 			break;
 	if (i == ARRAY_SIZE(downstl)) {
 		if (st->l3.debug & L3_DEB_STATE) {
-			sprintf(tmp, "down1tr6 state %d prim %d unhandled",
+			l3_debug(st, "down1tr6 state %d prim %d unhandled",
 				proc->state, pr);
-			l3_debug(st, tmp);
 		}
 	} else {
 		if (st->l3.debug & L3_DEB_STATE) {
-			sprintf(tmp, "down1tr6 state %d prim %d",
+			l3_debug(st, "down1tr6 state %d prim %d",
 				proc->state, pr);
-			l3_debug(st, tmp);
 		}
 		downstl[i].rout(proc, pr, arg);
 	}
diff -puN drivers/isdn/hisax/netjet.c~isdn-clean-up-debug-format-string-usage drivers/isdn/hisax/netjet.c
--- a/drivers/isdn/hisax/netjet.c~isdn-clean-up-debug-format-string-usage
+++ a/drivers/isdn/hisax/netjet.c
@@ -176,7 +176,7 @@ static void printframe(struct IsdnCardSt
 		else
 			j = i;
 		QuickHex(t, p, j);
-		debugl1(cs, tmp);
+		debugl1(cs, "%s", tmp);
 		p += j;
 		i -= j;
 		t = tmp;
diff -puN drivers/isdn/hisax/q931.c~isdn-clean-up-debug-format-string-usage drivers/isdn/hisax/q931.c
--- a/drivers/isdn/hisax/q931.c~isdn-clean-up-debug-format-string-usage
+++ a/drivers/isdn/hisax/q931.c
@@ -1179,7 +1179,7 @@ LogFrame(struct IsdnCardState *cs, u_cha
 		dp--;
 		*dp++ = '\n';
 		*dp = 0;
-		HiSax_putstatus(cs, NULL, cs->dlog);
+		HiSax_putstatus(cs, NULL, "%s", cs->dlog);
 	} else
 		HiSax_putstatus(cs, "LogFrame: ", "warning Frame too big (%d)", size);
 }
@@ -1246,7 +1246,7 @@ dlogframe(struct IsdnCardState *cs, stru
 	}
 	if (finish) {
 		*dp = 0;
-		HiSax_putstatus(cs, NULL, cs->dlog);
+		HiSax_putstatus(cs, NULL, "%s", cs->dlog);
 		return;
 	}
 	if ((0xfe & buf[0]) == PROTO_DIS_N0) {	/* 1TR6 */
@@ -1509,5 +1509,5 @@ dlogframe(struct IsdnCardState *cs, stru
 		dp += sprintf(dp, "Unknown protocol %x!", buf[0]);
 	}
 	*dp = 0;
-	HiSax_putstatus(cs, NULL, cs->dlog);
+	HiSax_putstatus(cs, NULL, "%s", cs->dlog);
 }
diff -puN drivers/isdn/hisax/w6692.c~isdn-clean-up-debug-format-string-usage drivers/isdn/hisax/w6692.c
--- a/drivers/isdn/hisax/w6692.c~isdn-clean-up-debug-format-string-usage
+++ a/drivers/isdn/hisax/w6692.c
@@ -154,7 +154,7 @@ W6692_empty_fifo(struct IsdnCardState *c
 
 		t += sprintf(t, "W6692_empty_fifo cnt %d", count);
 		QuickHex(t, ptr, count);
-		debugl1(cs, cs->dlog);
+		debugl1(cs, "%s", cs->dlog);
 	}
 }
 
@@ -196,7 +196,7 @@ W6692_fill_fifo(struct IsdnCardState *cs
 
 		t += sprintf(t, "W6692_fill_fifo cnt %d", count);
 		QuickHex(t, ptr, count);
-		debugl1(cs, cs->dlog);
+		debugl1(cs, "%s", cs->dlog);
 	}
 }
 
@@ -226,7 +226,7 @@ W6692B_empty_fifo(struct BCState *bcs, i
 		t += sprintf(t, "W6692B_empty_fifo %c cnt %d",
 			     bcs->channel + '1', count);
 		QuickHex(t, ptr, count);
-		debugl1(cs, bcs->blog);
+		debugl1(cs, "%s", bcs->blog);
 	}
 }
 
@@ -264,7 +264,7 @@ W6692B_fill_fifo(struct BCState *bcs)
 		t += sprintf(t, "W6692B_fill_fifo %c cnt %d",
 			     bcs->channel + '1', count);
 		QuickHex(t, ptr, count);
-		debugl1(cs, bcs->blog);
+		debugl1(cs, "%s", bcs->blog);
 	}
 }
 
_
