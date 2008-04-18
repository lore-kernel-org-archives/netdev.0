From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 08/15] [ISDN] minor irq handler cleanups
Date: Fri, 18 Apr 2008 19:22:55 -0400 (EDT)
Message-ID: <f8e24302d74ee5066900b6f650d4e558d4f930c1.1208559659.git.jgarzik@redhat.com>
References: <d7afbccda111e535bb14ad8082b208c7a2cd9833.1208559659.git.jgarzik@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
To: kkeil@suse.de, isdn4linux@listserv.isdn4linux.de,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755965AbYDRXZi@vger.kernel.org>
In-Reply-To: <d7afbccda111e535bb14ad8082b208c7a2cd9833.1208559659.git.jgarzik@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- remove pointless casts from void*

- remove braces around singleton C statements

- remove unused 'intno' argument from rs_interrupt_elsa()

- cs->irq_func() should be defined using standard irq_handler_t

This change's main purpose is to prepare for the patchset in
jgarzik/misc-2.6.git#irq-remove, that explores removal of the
never-used 'irq' argument in each interrupt handler.

Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
---
 drivers/isdn/hisax/elsa.c     |    4 ++--
 drivers/isdn/hisax/elsa_ser.c |    4 ++--
 drivers/isdn/hisax/hisax.h    |    2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/isdn/hisax/elsa.c b/drivers/isdn/hisax/elsa.c
index d272d8c..2c3691f 100644
--- a/drivers/isdn/hisax/elsa.c
+++ b/drivers/isdn/hisax/elsa.c
@@ -299,7 +299,7 @@ elsa_interrupt(int intno, void *dev_id)
 		val = serial_inp(cs, UART_IIR);
 		if (!(val & UART_IIR_NO_INT)) {
 			debugl1(cs,"IIR %02x", val);
-			rs_interrupt_elsa(intno, cs);
+			rs_interrupt_elsa(cs);
 		}
 	}
 #endif
@@ -379,7 +379,7 @@ elsa_interrupt_ipac(int intno, void *dev_id)
 		val = serial_inp(cs, UART_IIR);
 		if (!(val & UART_IIR_NO_INT)) {
 			debugl1(cs,"IIR %02x", val);
-			rs_interrupt_elsa(intno, cs);
+			rs_interrupt_elsa(cs);
 		}
 	}
 #endif
diff --git a/drivers/isdn/hisax/elsa_ser.c b/drivers/isdn/hisax/elsa_ser.c
index 1642dca..f181db4 100644
--- a/drivers/isdn/hisax/elsa_ser.c
+++ b/drivers/isdn/hisax/elsa_ser.c
@@ -384,13 +384,13 @@ static inline void transmit_chars(struct IsdnCardState *cs, int *intr_done)
 }
 
 
-static void rs_interrupt_elsa(int irq, struct IsdnCardState *cs)
+static void rs_interrupt_elsa(struct IsdnCardState *cs)
 {
 	int status, iir, msr;
 	int pass_counter = 0;
 	
 #ifdef SERIAL_DEBUG_INTR
-	printk("rs_interrupt_single(%d)...", irq);
+	printk(KERN_DEBUG "rs_interrupt_single(%d)...", cs->irq);
 #endif
 
 	do {
diff --git a/drivers/isdn/hisax/hisax.h b/drivers/isdn/hisax/hisax.h
index 34733c9..e8d429f 100644
--- a/drivers/isdn/hisax/hisax.h
+++ b/drivers/isdn/hisax/hisax.h
@@ -925,7 +925,7 @@ struct IsdnCardState {
 	int		(*cardmsg) (struct IsdnCardState *, int, void *);
 	void		(*setstack_d) (struct PStack *, struct IsdnCardState *);
 	void		(*DC_Close) (struct IsdnCardState *);
-	int		(*irq_func) (int, void *);
+	irq_handler_t	irq_func;
 	int		(*auxcmd) (struct IsdnCardState *, isdn_ctrl *);
 	struct Channel	channel[2+MAX_WAITING_CALLS];
 	struct BCState	bcs[2+MAX_WAITING_CALLS];
-- 
1.5.4.1
