From: Aaron Wu <Aaron.wu@analog.com>
Subject: [PATCH V6 3/3] bfin_can: move and merge the content of header file into driver body
Date: Fri, 6 Feb 2015 14:25:52 +0800
Message-ID: <1423203952-23004-3-git-send-email-Aaron.wu@analog.com>
References: <1423203952-23004-1-git-send-email-Aaron.wu@analog.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Aaron Wu <Aaron.wu@analog.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-devel@analog.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423203952-23004-1-git-send-email-Aaron.wu@analog.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Header file was in arch dependent location arch/blackfin/include/asm/bfin_can.h,
Now move and merge the useful contents of header file into driver code, note
the original header file is reserved for full register sets access test by other
code so it survives.   

Signed-off-by: Aaron Wu <Aaron.wu@analog.com>
---
 drivers/net/can/bfin_can.c |  114 +++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 113 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
index 259d09a..63fab5c 100644
--- a/drivers/net/can/bfin_can.c
+++ b/drivers/net/can/bfin_can.c
@@ -20,13 +20,125 @@
 #include <linux/can/dev.h>
 #include <linux/can/error.h>
 
-#include <asm/bfin_can.h>
 #include <asm/portmux.h>
 
 #define DRV_NAME "bfin_can"
 #define BFIN_CAN_TIMEOUT 100
 #define TX_ECHO_SKB_MAX  1
 
+/* transmit and receive channels */
+
+#define TRANSMIT_CHL    24
+#define RECEIVE_STD_CHL    0
+#define RECEIVE_EXT_CHL    4
+#define RECEIVE_RTR_CHL    8
+#define RECEIVE_EXT_RTR_CHL    12
+#define MAX_CHL_NUMBER    32
+
+/* All Blackfin system MMRs are padded to 32bits even if the register
+ * itself is only 16bits.  So use a helper macro to streamline this
+*/
+#define __BFP(m) u16 m; u16 __pad_##m
+
+ /* bfin can registers layout
+ */
+struct bfin_can_mask_regs {
+	__BFP(aml);
+	__BFP(amh);
+};
+
+struct bfin_can_channel_regs {
+	/* data[0,2,4,6] -> data{0,1,2,3} while data[1,3,5,7] is padding */
+	u16 data[8];
+	 __BFP(dlc);
+	__BFP(tsv);
+	__BFP(id0);
+	__BFP(id1);
+};
+
+struct bfin_can_regs {
+	/* global control and status registers
+	 */
+	__BFP(mc1);           /* offset 0x00 */
+	__BFP(md1);           /* offset 0x04 */
+	__BFP(trs1);          /* offset 0x08 */
+	__BFP(trr1);          /* offset 0x0c */
+	__BFP(ta1);           /* offset 0x10 */
+	__BFP(aa1);           /* offset 0x14 */
+	__BFP(rmp1);          /* offset 0x18 */
+	__BFP(rml1);          /* offset 0x1c */
+	__BFP(mbtif1);        /* offset 0x20 */
+	__BFP(mbrif1);        /* offset 0x24 */
+	__BFP(mbim1);         /* offset 0x28 */
+	__BFP(rfh1);          /* offset 0x2c */
+	__BFP(opss1);         /* offset 0x30 */
+	u32 __pad1[3];
+	 __BFP(mc2);           /* offset 0x40 */
+	__BFP(md2);           /* offset 0x44 */
+	__BFP(trs2);          /* offset 0x48 */
+	__BFP(trr2);          /* offset 0x4c */
+	__BFP(ta2);           /* offset 0x50 */
+	__BFP(aa2);           /* offset 0x54 */
+	__BFP(rmp2);          /* offset 0x58 */
+	__BFP(rml2);          /* offset 0x5c */
+	__BFP(mbtif2);        /* offset 0x60 */
+	__BFP(mbrif2);        /* offset 0x64 */
+	__BFP(mbim2);         /* offset 0x68 */
+	__BFP(rfh2);          /* offset 0x6c */
+	__BFP(opss2);         /* offset 0x70 */
+	u32 __pad2[3];
+	 __BFP(clock);         /* offset 0x80 */
+	__BFP(timing);        /* offset 0x84 */
+	__BFP(debug);         /* offset 0x88 */
+	__BFP(status);        /* offset 0x8c */
+	__BFP(cec);           /* offset 0x90 */
+	__BFP(gis);           /* offset 0x94 */
+	__BFP(gim);           /* offset 0x98 */
+	__BFP(gif);           /* offset 0x9c */
+	__BFP(control);       /* offset 0xa0 */
+	__BFP(intr);          /* offset 0xa4 */
+	__BFP(version);       /* offset 0xa8 */
+	__BFP(mbtd);          /* offset 0xac */
+	__BFP(ewr);           /* offset 0xb0 */
+	__BFP(esr);           /* offset 0xb4 */
+	u32 __pad3[2];
+	 __BFP(ucreg);         /* offset 0xc0 */
+	__BFP(uccnt);         /* offset 0xc4 */
+	__BFP(ucrc);          /* offset 0xc8 */
+	__BFP(uccnf);         /* offset 0xcc */
+	u32 __pad4[1];
+	 __BFP(version2);      /* offset 0xd4 */
+	u32 __pad5[10];
+
+	/* channel(mailbox) mask and message registers
+	 */
+	struct bfin_can_mask_regs msk[MAX_CHL_NUMBER];    /* offset 0x100 */
+	struct bfin_can_channel_regs chl[MAX_CHL_NUMBER]; /* offset 0x200 */
+};
+
+#undef __BFP
+
+#define SRS	             0x0001  /* Software Reset */
+#define SER	             0x0008  /* Stuff Error */
+#define BOIM	            0x0008  /* Enable Bus Off Interrupt */
+#define CCR	             0x0080  /* CAN Configuration Mode Request */
+#define CCA	             0x0080  /* Configuration Mode Acknowledge */
+#define SAM	             0x0080  /* Sampling */
+#define AME	             0x8000  /* Acceptance Mask Enable */
+#define RMLIM	           0x0080  /* Enable RX Message Lost Interrupt */
+#define RMLIS	           0x0080  /* RX Message Lost IRQ Status */
+#define RTR	             0x4000  /* Remote Frame Transmission Request */
+#define BOIS	            0x0008  /* Bus Off IRQ Status */
+#define IDE	             0x2000  /* Identifier Extension */
+#define EPIS	            0x0004  /* Error-Passive Mode IRQ Status */
+#define EPIM	            0x0004  /* Enable Error-Passive Mode Interrupt */
+#define EWTIS	           0x0001  /* TX Error Count IRQ Status */
+#define EWRIS	           0x0002  /* RX Error Count IRQ Status */
+#define BEF	             0x0040  /* Bit Error Flag */
+#define FER	             0x0080  /* Form Error Flag */
+#define SMR		   0x0020	/* Sleep Mode Request */
+#define SMACK		   0x0008	/* Sleep Mode Acknowledge */
+
 /*
  * bfin can private data
  */
-- 
1.7.9.5
