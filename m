From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCHv2 (net.git) 1/3] stmmac: update the PTP header file
Date: Mon, 14 Nov 2016 09:27:28 +0100
Message-ID: <1479112050-14042-2-git-send-email-peppe.cavallaro@st.com>
References: <1479112050-14042-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: <alexandre.torgue@st.com>, <rayagond@vayavyalabs.com>,
        <richardcochran@gmail.com>, <linux-kernel@vger.kernel.org>,
        <davem@davemloft.net>, <seraphin.bonnaffe@st.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479112050-14042-1-git-send-email-peppe.cavallaro@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is to update this file by using BIT macros, removing
not used defines and fixes some typos.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Acked-by: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Acked-by: Alexandre TORGUE <alexandre.torgue@st.com>
Acked-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h | 72 ++++++++++++------------
 1 file changed, 37 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
index 4535df3..c06938c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
@@ -22,51 +22,53 @@
   Author: Rayagond Kokatanur <rayagond@vayavyalabs.com>
 ******************************************************************************/
 
-#ifndef __STMMAC_PTP_H__
-#define __STMMAC_PTP_H__
+#ifndef	__STMMAC_PTP_H__
+#define	__STMMAC_PTP_H__
 
-/* IEEE 1588 PTP register offsets */
-#define PTP_TCR		0x0700	/* Timestamp Control Reg */
-#define PTP_SSIR	0x0704	/* Sub-Second Increment Reg */
-#define PTP_STSR	0x0708	/* System Time – Seconds Regr */
-#define PTP_STNSR	0x070C	/* System Time – Nanoseconds Reg */
-#define PTP_STSUR	0x0710	/* System Time – Seconds Update Reg */
-#define PTP_STNSUR	0x0714	/* System Time – Nanoseconds Update Reg */
-#define PTP_TAR		0x0718	/* Timestamp Addend Reg */
-#define PTP_TTSR	0x071C	/* Target Time Seconds Reg */
-#define PTP_TTNSR	0x0720	/* Target Time Nanoseconds Reg */
-#define	PTP_STHWSR	0x0724	/* System Time - Higher Word Seconds Reg */
-#define PTP_TSR		0x0728	/* Timestamp Status */
+#define	PTP_GMAC4_OFFSET	0xb00
+#define	PTP_GMAC3_X_OFFSET	0x700
 
-#define PTP_STNSUR_ADDSUB_SHIFT 31
+/* IEEE 1588 PTP register offsets */
+#define	PTP_TCR		0x00	/* Timestamp Control Reg */
+#define	PTP_SSIR	0x04	/* Sub-Second Increment Reg */
+#define	PTP_STSR	0x08	/* System Time – Seconds Regr */
+#define	PTP_STNSR	0x0c	/* System Time – Nanoseconds Reg */
+#define	PTP_STSUR	0x10	/* System Time – Seconds Update Reg */
+#define	PTP_STNSUR	0x14	/* System Time – Nanoseconds Update Reg */
+#define	PTP_TAR		0x18	/* Timestamp Addend Reg */
 
-/* PTP TCR defines */
-#define PTP_TCR_TSENA		0x00000001 /* Timestamp Enable */
-#define PTP_TCR_TSCFUPDT	0x00000002 /* Timestamp Fine/Coarse Update */
-#define PTP_TCR_TSINIT		0x00000004 /* Timestamp Initialize */
-#define PTP_TCR_TSUPDT		0x00000008 /* Timestamp Update */
-/* Timestamp Interrupt Trigger Enable */
-#define PTP_TCR_TSTRIG		0x00000010
-#define PTP_TCR_TSADDREG	0x00000020 /* Addend Reg Update */
-#define PTP_TCR_TSENALL		0x00000100 /* Enable Timestamp for All Frames */
-/* Timestamp Digital or Binary Rollover Control */
-#define PTP_TCR_TSCTRLSSR	0x00000200
+#define	PTP_STNSUR_ADDSUB_SHIFT	31
+#define	PTP_DIGITAL_ROLLOVER_MODE	0x3B9ACA00	/* 10e9-1 ns */
+#define	PTP_BINARY_ROLLOVER_MODE	0x80000000	/* ~0.466 ns */
 
+/* PTP Timestamp control register defines */
+#define	PTP_TCR_TSENA		BIT(0)	/* Timestamp Enable */
+#define	PTP_TCR_TSCFUPDT	BIT(1)	/* Timestamp Fine/Coarse Update */
+#define	PTP_TCR_TSINIT		BIT(2)	/* Timestamp Initialize */
+#define	PTP_TCR_TSUPDT		BIT(3)	/* Timestamp Update */
+#define	PTP_TCR_TSTRIG		BIT(4)	/* Timestamp Interrupt Trigger Enable */
+#define	PTP_TCR_TSADDREG	BIT(5)	/* Addend Reg Update */
+#define	PTP_TCR_TSENALL		BIT(8)	/* Enable Timestamp for All Frames */
+#define	PTP_TCR_TSCTRLSSR	BIT(9)	/* Digital or Binary Rollover Control */
 /* Enable PTP packet Processing for Version 2 Format */
-#define PTP_TCR_TSVER2ENA	0x00000400
+#define	PTP_TCR_TSVER2ENA	BIT(10)
 /* Enable Processing of PTP over Ethernet Frames */
-#define PTP_TCR_TSIPENA		0x00000800
+#define	PTP_TCR_TSIPENA		BIT(11)
 /* Enable Processing of PTP Frames Sent over IPv6-UDP */
-#define PTP_TCR_TSIPV6ENA	0x00001000
+#define	PTP_TCR_TSIPV6ENA	BIT(12)
 /* Enable Processing of PTP Frames Sent over IPv4-UDP */
-#define PTP_TCR_TSIPV4ENA	0x00002000
+#define	PTP_TCR_TSIPV4ENA	BIT(13)
 /* Enable Timestamp Snapshot for Event Messages */
-#define PTP_TCR_TSEVNTENA	0x00004000
+#define	PTP_TCR_TSEVNTENA	BIT(14)
 /* Enable Snapshot for Messages Relevant to Master */
-#define PTP_TCR_TSMSTRENA	0x00008000
+#define	PTP_TCR_TSMSTRENA	BIT(15)
 /* Select PTP packets for Taking Snapshots */
-#define PTP_TCR_SNAPTYPSEL_1	0x00010000
+#define	PTP_TCR_SNAPTYPSEL_1	GENMASK(17, 16)
 /* Enable MAC address for PTP Frame Filtering */
-#define PTP_TCR_TSENMACADDR	0x00040000
+#define	PTP_TCR_TSENMACADDR	BIT(18)
+
+/* SSIR defines */
+#define	PTP_SSIR_SSINC_MASK		0xff
+#define	GMAC4_PTP_SSIR_SSINC_SHIFT	16
 
-#endif /* __STMMAC_PTP_H__ */
+#endif	/* __STMMAC_PTP_H__ */
-- 
2.7.4
