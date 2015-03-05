From: Emil Medve <Emilian.Medve@Freescale.com>
Subject: [PATCH 1/7] soc/fman: Add the FMan FLIB headers
Date: Wed, 4 Mar 2015 23:45:45 -0600
Message-ID: <1425534351-1065-2-git-send-email-Emilian.Medve@Freescale.com>
References: <1425534351-1065-1-git-send-email-Emilian.Medve@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Igal Liberman <Igal.Liberman@Freescale.com>
To: <linuxppc-dev@lists.ozlabs.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425534351-1065-1-git-send-email-Emilian.Medve@Freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Igal Liberman <Igal.Liberman@freescale.com>

The Freescale Data Path Acceleration Architecture (DPAA) is a set of
hardware components on specific QorIQ P and T series multicore processors.
This architecture provides the infrastructure to support simplified
sharing of networking interfaces and accelerators by multiple CPU cores,
and the accelerators themselves.

One of the DPAA accelerators is the Frame Manager (FMan), which
combines the Ethernet network interfaces with packet distribution
logic to provide intelligent distribution and queuing decisions for
incoming traffic at line rate.

This patch presents the FMan Foundation Libraries (FLIB) headers.
The FMan FLIB suite adds basic support for the DPAA FMan hardware register access.
The FMan FLIB suite is used in Freescale's SDK Releases.

Signed-off-by: Igal Liberman <Igal.Liberman@freescale.com>
---
 drivers/soc/fsl/fman/flib/common/general.h         |   45 +
 drivers/soc/fsl/fman/flib/fman_common.h            |   74 ++
 drivers/soc/fsl/fman/flib/fsl_enet.h               |  276 ++++++
 drivers/soc/fsl/fman/flib/fsl_fman.h               |  801 +++++++++++++++
 drivers/soc/fsl/fman/flib/fsl_fman_dtsec.h         | 1017 ++++++++++++++++++++
 drivers/soc/fsl/fman/flib/fsl_fman_dtsec_mii_acc.h |  104 ++
 drivers/soc/fsl/fman/flib/fsl_fman_kg.h            |  506 ++++++++++
 drivers/soc/fsl/fman/flib/fsl_fman_memac.h         |  492 ++++++++++
 drivers/soc/fsl/fman/flib/fsl_fman_memac_mii_acc.h |   77 ++
 drivers/soc/fsl/fman/flib/fsl_fman_port.h          |  602 ++++++++++++
 drivers/soc/fsl/fman/flib/fsl_fman_prs.h           |  106 ++
 drivers/soc/fsl/fman/flib/fsl_fman_rtc.h           |  415 ++++++++
 drivers/soc/fsl/fman/flib/fsl_fman_sp.h            |  133 +++
 drivers/soc/fsl/fman/flib/fsl_fman_tgec.h          |  484 ++++++++++
 14 files changed, 5132 insertions(+)
 create mode 100644 drivers/soc/fsl/fman/flib/common/general.h
 create mode 100644 drivers/soc/fsl/fman/flib/fman_common.h
 create mode 100644 drivers/soc/fsl/fman/flib/fsl_enet.h
 create mode 100644 drivers/soc/fsl/fman/flib/fsl_fman.h
 create mode 100644 drivers/soc/fsl/fman/flib/fsl_fman_dtsec.h
 create mode 100644 drivers/soc/fsl/fman/flib/fsl_fman_dtsec_mii_acc.h
 create mode 100644 drivers/soc/fsl/fman/flib/fsl_fman_kg.h
 create mode 100644 drivers/soc/fsl/fman/flib/fsl_fman_memac.h
 create mode 100644 drivers/soc/fsl/fman/flib/fsl_fman_memac_mii_acc.h
 create mode 100644 drivers/soc/fsl/fman/flib/fsl_fman_port.h
 create mode 100644 drivers/soc/fsl/fman/flib/fsl_fman_prs.h
 create mode 100644 drivers/soc/fsl/fman/flib/fsl_fman_rtc.h
 create mode 100644 drivers/soc/fsl/fman/flib/fsl_fman_sp.h
 create mode 100644 drivers/soc/fsl/fman/flib/fsl_fman_tgec.h

diff --git a/drivers/soc/fsl/fman/flib/common/general.h b/drivers/soc/fsl/fman/flib/common/general.h
new file mode 100644
index 0000000..e5f56af
--- /dev/null
+++ b/drivers/soc/fsl/fman/flib/common/general.h
@@ -0,0 +1,45 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __GENERAL_H
+#define __GENERAL_H
+
+#include <linux/types.h>
+#include <linux/io.h>
+
+#define UNUSED(X)	(X = X)
+#define KILOBYTE	0x400UL	/* 1024 */
+
+#define iowrite32be(val, addr)		out_be32(&(*addr), val)
+#define ioread32be(addr)		in_be32(&(*addr))
+
+#endif /* __GENERAL_H */
diff --git a/drivers/soc/fsl/fman/flib/fman_common.h b/drivers/soc/fsl/fman/flib/fman_common.h
new file mode 100644
index 0000000..60f2bc4
--- /dev/null
+++ b/drivers/soc/fsl/fman/flib/fman_common.h
@@ -0,0 +1,74 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __FMAN_COMMON_H
+#define __FMAN_COMMON_H
+
+/* NIA Description */
+#define NIA_ORDER_RESTOR                        0x00800000
+#define NIA_ENG_FM_CTL                          0x00000000
+#define NIA_ENG_PRS                             0x00440000
+#define NIA_ENG_KG                              0x00480000
+#define NIA_ENG_PLCR                            0x004C0000
+#define NIA_ENG_BMI                             0x00500000
+#define NIA_ENG_QMI_ENQ                         0x00540000
+#define NIA_ENG_QMI_DEQ                         0x00580000
+#define NIA_ENG_MASK                            0x007C0000
+
+#define NIA_FM_CTL_AC_CC                        0x00000006
+#define NIA_FM_CTL_AC_HC                        0x0000000C
+#define NIA_FM_CTL_AC_IND_MODE_TX               0x00000008
+#define NIA_FM_CTL_AC_IND_MODE_RX               0x0000000A
+#define NIA_FM_CTL_AC_FRAG                      0x0000000e
+#define NIA_FM_CTL_AC_PRE_FETCH                 0x00000010
+#define NIA_FM_CTL_AC_POST_FETCH_PCD            0x00000012
+#define NIA_FM_CTL_AC_POST_FETCH_PCD_UDP_LEN    0x00000018
+#define NIA_FM_CTL_AC_POST_FETCH_NO_PCD         0x00000012
+#define NIA_FM_CTL_AC_FRAG_CHECK                0x00000014
+#define NIA_FM_CTL_AC_PRE_CC                    0x00000020
+
+#define NIA_BMI_AC_ENQ_FRAME                    0x00000002
+#define NIA_BMI_AC_TX_RELEASE                   0x000002C0
+#define NIA_BMI_AC_RELEASE                      0x000000C0
+#define NIA_BMI_AC_DISCARD                      0x000000C1
+#define NIA_BMI_AC_TX                           0x00000274
+#define NIA_BMI_AC_FETCH                        0x00000208
+#define NIA_BMI_AC_MASK                         0x000003FF
+
+#define NIA_KG_DIRECT                           0x00000100
+#define NIA_KG_CC_EN                            0x00000200
+#define NIA_PLCR_ABSOLUTE                       0x00008000
+
+#define NIA_BMI_AC_ENQ_FRAME_WITHOUT_DMA        0x00000202
+#define NIA_BMI_AC_FETCH_ALL_FRAME              0x0000020c
+
+#endif /* __FMAN_COMMON_H */
diff --git a/drivers/soc/fsl/fman/flib/fsl_enet.h b/drivers/soc/fsl/fman/flib/fsl_enet.h
new file mode 100644
index 0000000..cbfc91d
--- /dev/null
+++ b/drivers/soc/fsl/fman/flib/fsl_enet.h
@@ -0,0 +1,276 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __FSL_ENET_H
+#define __FSL_ENET_H
+
+/*Ethernet MAC-PHY Interface */
+
+enum enet_interface {
+	E_ENET_IF_MII = 0x00010000,	      /* MII interface */
+	E_ENET_IF_RMII = 0x00020000,	      /* RMII interface */
+	E_ENET_IF_SMII = 0x00030000,	      /* SMII interface */
+	E_ENET_IF_GMII = 0x00040000,	      /* GMII interface */
+	E_ENET_IF_RGMII = 0x00050000,	      /* RGMII interface */
+	E_ENET_IF_TBI = 0x00060000,	      /* TBI interface */
+	E_ENET_IF_RTBI = 0x00070000,	      /* RTBI interface */
+	E_ENET_IF_SGMII = 0x00080000,	      /* SGMII interface */
+	E_ENET_IF_XGMII = 0x00090000,	      /* XGMII interface */
+	E_ENET_IF_QSGMII = 0x000a0000,	      /* QSGMII interface */
+	E_ENET_IF_XFI = 0x000b0000	      /* XFI interface */
+};
+
+/* Ethernet Speed (nominal data rate) */
+enum enet_speed {
+	E_ENET_SPEED_10 = 10,		/* 10 Mbps */
+	E_ENET_SPEED_100 = 100,		/* 100 Mbps */
+	E_ENET_SPEED_1000 = 1000,	/* 1000 Mbps = 1 Gbps */
+	E_ENET_SPEED_10000 = 10000	/* 10000 Mbps = 10 Gbps */
+};
+
+enum mac_type {
+	E_MAC_DTSEC,
+	E_MAC_TGEC,
+	E_MAC_MEMAC
+};
+
+/* Enum for inter-module interrupts registration */
+enum fman_event_modules {
+	E_FMAN_MOD_PRS,			  /* Parser event */
+	E_FMAN_MOD_KG,			  /* Keygen event */
+	E_FMAN_MOD_PLCR,		  /* Policer event */
+	E_FMAN_MOD_10G_MAC,		  /* 10G MAC event */
+	E_FMAN_MOD_1G_MAC,		  /* 1G MAC event */
+	E_FMAN_MOD_TMR,			  /* Timer event */
+	E_FMAN_MOD_FMAN_CTRL,		  /* FMAN Controller  Timer event */
+	E_FMAN_MOD_MACSEC,
+	E_FMAN_MOD_DUMMY_LAST
+};
+
+/* Enum for interrupts types */
+enum fman_intr_type {
+	E_FMAN_INTR_TYPE_ERR,
+	E_FMAN_INTR_TYPE_NORMAL
+};
+
+/* enum for defining MAC types */
+enum fman_mac_type {
+	E_FMAN_MAC_10G = 0,		  /* 10G MAC */
+	E_FMAN_MAC_1G			  /* 1G MAC */
+};
+
+enum fman_mac_exceptions {
+	E_FMAN_MAC_EX_10G_MDIO_SCAN_EVENTMDIO = 0,
+		/* 10GEC MDIO scan event interrupt */
+	E_FMAN_MAC_EX_10G_MDIO_CMD_CMPL,
+		/* 10GEC MDIO command completion interrupt */
+	E_FMAN_MAC_EX_10G_REM_FAULT,
+		/* 10GEC, mEMAC Remote fault interrupt */
+	E_FMAN_MAC_EX_10G_LOC_FAULT,
+		/* 10GEC, mEMAC Local fault interrupt */
+	E_FMAN_MAC_EX_10G_1TX_ECC_ER,
+		/* 10GEC, mEMAC Transmit frame ECC error interrupt */
+	E_FMAN_MAC_EX_10G_TX_FIFO_UNFL,
+		/* 10GEC, mEMAC Transmit FIFO underflow interrupt */
+	E_FMAN_MAC_EX_10G_TX_FIFO_OVFL,
+		/* 10GEC, mEMAC Transmit FIFO overflow interrupt */
+	E_FMAN_MAC_EX_10G_TX_ER,
+		/* 10GEC Transmit frame error interrupt */
+	E_FMAN_MAC_EX_10G_RX_FIFO_OVFL,
+		/* 10GEC, mEMAC Receive FIFO overflow interrupt */
+	E_FMAN_MAC_EX_10G_RX_ECC_ER,
+		/* 10GEC, mEMAC Receive frame ECC error interrupt */
+	E_FMAN_MAC_EX_10G_RX_JAB_FRM,
+		/* 10GEC Receive jabber frame interrupt */
+	E_FMAN_MAC_EX_10G_RX_OVRSZ_FRM,
+		/* 10GEC Receive oversized frame interrupt */
+	E_FMAN_MAC_EX_10G_RX_RUNT_FRM,
+		/* 10GEC Receive runt frame interrupt */
+	E_FMAN_MAC_EX_10G_RX_FRAG_FRM,
+		/* 10GEC Receive fragment frame interrupt */
+	E_FMAN_MAC_EX_10G_RX_LEN_ER,
+		/* 10GEC Receive payload length error interrupt */
+	E_FMAN_MAC_EX_10G_RX_CRC_ER,
+		/* 10GEC Receive CRC error interrupt */
+	E_FMAN_MAC_EX_10G_RX_ALIGN_ER,
+		/* 10GEC Receive alignment error interrupt */
+	E_FMAN_MAC_EX_1G_BAB_RX,
+		/* dTSEC Babbling receive error */
+	E_FMAN_MAC_EX_1G_RX_CTL,
+		/* dTSEC Receive control (pause frame) interrupt */
+	E_FMAN_MAC_EX_1G_GRATEFUL_TX_STP_COMPLET,
+		/* dTSEC Graceful transmit stop complete */
+	E_FMAN_MAC_EX_1G_BAB_TX,
+		/* dTSEC Babbling transmit error */
+	E_FMAN_MAC_EX_1G_TX_CTL,
+		/* dTSEC Transmit control (pause frame) interrupt */
+	E_FMAN_MAC_EX_1G_TX_ERR,
+		/* dTSEC Transmit error */
+	E_FMAN_MAC_EX_1G_LATE_COL,
+		/* dTSEC Late collision */
+	E_FMAN_MAC_EX_1G_COL_RET_LMT,
+		/* dTSEC Collision retry limit */
+	E_FMAN_MAC_EX_1G_TX_FIFO_UNDRN,
+		/* dTSEC Transmit FIFO underrun */
+	E_FMAN_MAC_EX_1G_MAG_PCKT,
+		/* dTSEC Magic Packet detection */
+	E_FMAN_MAC_EX_1G_MII_MNG_RD_COMPLET,
+		/* dTSEC MII management read completion */
+	E_FMAN_MAC_EX_1G_MII_MNG_WR_COMPLET,
+		/* dTSEC MII management write completion */
+	E_FMAN_MAC_EX_1G_GRATEFUL_RX_STP_COMPLET,
+		/* dTSEC Graceful receive stop complete */
+	E_FMAN_MAC_EX_1G_TX_DATA_ERR,
+		/* dTSEC Internal data error on transmit */
+	E_FMAN_MAC_EX_1G_RX_DATA_ERR,
+		/* dTSEC Internal data error on receive */
+	E_FMAN_MAC_EX_1G_1588_TS_RX_ERR,
+		/* dTSEC Time-Stamp Receive Error */
+	E_FMAN_MAC_EX_1G_RX_MIB_CNT_OVFL,
+		/* dTSEC MIB counter overflow */
+	E_FMAN_MAC_EX_TS_FIFO_ECC_ERR,
+		/* < mEMAC Time-stamp FIFO ECC error interrupt;
+		 * not supported on T4240/B4860 rev1 chips
+		 */
+};
+
+/* SGMII/QSGII interface with 1000BaseX auto-negotiation between MAC
+ * and phy or backplane;
+ * Note: 1000BaseX auto-negotiation relates only to interface between MAC
+ * and phy/backplane, SGMII phy can still synchronize with far-end phy at
+ * 10Mbps, 100Mbps or 1000Mbps
+ */
+#define ENET_IF_SGMII_BASEX 0x80000000
+
+enum enet_mode {
+	E_ENET_MODE_INVALID = 0,
+		/* Invalid Ethernet mode */
+	E_ENET_MODE_MII_10 = (E_ENET_IF_MII | E_ENET_SPEED_10),
+		/*    10 Mbps MII   */
+	E_ENET_MODE_MII_100 = (E_ENET_IF_MII | E_ENET_SPEED_100),
+		/*   100 Mbps MII   */
+	E_ENET_MODE_RMII_10 = (E_ENET_IF_RMII | E_ENET_SPEED_10),
+		/*    10 Mbps RMII  */
+	E_ENET_MODE_RMII_100 = (E_ENET_IF_RMII | E_ENET_SPEED_100),
+		/*   100 Mbps RMII  */
+	E_ENET_MODE_SMII_10 = (E_ENET_IF_SMII | E_ENET_SPEED_10),
+		/*    10 Mbps SMII  */
+	E_ENET_MODE_SMII_100 = (E_ENET_IF_SMII | E_ENET_SPEED_100),
+		/*   100 Mbps SMII  */
+	E_ENET_MODE_GMII_1000 = (E_ENET_IF_GMII | E_ENET_SPEED_1000),
+		/*  1000 Mbps GMII  */
+	E_ENET_MODE_RGMII_10 = (E_ENET_IF_RGMII | E_ENET_SPEED_10),
+		/*    10 Mbps RGMII */
+	E_ENET_MODE_RGMII_100 = (E_ENET_IF_RGMII | E_ENET_SPEED_100),
+		/*   100 Mbps RGMII */
+	E_ENET_MODE_RGMII_1000 = (E_ENET_IF_RGMII | E_ENET_SPEED_1000),
+		/*  1000 Mbps RGMII */
+	E_ENET_MODE_TBI_1000 = (E_ENET_IF_TBI | E_ENET_SPEED_1000),
+		/*  1000 Mbps TBI   */
+	E_ENET_MODE_RTBI_1000 = (E_ENET_IF_RTBI | E_ENET_SPEED_1000),
+		/*  1000 Mbps RTBI  */
+	E_ENET_MODE_SGMII_10 = (E_ENET_IF_SGMII | E_ENET_SPEED_10),
+		/* 10 Mbps SGMII with auto-negotiation between MAC and
+		 * SGMII phy according to Cisco SGMII specification
+		 */
+	E_ENET_MODE_SGMII_100 = (E_ENET_IF_SGMII | E_ENET_SPEED_100),
+		/* 100 Mbps SGMII with auto-negotiation between MAC and
+		 * SGMII phy according to Cisco SGMII specification
+		 */
+	E_ENET_MODE_SGMII_1000 = (E_ENET_IF_SGMII | E_ENET_SPEED_1000),
+		/* 1000 Mbps SGMII with auto-negotiation between MAC and
+		 * SGMII phy according to Cisco SGMII specification
+		 */
+	E_ENET_MODE_SGMII_BASEX_10 = (ENET_IF_SGMII_BASEX | E_ENET_IF_SGMII
+				      | E_ENET_SPEED_10),
+		/* 10 Mbps SGMII with 1000BaseX auto-negotiation between
+		 * MAC and SGMII phy or backplane
+		 */
+	E_ENET_MODE_SGMII_BASEX_100 = (ENET_IF_SGMII_BASEX | E_ENET_IF_SGMII
+				       | E_ENET_SPEED_100),
+		/* 100 Mbps SGMII with 1000BaseX auto-negotiation between
+		 * MAC and SGMII phy or backplane
+		 */
+	E_ENET_MODE_SGMII_BASEX_1000 = (ENET_IF_SGMII_BASEX | E_ENET_IF_SGMII
+					| E_ENET_SPEED_1000),
+		/* 1000 Mbps SGMII with 1000BaseX auto-negotiation between
+		 * MAC and SGMII phy or backplane
+		 */
+	E_ENET_MODE_QSGMII_1000 = (E_ENET_IF_QSGMII | E_ENET_SPEED_1000),
+		/* 1000 Mbps QSGMII with auto-negotiation between MAC and
+		 * QSGMII phy according to Cisco QSGMII specification
+		 */
+	E_ENET_MODE_QSGMII_BASEX_1000 = (ENET_IF_SGMII_BASEX | E_ENET_IF_QSGMII
+					 | E_ENET_SPEED_1000),
+		/* 1000 Mbps QSGMII with 1000BaseX auto-negotiation between
+		 * MAC and QSGMII phy or backplane
+		 */
+	E_ENET_MODE_XGMII_10000 = (E_ENET_IF_XGMII | E_ENET_SPEED_10000),
+		/* 10000 Mbps XGMII */
+	E_ENET_MODE_XFI_10000 = (E_ENET_IF_XFI | E_ENET_SPEED_10000)
+		/* 10000 Mbps XFI */
+};
+
+enum fmam_mac_statistics_level {
+	E_FMAN_MAC_NONE_STATISTICS,	/* No statistics */
+	E_FMAN_MAC_PARTIAL_STATISTICS,	/* Only error counters are available;
+					 * Optimized for performance
+					 */
+	E_FMAN_MAC_FULL_STATISTICS	/* All counters available; Not
+					 * optimized for performance
+					 */
+};
+
+#define _MAKE_ENET_MODE(_interface, _speed) (enum enet_mode)((_interface) \
+	| (_speed))
+
+#define _ENET_INTERFACE_FROM_MODE(mode) \
+	((enum enet_interface)((mode) & 0x0FFF0000))
+
+#define _ENET_SPEED_FROM_MODE(mode) (enum enet_speed)((mode) & 0x0000FFFF)
+#define _ENET_ADDR_TO_UINT64(_enet_addr)		\
+	(uint64_t)(((uint64_t)(_enet_addr)[0] << 40) |	\
+		((uint64_t)(_enet_addr)[1] << 32) |	\
+		((uint64_t)(_enet_addr)[2] << 24) |	\
+		((uint64_t)(_enet_addr)[3] << 16) |	\
+		((uint64_t)(_enet_addr)[4] << 8) |	\
+		((uint64_t)(_enet_addr)[5]))
+
+#define _MAKE_ENET_ADDR_FROM_UINT64(_addr64, _enet_addr)		\
+	do {								\
+		int i;							\
+		for (i = 0; i < ENET_NUM_OCTETS_PER_ADDRESS; i++)	\
+			(_enet_addr)[i] =				\
+				(uint8_t)((_addr64) >> ((5 - i) * 8));	\
+	} while (0)
+
+#endif /* __FSL_ENET_H */
diff --git a/drivers/soc/fsl/fman/flib/fsl_fman.h b/drivers/soc/fsl/fman/flib/fsl_fman.h
new file mode 100644
index 0000000..76fd991
--- /dev/null
+++ b/drivers/soc/fsl/fman/flib/fsl_fman.h
@@ -0,0 +1,801 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __FSL_FMAN_H
+#define __FSL_FMAN_H
+
+#include "common/general.h"
+#include <linux/delay.h>
+
+struct fman_ext_pool_params {
+	uint8_t id;		       /* External buffer pool id */
+	uint16_t size;		       /* External buffer pool buffer size */
+};
+
+struct fman_ext_pools {
+	uint8_t num_pools_used;	       /* Number of pools use by this port */
+	struct fman_ext_pool_params *ext_buf_pool;
+					/* Parameters for each port */
+};
+
+struct fman_backup_bm_pools {
+	uint8_t num_backup_pools;	/* Number of BM backup pools -
+					 * must be smaller than the total
+					 * number of pools defined for the
+					 * specified port.
+					 */
+	uint8_t *pool_ids;		/* num_of_backup_pools pool id's,
+					 * specifying which pools should be
+					 * used only as backup. Pool id's
+					 * specified here must be a subset
+					 * of the pools used by the specified
+					 * port.
+					 */
+};
+
+/* A structure for defining BM pool depletion criteria */
+struct fman_buf_pool_depletion {
+	bool buf_pool_depletion_enabled;
+	bool pools_grp_mode_enable;    /* select mode in which pause frames
+					* will be sent after a number of pools
+					* (all together!) are depleted
+					*/
+	uint8_t num_pools;	       /* the number of depleted pools that
+					* will invoke pause frames transmission.
+					*/
+	bool *pools_to_consider;       /* For each pool, true if it should be
+					* considered for depletion (Note - this
+					* pool must be used by this port!).
+					*/
+	bool single_pool_mode_enable;  /* select mode in which pause frames
+					* will be sent after a single-pool
+					* is depleted;
+					*/
+	bool *pools_to_consider_for_single_mode;
+				       /* For each pool, true if it should be
+					* considered for depletion (Note - this
+					* pool must be used by this port!)
+					*/
+	bool has_pfc_priorities;
+	bool *pfc_priorities_en;       /* This field is used by the MAC as
+					* the Priority Enable Vector in the PFC
+					* frame which is transmitted
+					*/
+};
+
+/* Enum for defining port DMA swap mode */
+enum fman_dma_swap_option {
+	FMAN_DMA_NO_SWP,	   /* No swap, transfer data as is.*/
+	FMAN_DMA_SWP_PPC_LE,	   /* The transferred data should be swapped
+				    * in PowerPc Little Endian mode.
+				    */
+	FMAN_DMA_SWP_BE		   /* The transferred data should be swapped
+				    * in Big Endian mode
+				    */
+};
+
+/* Enum for defining port DMA cache attributes */
+enum fman_dma_cache_option {
+	FMAN_DMA_NO_STASH = 0,	   /* Cacheable, no Allocate (No Stashing) */
+	FMAN_DMA_STASH = 1	   /* Cacheable and Allocate (Stashing on) */
+};
+
+typedef struct fm_prs_result_t fm_prs_result;
+typedef enum e_enet_mode enet_mode_t;
+
+struct fman_revision_info {
+	uint8_t major_rev;			/* Major revision */
+	uint8_t minor_rev;			/* Minor revision */
+};
+
+/* sizes */
+#define CAPWAP_FRAG_EXTRA_SPACE                 32
+#define OFFSET_UNITS                            16
+#define MAX_INT_OFFSET                          240
+#define MAX_IC_SIZE                             256
+#define MAX_EXT_OFFSET                          496
+#define MAX_EXT_BUFFER_OFFSET                   511
+
+/* Memory Mapped Registers */
+#define FMAN_LIODN_TBL	64	/* size of LIODN table */
+
+struct fman_fpm_regs {
+	uint32_t fmfp_tnc;	/* FPM TNUM Control 0x00 */
+	uint32_t fmfp_prc;	/* FPM Port_ID FmCtl Association 0x04 */
+	uint32_t fmfp_brkc;		/* FPM Breakpoint Control 0x08 */
+	uint32_t fmfp_mxd;	/* FPM Flush Control 0x0c */
+	uint32_t fmfp_dist1;	/* FPM Dispatch Thresholds1 0x10 */
+	uint32_t fmfp_dist2;	/* FPM Dispatch Thresholds2 0x14 */
+	uint32_t fm_epi;	/* FM Error Pending Interrupts 0x18 */
+	uint32_t fm_rie;	/* FM Error Interrupt Enable 0x1c */
+	uint32_t fmfp_fcev[4];	/* FPM FMan-Controller Event 1-4 0x20-0x2f */
+	uint32_t res0030[4];	/* res 0x30 - 0x3f */
+	uint32_t fmfp_cee[4];	/* PM FMan-Controller Event 1-4 0x40-0x4f */
+	uint32_t res0050[4];	/* res 0x50-0x5f */
+	uint32_t fmfp_tsc1;	/* FPM TimeStamp Control1 0x60 */
+	uint32_t fmfp_tsc2;	/* FPM TimeStamp Control2 0x64 */
+	uint32_t fmfp_tsp;	/* FPM Time Stamp 0x68 */
+	uint32_t fmfp_tsf;	/* FPM Time Stamp Fraction 0x6c */
+	uint32_t fm_rcr;	/* FM Rams Control 0x70 */
+	uint32_t fmfp_extc;	/* FPM External Requests Control 0x74 */
+	uint32_t fmfp_ext1;	/* FPM External Requests Config1 0x78 */
+	uint32_t fmfp_ext2;	/* FPM External Requests Config2 0x7c */
+	uint32_t fmfp_drd[16];	/* FPM Data_Ram Data 0-15 0x80 - 0xbf */
+	uint32_t fmfp_dra;	/* FPM Data Ram Access 0xc0 */
+	uint32_t fm_ip_rev_1;	/* FM IP Block Revision 1 0xc4 */
+	uint32_t fm_ip_rev_2;	/* FM IP Block Revision 2 0xc8 */
+	uint32_t fm_rstc;	/* FM Reset Command 0xcc */
+	uint32_t fm_cld;	/* FM Classifier Debug 0xd0 */
+	uint32_t fm_npi;	/* FM Normal Pending Interrupts 0xd4 */
+	uint32_t fmfp_exte;	/* FPM External Requests Enable 0xd8 */
+	uint32_t fmfp_ee;	/* FPM Event&Mask 0xdc */
+	uint32_t fmfp_cev[4];	/* FPM CPU Event 1-4 0xe0-0xef */
+	uint32_t res00f0[4];	/* res 0xf0-0xff */
+	uint32_t fmfp_ps[50];	/* FPM Port Status 0x100-0x1c7 */
+	uint32_t res01c8[14];	/* res 0x1c8-0x1ff */
+	uint32_t fmfp_clfabc;	/* FPM CLFABC 0x200 */
+	uint32_t fmfp_clfcc;	/* FPM CLFCC 0x204 */
+	uint32_t fmfp_clfaval;	/* FPM CLFAVAL 0x208 */
+	uint32_t fmfp_clfbval;	/* FPM CLFBVAL 0x20c */
+	uint32_t fmfp_clfcval;	/* FPM CLFCVAL 0x210 */
+	uint32_t fmfp_clfamsk;	/* FPM CLFAMSK 0x214 */
+	uint32_t fmfp_clfbmsk;	/* FPM CLFBMSK 0x218 */
+	uint32_t fmfp_clfcmsk;	/* FPM CLFCMSK 0x21c */
+	uint32_t fmfp_clfamc;	/* FPM CLFAMC 0x220 */
+	uint32_t fmfp_clfbmc;	/* FPM CLFBMC 0x224 */
+	uint32_t fmfp_clfcmc;	/* FPM CLFCMC 0x228 */
+	uint32_t fmfp_decceh;	/* FPM DECCEH 0x22c */
+	uint32_t res0230[116];	/* res 0x230 - 0x3ff */
+	uint32_t fmfp_ts[128];	/* 0x400: FPM Task Status 0x400 - 0x5ff */
+	uint32_t res0600[0x400 - 384];
+};
+
+struct fman_bmi_regs {
+	uint32_t fmbm_init; /* BMI Initialization 0x00 */
+	uint32_t fmbm_cfg1; /* BMI Configuration 1 0x04 */
+	uint32_t fmbm_cfg2; /* BMI Configuration 2 0x08 */
+	uint32_t res000c[5]; /* 0x0c - 0x1f */
+	uint32_t fmbm_ievr; /* Interrupt Event Register 0x20 */
+	uint32_t fmbm_ier; /* Interrupt Enable Register 0x24 */
+	uint32_t fmbm_ifr; /* Interrupt Force Register 0x28 */
+	uint32_t res002c[5]; /* 0x2c - 0x3f */
+	uint32_t fmbm_arb[8]; /* BMI Arbitration 0x40 - 0x5f */
+	uint32_t res0060[12]; /*0x60 - 0x8f */
+	uint32_t fmbm_dtc[3]; /* Debug Trap Counter 0x90 - 0x9b */
+	uint32_t res009c; /* 0x9c */
+	uint32_t fmbm_dcv[3][4]; /* Debug Compare val 0xa0-0xcf */
+	uint32_t fmbm_dcm[3][4]; /* Debug Compare Mask 0xd0-0xff */
+	uint32_t fmbm_gde; /* BMI Global Debug Enable 0x100 */
+	uint32_t fmbm_pp[63]; /* BMI Port Parameters 0x104 - 0x1ff */
+	uint32_t res0200; /* 0x200 */
+	uint32_t fmbm_pfs[63]; /* BMI Port FIFO Size 0x204 - 0x2ff */
+	uint32_t res0300; /* 0x300 */
+	uint32_t fmbm_spliodn[63]; /* Port Partition ID 0x304 - 0x3ff */
+};
+
+struct fman_qmi_regs {
+	uint32_t fmqm_gc; /* General Configuration Register 0x00 */
+	uint32_t res0004; /* 0x04 */
+	uint32_t fmqm_eie; /* Error Interrupt Event Register 0x08 */
+	uint32_t fmqm_eien; /* Error Interrupt Enable Register 0x0c */
+	uint32_t fmqm_eif; /* Error Interrupt Force Register 0x10 */
+	uint32_t fmqm_ie; /* Interrupt Event Register 0x14 */
+	uint32_t fmqm_ien; /* Interrupt Enable Register 0x18 */
+	uint32_t fmqm_if; /* Interrupt Force Register 0x1c */
+	uint32_t fmqm_gs; /* Global Status Register 0x20 */
+	uint32_t fmqm_ts; /* Task Status Register 0x24 */
+	uint32_t fmqm_etfc; /* Enqueue Total Frame Counter 0x28 */
+	uint32_t fmqm_dtfc; /* Dequeue Total Frame Counter 0x2c */
+	uint32_t fmqm_dc0; /* Dequeue Counter 0 0x30 */
+	uint32_t fmqm_dc1; /* Dequeue Counter 1 0x34 */
+	uint32_t fmqm_dc2; /* Dequeue Counter 2 0x38 */
+	uint32_t fmqm_dc3; /* Dequeue Counter 3 0x3c */
+	uint32_t fmqm_dfdc; /* Dequeue FQID from Default Counter 0x40 */
+	uint32_t fmqm_dfcc; /* Dequeue FQID from Context Counter 0x44 */
+	uint32_t fmqm_dffc; /* Dequeue FQID from FD Counter 0x48 */
+	uint32_t fmqm_dcc; /* Dequeue Confirm Counter 0x4c */
+	uint32_t res0050[7]; /* 0x50 - 0x6b */
+	uint32_t fmqm_tapc; /* Tnum Aging Period Control 0x6c */
+	uint32_t fmqm_dmcvc; /* Dequeue MAC Command Valid Counter 0x70 */
+	uint32_t fmqm_difdcc; /* Dequeue Invalid FD Command Counter 0x74 */
+	uint32_t fmqm_da1v; /* Dequeue A1 Valid Counter 0x78 */
+	uint32_t res007c; /* 0x7c */
+	uint32_t fmqm_dtc; /* 0x80 Debug Trap Counter 0x80 */
+	uint32_t fmqm_efddd; /* 0x84 Enqueue Frame desc Dynamic dbg 0x84 */
+	uint32_t res0088[2]; /* 0x88 - 0x8f */
+	struct {
+		uint32_t fmqm_dtcfg1; /* 0x90 dbg trap cfg 1 Register 0x00 */
+		uint32_t fmqm_dtval1; /* Debug Trap Value 1 Register 0x04 */
+		uint32_t fmqm_dtm1; /* Debug Trap Mask 1 Register 0x08 */
+		uint32_t fmqm_dtc1; /* Debug Trap Counter 1 Register 0x0c */
+		uint32_t fmqm_dtcfg2; /* dbg Trap cfg 2 Register 0x10 */
+		uint32_t fmqm_dtval2; /* Debug Trap Value 2 Register 0x14 */
+		uint32_t fmqm_dtm2; /* Debug Trap Mask 2 Register 0x18 */
+		uint32_t res001c; /* 0x1c */
+	} dbg_traps[3];	/* 0x90 - 0xef */
+	uint8_t res00f0[0x400 - 0xf0]; /* 0xf0 - 0x3ff */
+};
+
+struct fman_dma_regs {
+	uint32_t fmdmsr; /* FM DMA status register 0x00 */
+	uint32_t fmdmmr; /* FM DMA mode register 0x04 */
+	uint32_t fmdmtr; /* FM DMA bus threshold register 0x08 */
+	uint32_t fmdmhy; /* FM DMA bus hysteresis register 0x0c */
+	uint32_t fmdmsetr; /* FM DMA SOS emergency Threshold Register 0x10 */
+	uint32_t fmdmtah; /* FM DMA transfer bus address high reg 0x14 */
+	uint32_t fmdmtal; /* FM DMA transfer bus address low reg 0x18 */
+	uint32_t fmdmtcid; /* FM DMA transfer bus communication ID reg 0x1c */
+	uint32_t fmdmra; /* FM DMA bus internal ram address register 0x20 */
+	uint32_t fmdmrd; /* FM DMA bus internal ram data register 0x24 */
+	uint32_t fmdmwcr; /* FM DMA CAM watchdog counter value 0x28 */
+	uint32_t fmdmebcr; /* FM DMA CAM base in MURAM register 0x2c */
+	uint32_t fmdmccqdr; /* FM DMA CAM and CMD Queue Debug reg 0x30 */
+	uint32_t fmdmccqvr1; /* FM DMA CAM and CMD Queue Value reg #1 0x34 */
+	uint32_t fmdmccqvr2; /* FM DMA CAM and CMD Queue Value reg #2 0x38 */
+	uint32_t fmdmcqvr3; /* FM DMA CMD Queue Value register #3 0x3c */
+	uint32_t fmdmcqvr4; /* FM DMA CMD Queue Value register #4 0x40 */
+	uint32_t fmdmcqvr5; /* FM DMA CMD Queue Value register #5 0x44 */
+	uint32_t fmdmsefrc; /* FM DMA Semaphore Entry Full Reject Cntr 0x48 */
+	uint32_t fmdmsqfrc; /* FM DMA Semaphore Queue Full Reject Cntr 0x4c */
+	uint32_t fmdmssrc; /* FM DMA Semaphore SYNC Reject Counter 0x50 */
+	uint32_t fmdmdcr;  /* FM DMA Debug Counter 0x54 */
+	uint32_t fmdmemsr; /* FM DMA Emergency Smoother Register 0x58 */
+	uint32_t res005c; /* 0x5c */
+	uint32_t fmdmplr[FMAN_LIODN_TBL / 2]; /* DMA LIODN regs 0x60-0xdf */
+	uint32_t res00e0[0x400 - 56];
+};
+
+struct fman_rg {
+	struct fman_fpm_regs __iomem *fpm_rg;
+	struct fman_dma_regs __iomem *dma_rg;
+	struct fman_bmi_regs __iomem *bmi_rg;
+	struct fman_qmi_regs __iomem *qmi_rg;
+};
+
+enum fman_dma_cache_override {
+	E_FMAN_DMA_NO_CACHE_OR = 0, /* No override of the Cache field */
+	E_FMAN_DMA_NO_STASH_DATA, /* No data stashing in system level cache */
+	E_FMAN_DMA_MAY_STASH_DATA, /* Stashing allowed in sys level cache */
+	E_FMAN_DMA_STASH_DATA /* Stashing performed in system level cache */
+};
+
+enum fman_dma_aid_mode {
+	E_FMAN_DMA_AID_OUT_PORT_ID = 0,		  /* 4 LSB of PORT_ID */
+	E_FMAN_DMA_AID_OUT_TNUM			  /* 4 LSB of TNUM */
+};
+
+enum fman_dma_dbg_cnt_mode {
+	E_FMAN_DMA_DBG_NO_CNT = 0, /* No counting */
+	E_FMAN_DMA_DBG_CNT_DONE, /* Count DONE commands */
+	E_FMAN_DMA_DBG_CNT_COMM_Q_EM, /* command Q emergency signal */
+	E_FMAN_DMA_DBG_CNT_INT_READ_EM,	/* Read buf emergency signal */
+	E_FMAN_DMA_DBG_CNT_INT_WRITE_EM, /* Write buf emergency signal */
+	E_FMAN_DMA_DBG_CNT_FPM_WAIT, /* FPM WAIT signal */
+	E_FMAN_DMA_DBG_CNT_SIGLE_BIT_ECC, /* Single bit ECC errors */
+	E_FMAN_DMA_DBG_CNT_RAW_WAR_PROT	/* RAW&WAR protection counter */
+};
+
+enum fman_dma_emergency_level {
+	E_FMAN_DMA_EM_EBS = 0, /* EBS emergency */
+	E_FMAN_DMA_EM_SOS /* SOS emergency */
+};
+
+enum fman_catastrophic_err {
+	E_FMAN_CATAST_ERR_STALL_PORT = 0, /* Port_ID stalled reset required */
+	E_FMAN_CATAST_ERR_STALL_TASK /* Only erroneous task is stalled */
+};
+
+enum fman_dma_err {
+	E_FMAN_DMA_ERR_CATASTROPHIC = 0, /* Catastrophic DMA error */
+	E_FMAN_DMA_ERR_REPORT /* Reported DMA error */
+};
+
+struct fman_cfg {
+	uint16_t liodn_bs_pr_port[FMAN_LIODN_TBL];	/* base per port */
+	bool en_counters;
+	uint8_t disp_limit_tsh;
+	uint8_t prs_disp_tsh;
+	uint8_t plcr_disp_tsh;
+	uint8_t kg_disp_tsh;
+	uint8_t bmi_disp_tsh;
+	uint8_t qmi_enq_disp_tsh;
+	uint8_t qmi_deq_disp_tsh;
+	uint8_t fm_ctl1_disp_tsh;
+	uint8_t fm_ctl2_disp_tsh;
+	enum fman_dma_cache_override dma_cache_override;
+	enum fman_dma_aid_mode dma_aid_mode;
+	bool dma_aid_override;
+	uint8_t dma_axi_dbg_num_of_beats;
+	uint8_t dma_cam_num_of_entries;
+	uint32_t dma_watchdog;
+	uint8_t dma_comm_qtsh_asrt_emer;
+	uint8_t dma_write_buf_tsh_asrt_emer;
+	uint8_t dma_read_buf_tsh_asrt_emer;
+	uint8_t dma_comm_qtsh_clr_emer;
+	uint8_t dma_write_buf_tsh_clr_emer;
+	uint8_t dma_read_buf_tsh_clr_emer;
+	uint32_t dma_sos_emergency;
+	enum fman_dma_dbg_cnt_mode dma_dbg_cnt_mode;
+	bool dma_stop_on_bus_error;
+	bool dma_en_emergency;
+	uint32_t dma_emergency_bus_select;
+	enum fman_dma_emergency_level dma_emergency_level;
+	bool dma_en_emergency_smoother;
+	uint32_t dma_emergency_switch_counter;
+	bool halt_on_external_activ;
+	bool halt_on_unrecov_ecc_err;
+	enum fman_catastrophic_err catastrophic_err;
+	enum fman_dma_err dma_err;
+	bool en_muram_test_mode;
+	bool en_iram_test_mode;
+	bool external_ecc_rams_enable;
+	uint16_t tnum_aging_period;
+	uint32_t exceptions;
+	uint16_t clk_freq;
+	bool pedantic_dma;
+	uint32_t cam_base_addr;
+	uint32_t fifo_base_addr;
+	uint32_t total_fifo_size;
+	uint8_t total_num_of_tasks;
+	bool qmi_deq_option_support;
+	uint32_t qmi_def_tnums_thresh;
+	bool fman_partition_array;
+	uint8_t num_of_fman_ctrl_evnt_regs;
+};
+
+/* Exceptions */
+#define FMAN_EX_DMA_BUS_ERROR			0x80000000
+#define FMAN_EX_DMA_READ_ECC			0x40000000
+#define FMAN_EX_DMA_SYSTEM_WRITE_ECC		0x20000000
+#define FMAN_EX_DMA_FM_WRITE_ECC		0x10000000
+#define FMAN_EX_FPM_STALL_ON_TASKS		0x08000000
+#define FMAN_EX_FPM_SINGLE_ECC			0x04000000
+#define FMAN_EX_FPM_DOUBLE_ECC			0x02000000
+#define FMAN_EX_QMI_SINGLE_ECC			0x01000000
+#define FMAN_EX_QMI_DEQ_FROM_UNKNOWN_PORTID	0x00800000
+#define FMAN_EX_QMI_DOUBLE_ECC			0x00400000
+#define FMAN_EX_BMI_LIST_RAM_ECC		0x00200000
+#define FMAN_EX_BMI_PIPELINE_ECC		0x00100000
+#define FMAN_EX_BMI_STATISTICS_RAM_ECC		0x00080000
+#define FMAN_EX_IRAM_ECC			0x00040000
+#define FMAN_EX_NURAM_ECC			0x00020000
+#define FMAN_EX_BMI_DISPATCH_RAM_ECC		0x00010000
+
+enum fman_exceptions {
+	E_FMAN_EX_DMA_BUS_ERROR = 0, /* DMA bus error. */
+	E_FMAN_EX_DMA_READ_ECC,	/* Read Buffer ECC error */
+	E_FMAN_EX_DMA_SYSTEM_WRITE_ECC,	/* Write Buffer ECC err on sys side */
+	E_FMAN_EX_DMA_FM_WRITE_ECC, /* Write Buffer ECC error on FM side */
+	E_FMAN_EX_FPM_STALL_ON_TASKS, /* Stall of tasks on FPM */
+	E_FMAN_EX_FPM_SINGLE_ECC, /* Single ECC on FPM. */
+	E_FMAN_EX_FPM_DOUBLE_ECC, /* Double ECC error on FPM ram access */
+	E_FMAN_EX_QMI_SINGLE_ECC, /* Single ECC on QMI. */
+	E_FMAN_EX_QMI_DOUBLE_ECC, /* Double bit ECC occurred on QMI */
+	E_FMAN_EX_QMI_DEQ_FROM_UNKNOWN_PORTID,/* DeQ from unknown port id */
+	E_FMAN_EX_BMI_LIST_RAM_ECC, /* Linked List RAM ECC error */
+	E_FMAN_EX_BMI_STORAGE_PROFILE_ECC, /* storage profile */
+	E_FMAN_EX_BMI_STATISTICS_RAM_ECC, /* Statistics RAM ECC Err Enable */
+	E_FMAN_EX_BMI_DISPATCH_RAM_ECC,	/* Dispatch RAM ECC Error Enable */
+	E_FMAN_EX_IRAM_ECC, /* Double bit ECC occurred on IRAM*/
+	E_FMAN_EX_MURAM_ECC /* Double bit ECC occurred on MURAM*/
+};
+
+enum fman_counters {
+	E_FMAN_COUNTERS_ENQ_TOTAL_FRAME = 0, /* QMI tot enQ frames counter */
+	E_FMAN_COUNTERS_DEQ_TOTAL_FRAME, /* QMI tot deQ frames counter */
+	E_FMAN_COUNTERS_DEQ_0, /* QMI 0 frames from QMan counter */
+	E_FMAN_COUNTERS_DEQ_1, /* QMI 1 frames from QMan counter */
+	E_FMAN_COUNTERS_DEQ_2, /* QMI 2 frames from QMan counter */
+	E_FMAN_COUNTERS_DEQ_3, /* QMI 3 frames from QMan counter */
+	E_FMAN_COUNTERS_DEQ_FROM_DEFAULT, /* QMI deQ from dflt queue cntr */
+	E_FMAN_COUNTERS_DEQ_FROM_CONTEXT, /* QMI deQ from FQ context cntr */
+	E_FMAN_COUNTERS_DEQ_FROM_FD, /* QMI deQ from FD command field cntr */
+	E_FMAN_COUNTERS_DEQ_CONFIRM, /* QMI dequeue confirm counter */
+	E_FMAN_COUNTERS_SEMAPHOR_ENTRY_FULL_REJECT, /* DMA full entry cntr */
+	E_FMAN_COUNTERS_SEMAPHOR_QUEUE_FULL_REJECT, /* DMA full CAM Q cntr */
+	E_FMAN_COUNTERS_SEMAPHOR_SYNC_REJECT /* DMA sync counter */
+};
+
+#define FPM_PRT_FM_CTL1	0x00000001
+#define FPM_PRT_FM_CTL2	0x00000002
+
+/* DMA definitions */
+
+/* masks */
+#define DMA_MODE_AID_OR			0x20000000
+#define DMA_MODE_SBER			0x10000000
+#define DMA_MODE_BER			0x00200000
+#define DMA_MODE_EB             0x00100000
+#define DMA_MODE_ECC			0x00000020
+#define DMA_MODE_PRIVILEGE_PROT	0x00001000
+#define DMA_MODE_SECURE_PROT	0x00000800
+#define DMA_MODE_EMER_READ		0x00080000
+#define DMA_MODE_EMER_WRITE		0x00040000
+#define DMA_MODE_CACHE_OR_MASK  0xC0000000
+#define DMA_MODE_CEN_MASK       0x0000E000
+#define DMA_MODE_DBG_MASK       0x00000380
+#define DMA_MODE_AXI_DBG_MASK   0x0F000000
+
+#define DMA_EMSR_EMSTR_MASK         0x0000FFFF
+
+#define DMA_TRANSFER_PORTID_MASK	0xFF000000
+#define DMA_TRANSFER_TNUM_MASK		0x00FF0000
+#define DMA_TRANSFER_LIODN_MASK		0x00000FFF
+
+#define DMA_HIGH_LIODN_MASK		0x0FFF0000
+#define DMA_LOW_LIODN_MASK		0x00000FFF
+
+#define DMA_STATUS_CMD_QUEUE_NOT_EMPTY	0x10000000
+#define DMA_STATUS_BUS_ERR		0x08000000
+#define DMA_STATUS_READ_ECC		0x04000000
+#define DMA_STATUS_SYSTEM_WRITE_ECC	0x02000000
+#define DMA_STATUS_FM_WRITE_ECC		0x01000000
+#define DMA_STATUS_SYSTEM_DPEXT_ECC	0x00800000
+#define DMA_STATUS_FM_DPEXT_ECC		0x00400000
+#define DMA_STATUS_SYSTEM_DPDAT_ECC	0x00200000
+#define DMA_STATUS_FM_DPDAT_ECC		0x00100000
+#define DMA_STATUS_FM_SPDAT_ECC		0x00080000
+
+#define FM_LIODN_BASE_MASK		0x00000FFF
+
+/* shifts */
+#define DMA_MODE_CACHE_OR_SHIFT			30
+#define DMA_MODE_BUS_PRI_SHIFT			16
+#define DMA_MODE_AXI_DBG_SHIFT			24
+#define DMA_MODE_CEN_SHIFT			13
+#define DMA_MODE_BUS_PROT_SHIFT			10
+#define DMA_MODE_DBG_SHIFT			7
+#define DMA_MODE_EMER_LVL_SHIFT			6
+#define DMA_MODE_AID_MODE_SHIFT			4
+#define DMA_MODE_MAX_AXI_DBG_NUM_OF_BEATS	16
+#define DMA_MODE_MAX_CAM_NUM_OF_ENTRIES		32
+
+#define DMA_THRESH_COMMQ_SHIFT			24
+#define DMA_THRESH_READ_INT_BUF_SHIFT		16
+
+#define DMA_LIODN_SHIFT				16
+
+#define DMA_TRANSFER_PORTID_SHIFT		24
+#define DMA_TRANSFER_TNUM_SHIFT			16
+
+/* sizes */
+#define DMA_MAX_WATCHDOG			0xffffffff
+
+/* others */
+#define DMA_CAM_SIZEOF_ENTRY			0x40
+#define DMA_CAM_ALIGN				0x40
+#define DMA_CAM_UNITS				8
+
+/* General defines */
+
+#define FM_DEBUG_STATUS_REGISTER_OFFSET	0x000d1084UL
+#define FM_UCODE_DEBUG_INSTRUCTION	0x6ffff805UL
+
+/* FPM defines */
+
+/* masks */
+#define FPM_EV_MASK_DOUBLE_ECC		0x80000000
+#define FPM_EV_MASK_STALL		0x40000000
+#define FPM_EV_MASK_SINGLE_ECC		0x20000000
+#define FPM_EV_MASK_RELEASE_FM		0x00010000
+#define FPM_EV_MASK_DOUBLE_ECC_EN	0x00008000
+#define FPM_EV_MASK_STALL_EN		0x00004000
+#define FPM_EV_MASK_SINGLE_ECC_EN	0x00002000
+#define FPM_EV_MASK_EXTERNAL_HALT	0x00000008
+#define FPM_EV_MASK_ECC_ERR_HALT	0x00000004
+
+#define FPM_RAM_RAMS_ECC_EN		0x80000000
+#define FPM_RAM_IRAM_ECC_EN		0x40000000
+#define FPM_RAM_MURAM_ECC		0x00008000
+#define FPM_RAM_IRAM_ECC		0x00004000
+#define FPM_RAM_MURAM_TEST_ECC		0x20000000
+#define FPM_RAM_IRAM_TEST_ECC		0x10000000
+#define FPM_RAM_RAMS_ECC_EN_SRC_SEL	0x08000000
+
+#define FPM_IRAM_ECC_ERR_EX_EN		0x00020000
+#define FPM_MURAM_ECC_ERR_EX_EN		0x00040000
+
+#define FPM_REV1_MAJOR_MASK		0x0000FF00
+#define FPM_REV1_MINOR_MASK		0x000000FF
+
+#define FPM_REV2_INTEG_MASK		0x00FF0000
+#define FPM_REV2_ERR_MASK		0x0000FF00
+#define FPM_REV2_CFG_MASK		0x000000FF
+
+#define FPM_TS_FRACTION_MASK		0x0000FFFF
+#define FPM_TS_CTL_EN			0x80000000
+
+#define FPM_PRC_REALSE_STALLED		0x00800000
+
+#define FPM_PS_STALLED			0x00800000
+#define FPM_PS_FM_CTL1_SEL		0x80000000
+#define FPM_PS_FM_CTL2_SEL		0x40000000
+#define FPM_PS_FM_CTL_SEL_MASK	(FPM_PS_FM_CTL1_SEL | FPM_PS_FM_CTL2_SEL)
+
+#define FPM_RSTC_FM_RESET		0x80000000
+
+#define FPM_DISP_LIMIT_MASK             0x1F000000
+#define FPM_THR1_PRS_MASK               0xFF000000
+#define FPM_THR1_KG_MASK                0x00FF0000
+#define FPM_THR1_PLCR_MASK              0x0000FF00
+#define FPM_THR1_BMI_MASK               0x000000FF
+
+#define FPM_THR2_QMI_ENQ_MASK           0xFF000000
+#define FPM_THR2_QMI_DEQ_MASK           0x000000FF
+#define FPM_THR2_FM_CTL1_MASK           0x00FF0000
+#define FPM_THR2_FM_CTL2_MASK           0x0000FF00
+
+/* shifts */
+#define FPM_DISP_LIMIT_SHIFT		24
+
+#define FPM_THR1_PRS_SHIFT		24
+#define FPM_THR1_KG_SHIFT		16
+#define FPM_THR1_PLCR_SHIFT		8
+#define FPM_THR1_BMI_SHIFT		0
+
+#define FPM_THR2_QMI_ENQ_SHIFT		24
+#define FPM_THR2_QMI_DEQ_SHIFT		0
+#define FPM_THR2_FM_CTL1_SHIFT		16
+#define FPM_THR2_FM_CTL2_SHIFT		8
+
+#define FPM_EV_MASK_CAT_ERR_SHIFT	1
+#define FPM_EV_MASK_DMA_ERR_SHIFT	0
+
+#define FPM_REV1_MAJOR_SHIFT		8
+#define FPM_REV1_MINOR_SHIFT		0
+
+#define FPM_REV2_INTEG_SHIFT		16
+#define FPM_REV2_ERR_SHIFT		8
+#define FPM_REV2_CFG_SHIFT		0
+
+#define FPM_TS_INT_SHIFT		16
+
+#define FPM_PORT_FM_CTL_PORTID_SHIFT	24
+
+#define FPM_PS_FM_CTL_SEL_SHIFT		30
+#define FPM_PRC_ORA_FM_CTL_SEL_SHIFT	16
+
+#define FPM_DISP_LIMIT_SHIFT            24
+
+/* Interrupts defines */
+#define FPM_EVENT_FM_CTL_0		0x00008000
+#define FPM_EVENT_FM_CTL		0x0000FF00
+#define FPM_EVENT_FM_CTL_BRK		0x00000080
+
+/* others */
+#define FPM_MAX_DISP_LIMIT              31
+#define FPM_RSTC_FM_RESET               0x80000000
+#define FPM_RSTC_MAC0_RESET             0x40000000
+#define FPM_RSTC_MAC1_RESET             0x20000000
+#define FPM_RSTC_MAC2_RESET             0x10000000
+#define FPM_RSTC_MAC3_RESET             0x08000000
+#define FPM_RSTC_MAC8_RESET             0x04000000
+#define FPM_RSTC_MAC4_RESET             0x02000000
+#define FPM_RSTC_MAC5_RESET             0x01000000
+#define FPM_RSTC_MAC6_RESET             0x00800000
+#define FPM_RSTC_MAC7_RESET             0x00400000
+#define FPM_RSTC_MAC9_RESET             0x00200000
+/* BMI defines */
+/* masks */
+#define BMI_INIT_START				0x80000000
+#define BMI_ERR_INTR_EN_STORAGE_PROFILE_ECC	0x80000000
+#define BMI_ERR_INTR_EN_LIST_RAM_ECC		0x40000000
+#define BMI_ERR_INTR_EN_STATISTICS_RAM_ECC	0x20000000
+#define BMI_ERR_INTR_EN_DISPATCH_RAM_ECC	0x10000000
+#define BMI_NUM_OF_TASKS_MASK			0x3F000000
+#define BMI_NUM_OF_EXTRA_TASKS_MASK		0x000F0000
+#define BMI_NUM_OF_DMAS_MASK			0x00000F00
+#define BMI_NUM_OF_EXTRA_DMAS_MASK		0x0000000F
+#define BMI_FIFO_SIZE_MASK			0x000003FF
+#define BMI_EXTRA_FIFO_SIZE_MASK		0x03FF0000
+#define BMI_CFG2_DMAS_MASK			0x0000003F
+#define BMI_TOTAL_FIFO_SIZE_MASK           0x07FF0000
+#define BMI_TOTAL_NUM_OF_TASKS_MASK        0x007F0000
+
+/* shifts */
+#define BMI_CFG2_TASKS_SHIFT		16
+#define BMI_CFG2_DMAS_SHIFT		0
+#define BMI_CFG1_FIFO_SIZE_SHIFT	16
+#define BMI_FIFO_SIZE_SHIFT		0
+#define BMI_EXTRA_FIFO_SIZE_SHIFT	16
+#define BMI_NUM_OF_TASKS_SHIFT		24
+#define BMI_EXTRA_NUM_OF_TASKS_SHIFT	16
+#define BMI_NUM_OF_DMAS_SHIFT		8
+#define BMI_EXTRA_NUM_OF_DMAS_SHIFT	0
+
+/* others */
+#define BMI_FIFO_ALIGN			0x100
+#define FMAN_BMI_FIFO_UNITS		0x100
+
+/* QMI defines */
+/* masks */
+#define QMI_CFG_ENQ_EN			0x80000000
+#define QMI_CFG_DEQ_EN			0x40000000
+#define QMI_CFG_EN_COUNTERS		0x10000000
+#define QMI_CFG_SOFT_RESET		0x01000000
+#define QMI_CFG_DEQ_MASK		0x0000003F
+#define QMI_CFG_ENQ_MASK		0x00003F00
+
+#define QMI_ERR_INTR_EN_DOUBLE_ECC	0x80000000
+#define QMI_ERR_INTR_EN_DEQ_FROM_DEF	0x40000000
+#define QMI_INTR_EN_SINGLE_ECC		0x80000000
+
+/* shifts */
+#define QMI_CFG_ENQ_SHIFT		8
+#define QMI_TAPC_TAP			22
+
+#define QMI_GS_HALT_NOT_BUSY            0x00000002
+
+/* IRAM defines */
+/* masks */
+#define IRAM_IADD_AIE			0x80000000
+#define IRAM_READY			0x80000000
+
+uint32_t fman_get_bmi_err_event(struct fman_bmi_regs __iomem *bmi_rg);
+uint32_t fman_get_qmi_err_event(struct fman_qmi_regs __iomem *qmi_rg);
+uint32_t fman_get_dma_com_id(struct fman_dma_regs __iomem *dma_rg);
+uint64_t fman_get_dma_addr(struct fman_dma_regs __iomem *dma_rg);
+uint32_t fman_get_dma_err_event(struct fman_dma_regs __iomem *dma_rg);
+uint32_t fman_get_fpm_err_event(struct fman_fpm_regs __iomem *fpm_rg);
+uint32_t fman_get_muram_err_event(struct fman_fpm_regs __iomem *fpm_rg);
+uint32_t fman_get_iram_err_event(struct fman_fpm_regs __iomem *fpm_rg);
+uint32_t fman_get_qmi_event(struct fman_qmi_regs __iomem *qmi_rg);
+uint32_t fman_get_fpm_error_interrupts(struct fman_fpm_regs __iomem *fpm_rg);
+uint32_t fman_get_ctrl_intr(struct fman_fpm_regs __iomem *fpm_rg,
+			    uint8_t event_reg_id);
+uint8_t fman_get_qmi_deq_th(struct fman_qmi_regs __iomem *qmi_rg);
+uint8_t fman_get_qmi_enq_th(struct fman_qmi_regs __iomem *qmi_rg);
+uint16_t fman_get_size_of_fifo(struct fman_bmi_regs __iomem *bmi_rg,
+			       uint8_t port_id);
+uint32_t fman_get_total_fifo_size(struct fman_bmi_regs __iomem *bmi_rg);
+uint16_t fman_get_size_of_extra_fifo(struct fman_bmi_regs __iomem *bmi_rg,
+				     uint8_t port_id);
+uint8_t fman_get_num_of_tasks(struct fman_bmi_regs __iomem *bmi_rg,
+			      uint8_t port_id);
+uint8_t fman_get_num_extra_tasks(struct fman_bmi_regs __iomem *bmi_rg,
+				 uint8_t port_id);
+uint8_t fman_get_num_of_dmas(struct fman_bmi_regs __iomem *bmi_rg,
+			     uint8_t port_id);
+uint8_t fman_get_num_extra_dmas(struct fman_bmi_regs __iomem *bmi_rg,
+				uint8_t port_id);
+uint32_t fman_get_normal_pending(struct fman_fpm_regs __iomem *fpm_rg);
+uint32_t fman_get_controller_event(struct fman_fpm_regs __iomem *fpm_rg,
+				   uint8_t reg_id);
+uint32_t fman_get_error_pending(struct fman_fpm_regs __iomem *fpm_rg);
+void fman_get_revision(struct fman_fpm_regs __iomem *fpm_rg, uint8_t *major,
+		       uint8_t *minor);
+uint32_t fman_get_counter(struct fman_rg *fman_rg, enum fman_counters reg_name);
+uint32_t fman_get_dma_status(struct fman_dma_regs __iomem *dma_rg);
+
+int fman_set_erratum_10gmac_a004_wa(struct fman_fpm_regs __iomem *fpm_rg);
+void fman_set_ctrl_intr(struct fman_fpm_regs __iomem *fpm_rg,
+			uint8_t event_reg_id,
+			uint32_t enable_events);
+void fman_set_num_of_riscs_per_port(struct fman_fpm_regs __iomem *fpm_rg,
+				    uint8_t port_id,
+				    uint8_t num_fman_ctrls,
+				    uint32_t or_fman_ctrl);
+void fman_set_order_restoration_per_port(struct fman_fpm_regs __iomem *fpm_rg,
+					 uint8_t port_id, bool is_rx_port);
+void fman_set_qmi_enq_th(struct fman_qmi_regs __iomem *qmi_rg, uint8_t val);
+void fman_set_qmi_deq_th(struct fman_qmi_regs __iomem *qmi_rg, uint8_t val);
+void fman_set_liodn_per_port(struct fman_rg *fman_rg,
+			     uint8_t port_id,
+			     uint16_t liodn_base, uint16_t liodn_offset);
+void fman_set_size_of_fifo(struct fman_bmi_regs __iomem *bmi_rg,
+			   uint8_t port_id,
+			   uint32_t size_of_fifo, uint32_t extra_size_of_fifo);
+void fman_set_num_of_tasks(struct fman_bmi_regs __iomem *bmi_rg,
+			   uint8_t port_id,
+			   uint8_t num_of_tasks, uint8_t num_of_extra_tasks);
+void fman_set_num_of_open_dmas(struct fman_bmi_regs __iomem *bmi_rg,
+			       uint8_t port_id,
+			       uint8_t num_of_open_dmas,
+			       uint8_t num_of_extra_open_dmas,
+			       uint8_t total_num_of_dmas);
+void fman_set_ports_bandwidth(struct fman_bmi_regs __iomem *bmi_rg,
+			      uint8_t *weights);
+int fman_set_exception(struct fman_rg *fman_rg,
+		       enum fman_exceptions exception, bool enable);
+void fman_set_dma_emergency(struct fman_dma_regs __iomem *dma_rg,
+			    bool is_write,
+			    bool enable);
+void fman_set_dma_ext_bus_pri(struct fman_dma_regs __iomem *dma_rg,
+			      uint32_t pri);
+void fman_set_congestion_group_pfc_priority(uint32_t __iomem *cpg_rg,
+					    uint32_t congestion_group_id,
+					    uint8_t priority_bit_map,
+					    uint32_t reg_num);
+
+void fman_defconfig(struct fman_cfg *cfg);
+void fman_regconfig(struct fman_rg *fman_rg, struct fman_cfg *cfg);
+int fman_fpm_init(struct fman_fpm_regs __iomem *fpm_rg, struct fman_cfg *cfg);
+int fman_bmi_init(struct fman_bmi_regs __iomem *bmi_rg, struct fman_cfg *cfg);
+int fman_qmi_init(struct fman_qmi_regs __iomem *qmi_rg, struct fman_cfg *cfg);
+int fman_dma_init(struct fman_dma_regs __iomem *dma_rg, struct fman_cfg *cfg);
+void fman_free_resources(struct fman_rg *fman_rg);
+int fman_enable(struct fman_rg *fman_rg, struct fman_cfg *cfg);
+void fman_reset(struct fman_fpm_regs __iomem *fpm_rg);
+void fman_resume(struct fman_fpm_regs __iomem *fpm_rg);
+
+void fman_enable_time_stamp(struct fman_fpm_regs __iomem *fpm_rg,
+			    uint8_t count1ubit, uint16_t fm_clk_freq);
+void fman_enable_rams_ecc(struct fman_fpm_regs __iomem *fpm_rg);
+void fman_qmi_disable_dispatch_limit(struct fman_fpm_regs __iomem *fpm_rg);
+void fman_disable_rams_ecc(struct fman_fpm_regs __iomem *fpm_rg);
+void fman_resume_stalled_port(struct fman_fpm_regs __iomem *fpm_rg,
+			      uint8_t port_id);
+int fman_reset_mac(struct fman_fpm_regs __iomem *fpm_rg, uint8_t mac_id);
+bool fman_is_port_stalled(struct fman_fpm_regs __iomem *fpm_rg,
+			  uint8_t port_id);
+bool fman_rams_ecc_is_external_ctl(struct fman_fpm_regs __iomem *fpm_rg);
+bool fman_is_qmi_halt_not_busy_state(struct fman_qmi_regs __iomem *qmi_rg);
+int fman_modify_counter(struct fman_rg *fman_rg,
+			enum fman_counters reg_name, uint32_t val);
+void fman_force_intr(struct fman_rg *fman_rg, enum fman_exceptions exception);
+void fman_set_vsp_window(struct fman_bmi_regs __iomem *bmi_rg,
+			 uint8_t port_id,
+			 uint8_t base_storage_profile,
+			 uint8_t log2_num_of_profiles);
+
+/* default values */
+#define DEFAULT_CATASTROPHIC_ERR                E_FMAN_CATAST_ERR_STALL_PORT
+#define DEFAULT_DMA_ERR                         E_FMAN_DMA_ERR_CATASTROPHIC
+/* do not change! if changed, must be disabled for rev1 ! */
+#define DEFAULT_HALT_ON_EXTERNAL_ACTIVATION     false
+/* do not change! if changed, must be disabled for rev1 ! */
+#define DEFAULT_HALT_ON_UNRECOVERABLE_ECC_ERROR false
+#define DEFAULT_EXTERNAL_ECC_RAMS_ENABLE        false
+#define DEFAULT_AID_OVERRIDE                    false
+#define DEFAULT_AID_MODE                        E_FMAN_DMA_AID_OUT_TNUM
+#define DEFAULT_DMA_COMM_Q_LOW                  0x2A
+#define DEFAULT_DMA_COMM_Q_HIGH                 0x3F
+#define DEFAULT_CACHE_OVERRIDE                  E_FMAN_DMA_NO_CACHE_OR
+#define DEFAULT_DMA_CAM_NUM_OF_ENTRIES          64
+#define DEFAULT_DMA_DBG_CNT_MODE                E_FMAN_DMA_DBG_NO_CNT
+#define DEFAULT_DMA_EN_EMERGENCY                false
+#define DEFAULT_DMA_SOS_EMERGENCY               0
+#define DEFAULT_DMA_WATCHDOG                    0	/* disabled */
+#define DEFAULT_DMA_EN_EMERGENCY_SMOOTHER       false
+#define DEFAULT_DMA_EMERGENCY_SWITCH_COUNTER    0
+#define DEFAULT_DISP_LIMIT                      0
+#define DEFAULT_PRS_DISP_TH                     16
+#define DEFAULT_PLCR_DISP_TH                    16
+#define DEFAULT_KG_DISP_TH                      16
+#define DEFAULT_BMI_DISP_TH                     16
+#define DEFAULT_QMI_ENQ_DISP_TH                 16
+#define DEFAULT_QMI_DEQ_DISP_TH                 16
+#define DEFAULT_FM_CTL1_DISP_TH                 16
+#define DEFAULT_FM_CTL2_DISP_TH                 16
+#define DEFAULT_TNUM_AGING_PERIOD               4
+
+#endif /* __FSL_FMAN_H */
diff --git a/drivers/soc/fsl/fman/flib/fsl_fman_dtsec.h b/drivers/soc/fsl/fman/flib/fsl_fman_dtsec.h
new file mode 100644
index 0000000..104352c
--- /dev/null
+++ b/drivers/soc/fsl/fman/flib/fsl_fman_dtsec.h
@@ -0,0 +1,1017 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __FSL_FMAN_DTSEC_H
+#define __FSL_FMAN_DTSEC_H
+
+#include "common/general.h"
+#include "fsl_enet.h"
+
+/* dTSEC Init sequence
+ *To prepare dTSEC block for transfer use the following call sequence:
+ *- fman_dtsec_defconfig() - This step is optional and yet recommended. Its
+ *use is to obtain the default dTSEC configuration parameters.
+ *- Change dtsec configuration in &dtsec_cfg. This structure will be used
+ *to customize the dTSEC behavior.
+ *- fman_dtsec_init() - Applies the configuration on dTSEC hardware.  Note that
+ *dTSEC is initialized while both Tx and Rx are disabled.
+ *- fman_dtsec_set_mac_address() - Set the station address (mac address).
+ *This is used by dTSEC to match against received packets.
+ *
+ *- fman_dtsec_adjust_link() - Set the link speed and duplex parameters
+ *after the PHY establishes the link.
+ *- dtsec_enable_tx() and dtsec_enable_rx() to enable transmission and
+ *reception.
+ */
+
+/*  dTSEC Graceful stop
+ *To temporary stop dTSEC activity use fman_dtsec_stop_tx() and
+ *fman_dtsec_stop_rx(). Note that these functions request dTSEC graceful stop
+ *but return before this stop is complete.  To query for graceful stop
+ *completion use fman_dtsec_get_event() and check DTSEC_IEVENT_GTSC and
+ *DTSEC_IEVENT_GRSC bits. Alternatively the dTSEC interrupt mask can be set to
+ *enable graceful stop interrupts.
+ *To resume operation after graceful stop use fman_dtsec_start_tx() and
+ *fman_dtsec_start_rx().
+ */
+
+/* dTSEC interrupt handling
+ *
+ *This code does not provide an interrupt handler for dTSEC.  Instead this
+ *handler should be implemented and registered to the operating system by the
+ *caller.  Some primitives for accessing the event status and mask registers
+ *are provided.
+ *See "dTSEC Events" section for a list of events that dTSEC can generate.
+ */
+
+/*dTSEC Events
+ *Interrupt events cause dTSEC event bits to be set.  Software may poll the
+ *event register at any time to check for pending interrupts.  If an event
+ *occurs and its corresponding enable bit is set in the interrupt mask
+ *register, the event also causes a hardware interrupt at the PIC.
+ *To poll for event status use the fman_dtsec_get_event() function.
+ *To configure the interrupt mask use fman_dtsec_enable_interrupt() and
+ *fman_dtsec_disable_interrupt() functions.
+ *After servicing a dTSEC interrupt use fman_dtsec_ack_event to reset the
+ *serviced event bit.
+ *The following events may be signaled by dTSEC hardware:
+ *%DTSEC_IEVENT_BABR - Babbling receive error.  This bit indicates that
+ *a frame was received with length in excess of the MAC's maximum frame length
+ *register.
+ *%DTSEC_IEVENT_RXC - Receive control (pause frame) interrupt.  A pause
+ *control frame was received while Rx pause frame handling is enabled.
+ *Also see fman_dtsec_handle_rx_pause().
+ *%DTSEC_IEVENT_MSRO - MIB counter overflow.  The count for one of the MIB
+ *counters has exceeded the size of its register.
+ *%DTSEC_IEVENT_GTSC - Graceful transmit stop complete.  Graceful stop is now
+ *complete. The transmitter is in a stopped state, in which only pause frames
+ *can be transmitted.
+ *Also see fman_dtsec_stop_tx().
+ *%DTSEC_IEVENT_BABT - Babbling transmit error.  The transmitted frame length
+ *has exceeded the value in the MAC's Maximum Frame Length register.
+ *%DTSEC_IEVENT_TXC - Transmit control (pause frame) interrupt.  his bit
+ *indicates that a control frame was transmitted.
+ *%DTSEC_IEVENT_TXE - Transmit error.  This bit indicates that an error
+ *occurred on the transmitted channel.  This bit is set whenever any transmit
+ *error occurs which causes the dTSEC to discard all or part of a frame
+ *(LC, CRL, XFUN).
+ *%DTSEC_IEVENT_LC - Late collision.  This bit indicates that a collision
+ *occurred beyond the collision window (slot time) in half-duplex mode.
+ *The frame is truncated with a bad CRC and the remainder of the frame
+ *is discarded.
+ *%DTSEC_IEVENT_CRL - Collision retry limit.  is bit indicates that the number
+ *of successive transmission collisions has exceeded the MAC's half-duplex
+ *register's retransmission maximum count.  The frame is discarded without
+ *being transmitted and transmission of the next frame commences.  This only
+ *occurs while in half-duplex mode.
+ *The number of retransmit attempts can be set in
+ *&dtsec_halfdup_cfg.retransmit before calling fman_dtsec_init().
+ *%DTSEC_IEVENT_XFUN - Transmit FIFO underrun.  This bit indicates that the
+ *transmit FIFO became empty before the complete frame was transmitted.
+ *The frame is truncated with a bad CRC and the remainder of the frame is
+ *discarded.
+ *%DTSEC_IEVENT_MAG - TBD
+ *%DTSEC_IEVENT_MMRD - MII management read completion.
+ *%DTSEC_IEVENT_MMWR - MII management write completion.
+ *%DTSEC_IEVENT_GRSC - Graceful receive stop complete.  It allows the user to
+ *know if the system has completed the stop and it is safe to write to receive
+ *registers (status, control or configuration registers) that are used by the
+ *system during normal operation.
+ *%DTSEC_IEVENT_TDPE - Internal data error on transmit.  This bit indicates
+ *that the dTSEC has detected a parity error on its stored transmit data, which
+ *is likely to compromise the validity of recently transferred frames.
+ *%DTSEC_IEVENT_RDPE - Internal data error on receive.  This bit indicates that
+ *the dTSEC has detected a parity error on its stored receive data, which is
+ *likely to compromise the validity of recently transferred frames.
+ */
+/* Interrupt Mask Register (IMASK) */
+#define DTSEC_IMASK_BREN	0x80000000
+#define DTSEC_IMASK_RXCEN	0x40000000
+#define DTSEC_IMASK_MSROEN	0x04000000
+#define DTSEC_IMASK_GTSCEN	0x02000000
+#define DTSEC_IMASK_BTEN	0x01000000
+#define DTSEC_IMASK_TXCEN	0x00800000
+#define DTSEC_IMASK_TXEEN	0x00400000
+#define DTSEC_IMASK_LCEN	0x00040000
+#define DTSEC_IMASK_CRLEN	0x00020000
+#define DTSEC_IMASK_XFUNEN	0x00010000
+#define DTSEC_IMASK_ABRTEN	0x00008000
+#define DTSEC_IMASK_IFERREN	0x00004000
+#define DTSEC_IMASK_MAGEN	0x00000800
+#define DTSEC_IMASK_MMRDEN	0x00000400
+#define DTSEC_IMASK_MMWREN	0x00000200
+#define DTSEC_IMASK_GRSCEN	0x00000100
+#define DTSEC_IMASK_TDPEEN	0x00000002
+#define DTSEC_IMASK_RDPEEN	0x00000001
+
+#define DTSEC_EVENTS_MASK				\
+	((uint32_t)(DTSEC_IMASK_BREN    | \
+				DTSEC_IMASK_RXCEN   | \
+				DTSEC_IMASK_BTEN    | \
+				DTSEC_IMASK_TXCEN   | \
+				DTSEC_IMASK_TXEEN   | \
+				DTSEC_IMASK_ABRTEN  | \
+				DTSEC_IMASK_LCEN    | \
+				DTSEC_IMASK_CRLEN   | \
+				DTSEC_IMASK_XFUNEN  | \
+				DTSEC_IMASK_IFERREN | \
+				DTSEC_IMASK_MAGEN   | \
+				DTSEC_IMASK_TDPEEN  | \
+				DTSEC_IMASK_RDPEEN))
+
+/* dtsec timestamp event bits */
+#define TMR_PEMASK_TSREEN	0x00010000
+#define TMR_PEVENT_TSRE		0x00010000
+
+/* Group address bit indication */
+#define MAC_GROUP_ADDRESS	0x0000010000000000ULL
+/* size in bytes of L2 address */
+#define MAC_ADDRLEN		6
+
+#define DEFAULT_HALFDUP_ON		false
+#define DEFAULT_HALFDUP_RETRANSMIT	0xf
+#define DEFAULT_HALFDUP_COLL_WINDOW	0x37
+#define DEFAULT_HALFDUP_EXCESS_DEFER	true
+#define DEFAULT_HALFDUP_NO_BACKOFF	false
+#define DEFAULT_HALFDUP_BP_NO_BACKOFF	false
+#define DEFAULT_HALFDUP_ALT_BACKOFF_VAL	0x0A
+#define DEFAULT_HALFDUP_ALT_BACKOFF_EN	false
+#define DEFAULT_RX_DROP_BCAST		false
+#define DEFAULT_RX_SHORT_FRM		true
+#define DEFAULT_RX_LEN_CHECK		false
+#define DEFAULT_TX_PAD_CRC		true
+#define DEFAULT_TX_CRC			false
+#define DEFAULT_RX_CTRL_ACC		false
+#define DEFAULT_TX_PAUSE_TIME		0xf000
+#define DEFAULT_TBIPA			5
+#define DEFAULT_RX_PREPEND		0
+#define DEFAULT_PTP_TSU_EN		true
+#define DEFAULT_PTP_EXCEPTION_EN	true
+#define DEFAULT_PREAMBLE_LEN		7
+#define DEFAULT_RX_PREAMBLE		false
+#define DEFAULT_TX_PREAMBLE		false
+#define DEFAULT_LOOPBACK		false
+#define DEFAULT_RX_TIME_STAMP_EN	false
+#define DEFAULT_TX_TIME_STAMP_EN	false
+#define DEFAULT_RX_FLOW			true
+#define DEFAULT_TX_FLOW			true
+#define DEFAULT_RX_GROUP_HASH_EXD	false
+#define DEFAULT_TX_PAUSE_TIME_EXTD	0
+#define DEFAULT_RX_PROMISC		false
+#define DEFAULT_NON_BACK_TO_BACK_IPG1	0x40
+#define DEFAULT_NON_BACK_TO_BACK_IPG2	0x60
+#define DEFAULT_MIN_IFG_ENFORCEMENT	0x50
+#define DEFAULT_BACK_TO_BACK_IPG	0x60
+#define DEFAULT_MAXIMUM_FRAME		0x600
+#define DEFAULT_TBI_PHY_ADDR		5
+#define DEFAULT_WAKE_ON_LAN		false
+
+/* register related defines (bits, field offsets..) */
+#define DTSEC_ID1_ID			0xffff0000
+#define DTSEC_ID1_REV_MJ		0x0000FF00
+#define DTSEC_ID1_REV_MN		0x000000ff
+
+#define DTSEC_ID2_INT_REDUCED_OFF	0x00010000
+#define DTSEC_ID2_INT_NORMAL_OFF	0x00020000
+
+#define DTSEC_ECNTRL_CLRCNT		0x00004000
+#define DTSEC_ECNTRL_AUTOZ		0x00002000
+#define DTSEC_ECNTRL_STEN		0x00001000
+#define DTSEC_ECNTRL_CFG_RO		0x80000000
+#define DTSEC_ECNTRL_GMIIM		0x00000040
+#define DTSEC_ECNTRL_TBIM		0x00000020
+#define DTSEC_ECNTRL_SGMIIM		0x00000002
+#define DTSEC_ECNTRL_RPM		0x00000010
+#define DTSEC_ECNTRL_R100M		0x00000008
+#define DTSEC_ECNTRL_RMM		0x00000004
+#define DTSEC_ECNTRL_QSGMIIM		0x00000001
+
+#define DTSEC_TCTRL_THDF		0x00000800
+#define DTSEC_TCTRL_TTSE		0x00000040
+#define DTSEC_TCTRL_GTS			0x00000020
+#define DTSEC_TCTRL_TFC_PAUSE		0x00000010
+
+/* PTV offsets */
+#define PTV_PTE_OFST		16
+
+#define RCTRL_CFA		0x00008000
+#define RCTRL_GHTX		0x00000400
+#define RCTRL_RTSE		0x00000040
+#define RCTRL_GRS		0x00000020
+#define RCTRL_BC_REJ		0x00000010
+#define RCTRL_MPROM		0x00000008
+#define RCTRL_RSF		0x00000004
+#define RCTRL_UPROM		0x00000001
+#define RCTRL_PROM		(RCTRL_UPROM | RCTRL_MPROM)
+
+#define TMR_CTL_ESFDP		0x00000800
+#define TMR_CTL_ESFDE		0x00000400
+
+#define MACCFG1_SOFT_RESET	0x80000000
+#define MACCFG1_LOOPBACK	0x00000100
+#define MACCFG1_RX_FLOW		0x00000020
+#define MACCFG1_TX_FLOW		0x00000010
+#define MACCFG1_TX_EN		0x00000001
+#define MACCFG1_RX_EN		0x00000004
+
+#define MACCFG2_NIBBLE_MODE	0x00000100
+#define MACCFG2_BYTE_MODE	0x00000200
+#define MACCFG2_PRE_AM_RX_EN	0x00000080
+#define MACCFG2_PRE_AM_TX_EN	0x00000040
+#define MACCFG2_LENGTH_CHECK	0x00000010
+#define MACCFG2_MAGIC_PACKET_EN	0x00000008
+#define MACCFG2_PAD_CRC_EN	0x00000004
+#define MACCFG2_CRC_EN		0x00000002
+#define MACCFG2_FULL_DUPLEX	0x00000001
+
+#define PREAMBLE_LENGTH_SHIFT	12
+
+#define IPGIFG_NON_BACK_TO_BACK_IPG_1_SHIFT	24
+#define IPGIFG_NON_BACK_TO_BACK_IPG_2_SHIFT	16
+#define IPGIFG_MIN_IFG_ENFORCEMENT_SHIFT	8
+
+#define IPGIFG_NON_BACK_TO_BACK_IPG_1	0x7F000000
+#define IPGIFG_NON_BACK_TO_BACK_IPG_2	0x007F0000
+#define IPGIFG_MIN_IFG_ENFORCEMENT	0x0000FF00
+#define IPGIFG_BACK_TO_BACK_IPG		0x0000007F
+
+#define HAFDUP_ALT_BEB			0x00080000
+#define HAFDUP_BP_NO_BACKOFF		0x00040000
+#define HAFDUP_NO_BACKOFF		0x00020000
+#define HAFDUP_EXCESS_DEFER		0x00010000
+#define HAFDUP_COLLISION_WINDOW		0x000003ff
+
+#define HAFDUP_ALTERNATE_BEB_TRUNCATION_SHIFT	20
+#define HAFDUP_RETRANSMISSION_MAX_SHIFT		12
+#define HAFDUP_RETRANSMISSION_MAX		0x0000f000
+
+#define NUM_OF_HASH_REGS	8	/* Number of hash table registers */
+
+/* CAR1/2 bits */
+#define DTSEC_CAR1_TR64		0x80000000
+#define DTSEC_CAR1_TR127	0x40000000
+#define DTSEC_CAR1_TR255	0x20000000
+#define DTSEC_CAR1_TR511	0x10000000
+#define DTSEC_CAR1_TRK1		0x08000000
+#define DTSEC_CAR1_TRMAX	0x04000000
+#define DTSEC_CAR1_TRMGV	0x02000000
+
+#define DTSEC_CAR1_RBYT		0x00010000
+#define DTSEC_CAR1_RPKT		0x00008000
+#define DTSEC_CAR1_RFCS		0x00004000
+#define DTSEC_CAR1_RMCA		0x00002000
+#define DTSEC_CAR1_RBCA		0x00001000
+#define DTSEC_CAR1_RXCF		0x00000800
+#define DTSEC_CAR1_RXPF		0x00000400
+#define DTSEC_CAR1_RXUO		0x00000200
+#define DTSEC_CAR1_RALN		0x00000100
+#define DTSEC_CAR1_RFLR		0x00000080
+#define DTSEC_CAR1_RCDE		0x00000040
+#define DTSEC_CAR1_RCSE		0x00000020
+#define DTSEC_CAR1_RUND		0x00000010
+#define DTSEC_CAR1_ROVR		0x00000008
+#define DTSEC_CAR1_RFRG		0x00000004
+#define DTSEC_CAR1_RJBR		0x00000002
+#define DTSEC_CAR1_RDRP		0x00000001
+
+#define DTSEC_CAR2_TJBR		0x00080000
+#define DTSEC_CAR2_TFCS		0x00040000
+#define DTSEC_CAR2_TXCF		0x00020000
+#define DTSEC_CAR2_TOVR		0x00010000
+#define DTSEC_CAR2_TUND		0x00008000
+#define DTSEC_CAR2_TFRG		0x00004000
+#define DTSEC_CAR2_TBYT		0x00002000
+#define DTSEC_CAR2_TPKT		0x00001000
+#define DTSEC_CAR2_TMCA		0x00000800
+#define DTSEC_CAR2_TBCA		0x00000400
+#define DTSEC_CAR2_TXPF		0x00000200
+#define DTSEC_CAR2_TDFR		0x00000100
+#define DTSEC_CAR2_TEDF		0x00000080
+#define DTSEC_CAR2_TSCL		0x00000040
+#define DTSEC_CAR2_TMCL		0x00000020
+#define DTSEC_CAR2_TLCL		0x00000010
+#define DTSEC_CAR2_TXCL		0x00000008
+#define DTSEC_CAR2_TNCL		0x00000004
+#define DTSEC_CAR2_TDRP		0x00000001
+
+#define CAM1_ERRORS_ONLY \
+	(DTSEC_CAR1_RXPF | DTSEC_CAR1_RALN | DTSEC_CAR1_RFLR \
+	| DTSEC_CAR1_RCDE | DTSEC_CAR1_RCSE | DTSEC_CAR1_RUND \
+	| DTSEC_CAR1_ROVR | DTSEC_CAR1_RFRG | DTSEC_CAR1_RJBR \
+	| DTSEC_CAR1_RDRP)
+
+#define CAM2_ERRORS_ONLY (DTSEC_CAR2_TFCS | DTSEC_CAR2_TXPF | DTSEC_CAR2_TDRP)
+
+/* Group of dTSEC specific counters relating to the standard RMON MIB Group 1
+ * (or Ethernet) statistics.
+ */
+#define CAM1_MIB_GRP_1 \
+	(DTSEC_CAR1_RDRP | DTSEC_CAR1_RBYT | DTSEC_CAR1_RPKT | DTSEC_CAR1_RMCA\
+	| DTSEC_CAR1_RBCA | DTSEC_CAR1_RALN | DTSEC_CAR1_RUND | DTSEC_CAR1_ROVR\
+	| DTSEC_CAR1_RFRG | DTSEC_CAR1_RJBR \
+	| DTSEC_CAR1_TR64 | DTSEC_CAR1_TR127 | DTSEC_CAR1_TR255 \
+	| DTSEC_CAR1_TR511 | DTSEC_CAR1_TRMAX)
+
+#define CAM2_MIB_GRP_1 (DTSEC_CAR2_TNCL | DTSEC_CAR2_TDRP)
+
+/* memory map */
+
+struct dtsec_regs {
+	/* dTSEC General Control and Status Registers */
+	uint32_t tsec_id;	/* 0x000 ETSEC_ID register */
+	uint32_t tsec_id2;	/* 0x004 ETSEC_ID2 register */
+	uint32_t ievent;	/* 0x008 Interrupt event register */
+	uint32_t imask;		/* 0x00C Interrupt mask register */
+	uint32_t reserved0010[1];
+	uint32_t ecntrl;	/* 0x014 E control register */
+	uint32_t ptv;		/* 0x018 Pause time value register */
+	uint32_t tbipa;		/* 0x01C TBI PHY address register */
+	uint32_t tmr_ctrl;	/* 0x020 Time-stamp Control register */
+	uint32_t tmr_pevent;	/* 0x024 Time-stamp event register */
+	uint32_t tmr_pemask;	/* 0x028 Timer event mask register */
+	uint32_t reserved002c[5];
+	uint32_t tctrl;		/* 0x040 Transmit control register */
+	uint32_t reserved0044[3];
+	uint32_t rctrl;		/* 0x050 Receive control register */
+	uint32_t reserved0054[11];
+	uint32_t igaddr[8];	/* 0x080-0x09C Individual/group address */
+	uint32_t gaddr[8];	/* 0x0A0-0x0BC Group address registers 0-7 */
+	uint32_t reserved00c0[16];
+	uint32_t maccfg1;	/* 0x100 MAC configuration #1 */
+	uint32_t maccfg2;	/* 0x104 MAC configuration #2 */
+	uint32_t ipgifg;	/* 0x108 IPG/IFG */
+	uint32_t hafdup;	/* 0x10C Half-duplex */
+	uint32_t maxfrm;	/* 0x110 Maximum frame */
+	uint32_t reserved0114[10];
+	uint32_t ifstat;	/* 0x13C Interface status */
+	uint32_t macstnaddr1;	/* 0x140 Station Address,part 1 */
+	uint32_t macstnaddr2;	/* 0x144 Station Address,part 2  */
+	struct {
+		uint32_t exact_match1;	/* octets 1-4 */
+		uint32_t exact_match2;	/* octets 5-6 */
+	} macaddr[15];		/* 0x148-0x1BC mac exact match addresses 1-15 */
+	uint32_t reserved01c0[16];
+	/* 0x200 transmit and receive 64 byte frame counter */
+	uint32_t tr64;
+	/* 0x204 transmit and receive 65 to 127 byte frame counter */
+	uint32_t tr127;
+	/* 0x208 transmit and receive 128 to 255 byte frame counter */
+	uint32_t tr255;
+	/* 0x20C transmit and receive 256 to 511 byte frame counter */
+	uint32_t tr511;
+	/* 0x210 transmit and receive 512 to 1023 byte frame counter */
+	uint32_t tr1k;
+	/* 0x214 transmit and receive 1024 to 1518 byte frame counter */
+	uint32_t trmax;
+	/* 0x218 transmit and receive 1519 to 1522 byte good VLAN frame count*/
+	uint32_t trmgv;
+	uint32_t rbyt;		/* 0x21C receive byte counter */
+	uint32_t rpkt;		/* 0x220 receive packet counter */
+	uint32_t rfcs;		/* 0x224 receive FCS error counter */
+	/* 0x228 RMCA receive multicast packet counter */
+	uint32_t rmca;
+	uint32_t rbca;		/* 0x22C receive broadcast packet counter */
+	uint32_t rxcf;		/* 0x230 receive control frame packet counter */
+	uint32_t rxpf;		/* 0x234 receive pause frame packet counter */
+	uint32_t rxuo;		/* 0x238 receive unknown OP code counter */
+	uint32_t raln;		/* 0x23C receive alignment error counter */
+	uint32_t rflr;		/* 0x240 receive frame length error counter */
+	uint32_t rcde;		/* 0x244 receive code error counter */
+	uint32_t rcse;		/* 0x248 receive carrier sense error counter */
+	uint32_t rund;		/* 0x24C receive undersize packet counter */
+	uint32_t rovr;		/* 0x250 receive oversize packet counter */
+	uint32_t rfrg;		/* 0x254 receive fragments counter */
+	uint32_t rjbr;		/* 0x258 receive jabber counter */
+	uint32_t rdrp;		/* 0x25C receive drop */
+	uint32_t tbyt;		/* 0x260 transmit byte counter */
+	uint32_t tpkt;		/* 0x264 transmit packet counter */
+	uint32_t tmca;		/* 0x268 transmit multicast packet counter */
+	uint32_t tbca;		/* 0x26C transmit broadcast packet counter */
+	uint32_t txpf;		/* 0x270 transmit pause control frame counter */
+	uint32_t tdfr;		/* 0x274 transmit deferral packet counter */
+	/* 0x278 transmit excessive deferral packet counter */
+	uint32_t tedf;
+	/* 0x27C transmit single collision packet counter */
+	uint32_t tscl;
+	/* 0x280 transmit multiple collision packet counter */
+	uint32_t tmcl;
+	/* 0x284 transmit late collision packet counter */
+	uint32_t tlcl;
+	/* 0x288 transmit excessive collision packet counter */
+	uint32_t txcl;
+	uint32_t tncl;		/* 0x28C transmit total collision counter */
+	uint32_t reserved0290[1];
+	uint32_t tdrp;		/* 0x294 transmit drop frame counter */
+	uint32_t tjbr;		/* 0x298 transmit jabber frame counter */
+	uint32_t tfcs;		/* 0x29C transmit FCS error counter */
+	uint32_t txcf;		/* 0x2A0 transmit control frame counter */
+	uint32_t tovr;		/* 0x2A4 transmit oversize frame counter */
+	uint32_t tund;		/* 0x2A8 transmit undersize frame counter */
+	uint32_t tfrg;		/* 0x2AC transmit fragments frame counter */
+	uint32_t car1;		/* 0x2B0 carry register one register* */
+	uint32_t car2;		/* 0x2B4 carry register two register* */
+	uint32_t cam1;		/* 0x2B8 carry register one mask register */
+	uint32_t cam2;		/* 0x2BC carry register two mask register */
+	uint32_t reserved02c0[848];
+};
+
+/*struct dtsec_mib_grp_1_counters - MIB counter overflows
+ *tr64:	Transmit and Receive 64 byte frame count.  Increment for each
+ *		good or bad frame, of any type, transmitted or received, which
+ *		is 64 bytes in length.
+ *tr127:	Transmit and Receive 65 to 127 byte frame count.  Increments for
+ *		each good or bad frame of any type, transmitted or received,
+ *		which is 65-127 bytes in length.
+ *tr255:	Transmit and Receive 128 to 255 byte frame count.  Increments
+ *		for each good or bad frame, of any type, transmitted or
+ *		received, which is 128-255 bytes in length.
+ *tr511:	Transmit and Receive 256 to 511 byte frame count.  Increments
+ *		for each good or bad frame, of any type, transmitted or
+ *		received, which is 256-511 bytes in length.
+ *tr1k:	Transmit and Receive 512 to 1023 byte frame count.  Increments
+ *		for each good or bad frame, of any type, transmitted or
+ *		received, which is 512-1023 bytes in length.
+ *trmax:	Transmit and Receive 1024 to 1518 byte frame count.  Increments
+ *		for each good or bad frame, of any type, transmitted or
+ *		received, which is 1024-1518 bytes in length.
+ *rfrg:	Receive fragments count.  Increments for each received frame
+ *		which is less than 64 bytes in length and contains an invalid
+ *		FCS.  This includes integral and non-integral lengths.
+ *rjbr:	Receive jabber count.  Increments for received frames which
+ *		exceed 1518 (non VLAN) or 1522 (VLAN) bytes and contain an
+ *		invalid FCS.  This includes alignment errors.
+ *rdrp:	Receive dropped packets count.  Increments for received frames
+ *		which are streamed to system but are later dropped due to lack
+ *		of system resources.  Does not increment for frames rejected due
+ *		to address filtering.
+ *raln:	Receive alignment error count.  Increments for each received
+ *		frame from 64 to 1518 (non VLAN) or 1522 (VLAN) which contains
+ *		an invalid FCS and is not an integral number of bytes.
+ *rund:	Receive undersize packet count.  Increments each time a frame is
+ *		received which is less than 64 bytes in length and contains a
+ *		valid FCS and is otherwise well formed.  This count does not
+ *		include range length errors.
+ *rovr:	Receive oversize packet count.  Increments each time a frame is
+ *		received which exceeded 1518 (non VLAN) or 1522 (VLAN) and
+ *		contains a valid FCS and is otherwise well formed.
+ *rbyt:	Receive byte count.  Increments by the byte count of frames
+ *		received, including those in bad packets, excluding preamble and
+ *		SFD but including FCS bytes.
+ *rpkt:	Receive packet count.  Increments for each received frame
+ *		(including bad packets, all unicast, broadcast, and multicast
+ *		packets).
+ *rmca:	Receive multicast packet count.  Increments for each multicast
+ *		frame with valid CRC and of lengths 64 to 1518 (non VLAN) or
+ *		1522 (VLAN), excluding broadcast frames. This count does not
+ *		include range/length errors.
+ *rbca:	Receive broadcast packet count.  Increments for each broadcast
+ *		frame with valid CRC and of lengths 64 to 1518 (non VLAN) or
+ *		1522 (VLAN), excluding multicast frames. Does not include
+ *		range/length errors.
+ *tdrp:	Transmit drop frame count.  Increments each time a memory error
+ *		or an underrun has occurred.
+ *tncl:	Transmit total collision counter. Increments by the number of
+ *		collisions experienced during the transmission of a frame. Does
+ *		not increment for aborted frames.
+ *
+ *The structure contains a group of dTSEC HW specific counters relating to the
+ *standard RMON MIB Group 1 (or Ethernet statistics) counters.  This structure
+ *is counting only the carry events of the corresponding HW counters.
+ *
+ *tr64 to trmax notes: Frame sizes specified are considered excluding preamble
+ *and SFD but including FCS bytes.
+ */
+struct dtsec_mib_grp_1_counters {
+	uint64_t rdrp;
+	uint64_t tdrp;
+	uint64_t rbyt;
+	uint64_t rpkt;
+	uint64_t rbca;
+	uint64_t rmca;
+	uint64_t raln;
+	uint64_t rund;
+	uint64_t rovr;
+	uint64_t rfrg;
+	uint64_t rjbr;
+	uint64_t tncl;
+	uint64_t tr64;
+	uint64_t tr127;
+	uint64_t tr255;
+	uint64_t tr511;
+	uint64_t tr1k;
+	uint64_t trmax;
+};
+
+enum dtsec_stat_counters {
+	E_DTSEC_STAT_TR64,
+	E_DTSEC_STAT_TR127,
+	E_DTSEC_STAT_TR255,
+	E_DTSEC_STAT_TR511,
+	E_DTSEC_STAT_TR1K,
+	E_DTSEC_STAT_TRMAX,
+	E_DTSEC_STAT_TRMGV,
+	E_DTSEC_STAT_RBYT,
+	E_DTSEC_STAT_RPKT,
+	E_DTSEC_STAT_RMCA,
+	E_DTSEC_STAT_RBCA,
+	E_DTSEC_STAT_RXPF,
+	E_DTSEC_STAT_RALN,
+	E_DTSEC_STAT_RFLR,
+	E_DTSEC_STAT_RCDE,
+	E_DTSEC_STAT_RCSE,
+	E_DTSEC_STAT_RUND,
+	E_DTSEC_STAT_ROVR,
+	E_DTSEC_STAT_RFRG,
+	E_DTSEC_STAT_RJBR,
+	E_DTSEC_STAT_RDRP,
+	E_DTSEC_STAT_TFCS,
+	E_DTSEC_STAT_TBYT,
+	E_DTSEC_STAT_TPKT,
+	E_DTSEC_STAT_TMCA,
+	E_DTSEC_STAT_TBCA,
+	E_DTSEC_STAT_TXPF,
+	E_DTSEC_STAT_TNCL,
+	E_DTSEC_STAT_TDRP
+};
+
+enum dtsec_stat_level {
+	/* No statistics */
+	E_MAC_STAT_NONE = 0,
+	/* Only RMON MIB group 1 (ether stats). Optimized for performance */
+	E_MAC_STAT_MIB_GRP1,
+	/* Only error counters are available. Optimized for performance */
+	E_MAC_STAT_PARTIAL,
+	/* All counters available. Not optimized for performance */
+	E_MAC_STAT_FULL
+};
+
+/* struct dtsec_cfg - dTSEC configuration
+ * Transmit half-duplex flow control, under software
+ * control for 10/100-Mbps half-duplex media. If set,
+ * back pressure is applied to media by raising carrier.
+ * halfdup_retransmit:
+ * Number of retransmission attempts following a collision.
+ * If this is exceeded dTSEC aborts transmission due to
+ * excessive collisions. The standard specifies the
+ * attempt limit to be 15.
+ * halfdup_coll_window:
+ * The number of bytes of the frame during which
+ * collisions may occur. The default value of 55
+ * corresponds to the frame byte at the end of the
+ * standard 512-bit slot time window. If collisions are
+ * detected after this byte, the late collision event is
+ * asserted and transmission of current frame is aborted.
+ * rx_drop_bcast:
+ * Discard broadcast frames.  If set, all broadcast frames
+ * will be discarded by dTSEC.
+ * rx_short_frm:
+ * Accept short frames.  If set, dTSEC will accept frames
+ * of length 14..63 bytes.
+ * rx_len_check:
+ * Length check for received frames.  If set, the MAC
+ * checks the frame's length field on receive to ensure it
+ * matches the actual data field length. This only works
+ * for received frames with length field less than 1500.
+ * No check is performed for larger frames.
+ * tx_pad_crc:
+ * Pad and append CRC.  If set, the MAC pads all
+ * transmitted short frames and appends a CRC to every
+ * frame regardless of padding requirement.
+ * tx_crc:
+ * Transmission CRC enable.  If set, the MAC appends a CRC
+ * to all frames.  If frames presented to the MAC have a
+ * valid length and contain a valid CRC, tx_crc should be
+ * reset.
+ * This field is ignored if tx_pad_crc is set.
+ * rx_ctrl_acc:
+ * Control frame accept.  If set, this overrides 802.3
+ * standard control frame behavior, and all Ethernet frames
+ * that have an ethertype of 0x8808 are treated as normal
+ * Ethernet frames and passed up to the packet interface on
+ * a DA match.  Received pause control frames are passed to
+ * the packet interface only if Rx flow control is also
+ * disabled.  See fman_dtsec_handle_rx_pause() function.
+ * tx_pause_time:
+ * Transmit pause time value.  This pause value is used as
+ * part of the pause frame to be sent when a transmit pause
+ * frame is initiated.  If set to 0 this disables
+ * transmission of pause frames.
+ * rx_preamble:
+ * Receive preamble enable.  If set, the MAC recovers the
+ * received Ethernet 7-byte preamble and passes it to the
+ * packet interface at the start of each received frame.
+ * This field should be reset for internal MAC loop-back
+ * mode.
+ * tx_preamble:	User defined preamble enable for transmitted frames.
+ * If set, a user-defined preamble must passed to the MAC
+ * and it is transmitted instead of the standard preamble.
+ * preamble_len:
+ * Length, in bytes, of the preamble field preceding each
+ * Ethernet start-of-frame delimiter byte.  The default
+ * value of 0x7 should be used in order to guarantee
+ * reliable operation with IEEE 802.3 compliant hardware.
+ * rx_prepend:
+ * Packet alignment padding length.  The specified number
+ * of bytes (1-31) of zero padding are inserted before the
+ * start of each received frame.  For Ethernet, where
+ * optional preamble extraction is enabled, the padding
+ * appears before the preamble, otherwise the padding
+ * precedes the layer 2 header.
+ *
+ * This structure contains basic dTSEC configuration and must be passed to
+ * fman_dtsec_init() function.  A default set of configuration values can be
+ * obtained by calling fman_dtsec_defconfig().
+ */
+struct dtsec_cfg {
+	bool halfdup_on;
+	bool halfdup_alt_backoff_en;
+	bool halfdup_excess_defer;
+	bool halfdup_no_backoff;
+	bool halfdup_bp_no_backoff;
+	uint8_t halfdup_alt_backoff_val;
+	uint16_t halfdup_retransmit;
+	uint16_t halfdup_coll_window;
+	bool rx_drop_bcast;
+	bool rx_short_frm;
+	bool rx_len_check;
+	bool tx_pad_crc;
+	bool tx_crc;
+	bool rx_ctrl_acc;
+	unsigned short tx_pause_time;
+	unsigned short tbipa;
+	bool ptp_tsu_en;
+	bool ptp_exception_en;
+	bool rx_preamble;
+	bool tx_preamble;
+	unsigned char preamble_len;
+	unsigned char rx_prepend;
+	bool loopback;
+	bool rx_time_stamp_en;
+	bool tx_time_stamp_en;
+	bool rx_flow;
+	bool tx_flow;
+	bool rx_group_hash_exd;
+	bool rx_promisc;
+	uint8_t tbi_phy_addr;
+	uint16_t tx_pause_time_extd;
+	uint16_t maximum_frame;
+	uint32_t non_back_to_back_ipg1;
+	uint32_t non_back_to_back_ipg2;
+	uint32_t min_ifg_enforcement;
+	uint32_t back_to_back_ipg;
+	bool wake_on_lan;
+};
+
+/*fman_dtsec_defconfig() - Get default dTSEC configuration
+ *cfg:	pointer to configuration structure.
+ *
+ *Call this function to obtain a default set of configuration values for
+ *initializing dTSEC.  The user can overwrite any of the values before calling
+ *fman_dtsec_init(), if specific configuration needs to be applied.
+ */
+void fman_dtsec_defconfig(struct dtsec_cfg *cfg);
+
+/*fman_dtsec_init() - Init dTSEC hardware block
+ *regs:		Pointer to dTSEC register block
+ *cfg:		dTSEC configuration data
+ *iface_mode:		dTSEC interface mode, the type of MAC - PHY interface.
+ *iface_speed:	1G or 10G
+ *macaddr:		MAC station address to be assigned to the device
+ *fm_rev_maj:		major rev number
+ *fm_rev_min:		minor rev number
+ *exceptions_mask:	initial exceptions mask
+ *This function initializes dTSEC and applies basic configuration.
+ *
+ *dTSEC initialization sequence:
+ *Before enabling Rx/Tx call dtsec_set_address() to set MAC address,
+ *fman_dtsec_adjust_link() to configure interface speed and duplex and finally
+ *dtsec_enable_tx()/dtsec_enable_rx() to start transmission and reception.
+ *
+ *Returns: 0 if successful, an error code otherwise.
+ */
+int fman_dtsec_init(struct dtsec_regs __iomem *regs, struct dtsec_cfg *cfg,
+		    enum enet_interface iface_mode,
+		    enum enet_speed iface_speed,
+		    uint8_t *macaddr, uint8_t fm_rev_maj,
+		    uint8_t fm_rev_min, uint32_t exception_mask);
+
+/*fman_dtsec_enable() - Enable dTSEC Tx and Tx
+ *regs:	Pointer to dTSEC register block
+ *apply_rx:	enable rx side
+ *apply_tx:	enable tx side
+ *This function resets Tx and Rx graceful stop bit and enables dTSEC Tx and Rx.
+ */
+void fman_dtsec_enable(struct dtsec_regs __iomem *regs, bool apply_rx,
+		       bool apply_tx);
+
+/*fman_dtsec_disable() - Disable dTSEC Tx and Rx
+ *regs:	Pointer to dTSEC register block
+ *apply_rx:	disable rx side
+ *apply_tx:	disable tx side
+ *This function disables Tx and Rx in dTSEC.
+ */
+void fman_dtsec_disable(struct dtsec_regs __iomem *regs, bool apply_rx,
+			bool apply_tx);
+
+/*fman_dtsec_get_revision() - Get dTSEC hardware revision
+ *regs:   Pointer to dTSEC register block
+ *Returns dtsec_id content
+ *Call this function to obtain the dTSEC hardware version.
+ */
+uint32_t fman_dtsec_get_revision(struct dtsec_regs __iomem *regs);
+
+/*fman_dtsec_set_mac_address() - Set MAC station address
+ *regs:   Pointer to dTSEC register block
+ *macaddr:    MAC address array
+ *This function sets MAC station address.  To enable unicast reception call
+ *this after fman_dtsec_init().  While promiscuous mode is disabled dTSEC will
+ *match the destination address of received unicast frames against this
+ *address.
+ */
+void fman_dtsec_set_mac_address(struct dtsec_regs __iomem *regs,
+				uint8_t *macaddr);
+
+/*fman_dtsec_get_mac_address() - Query MAC station address
+ *regs:   Pointer to dTSEC register block
+ *macaddr:    MAC address array
+ */
+void fman_dtsec_get_mac_address(struct dtsec_regs __iomem *regs,
+				uint8_t *macaddr);
+
+/*fman_dtsec_set_uc_promisc() - Sets unicast promiscuous mode
+ *regs:	Pointer to dTSEC register block
+ *enable:	Enable unicast promiscuous mode
+ *Use this function to enable/disable dTSEC L2 address filtering.  If the
+ *address filtering is disabled all unicast packets are accepted.
+ *To set dTSEC in promiscuous mode call both fman_dtsec_set_uc_promisc() and
+ *fman_dtsec_set_mc_promisc() to disable filtering for both unicast and
+ *multicast addresses.
+ */
+void fman_dtsec_set_uc_promisc(struct dtsec_regs __iomem *regs, bool enable);
+
+/* fman_dtsec_set_wol() - Enable/Disable wake on lan
+ * regs:   Pointer to dTSEC register block
+ * en:     Enable Wake On Lan support in dTSEC
+ */
+void fman_dtsec_set_wol(struct dtsec_regs __iomem *regs, bool en);
+
+/*fman_dtsec_adjust_link() - Adjust dTSEC speed/duplex settings
+ *regs:	Pointer to dTSEC register block
+ *iface_mode: dTSEC interface mode
+ *speed:	Link speed
+ *full_dx:	True for full-duplex, false for half-duplex.
+ *This function configures the MAC to function and the desired rates.  Use it
+ *to configure dTSEC after fman_dtsec_init() and whenever the link speed
+ *changes (for instance following PHY auto-negociation).
+ *Returns: 0 if successful, an error code otherwise.
+ */
+int fman_dtsec_adjust_link(struct dtsec_regs __iomem *regs,
+			   enum enet_interface iface_mode,
+			   enum enet_speed speed, bool full_dx);
+
+/*fman_dtsec_set_tbi_phy_addr() - Updates TBI address field
+ *regs:	Pointer to dTSEC register block
+ *address:	Valid PHY address in the range of 1 to 31. 0 is reserved.
+ *In SGMII mode, the dTSEC's TBIPA field must contain a valid TBI PHY address
+ *so that the associated TBI PHY (i.e. the link) may be initialized.
+ *Returns: 0 if successful, an error code otherwise.
+ */
+int fman_dtsec_set_tbi_phy_addr(struct dtsec_regs __iomem *regs, uint8_t addr);
+
+/*fman_dtsec_set_max_frame_len() - Set max frame length
+ *regs:	Pointer to dTSEC register block
+ *length:	Max frame length.
+ *Sets maximum frame length for received and transmitted frames.  Frames that
+ *exceeds this length are truncated.
+ */
+void fman_dtsec_set_max_frame_len(struct dtsec_regs __iomem *regs,
+				  uint16_t length);
+
+/*fman_dtsec_get_max_frame_len() - Query max frame length
+ *regs:	Pointer to dTSEC register block
+ *Returns: the current value of the maximum frame length.
+ */
+uint16_t fman_dtsec_get_max_frame_len(struct dtsec_regs __iomem *regs);
+
+/*fman_dtsec_handle_rx_pause() - Configure pause frame handling
+ *regs:	Pointer to dTSEC register block
+ *en:		Enable pause frame handling in dTSEC
+ *If enabled, dTSEC will handle pause frames internally.  This must be disabled
+ *if dTSEC is set in half-duplex mode.
+ *If pause frame handling is disabled and &dtsec_cfg.rx_ctrl_acc is set, pause
+ *frames will be transferred to the packet interface just like regular Ethernet
+ *frames.
+ */
+void fman_dtsec_handle_rx_pause(struct dtsec_regs __iomem *regs, bool en);
+
+/*fman_dtsec_set_tx_pause_frames() - Configure Tx pause time
+ *regs:	Pointer to dTSEC register block
+ *time:	Time value included in pause frames
+ *Call this function to set the time value used in transmitted pause frames.
+ *If time is 0, transmission of pause frames is disabled
+ */
+void fman_dtsec_set_tx_pause_frames(struct dtsec_regs __iomem *regs,
+				    uint16_t time);
+
+/*fman_dtsec_ack_event() - Acknowledge handled events
+ *regs:	Pointer to dTSEC register block
+ *ev_mask:	Events to acknowledge
+ *After handling events signaled by dTSEC in either polling or interrupt mode,
+ *call this function to reset the associated status bits in dTSEC event
+ *register.
+ */
+void fman_dtsec_ack_event(struct dtsec_regs __iomem *regs, uint32_t ev_mask);
+
+/*fman_dtsec_get_event() - Returns currently asserted events
+ *regs:	Pointer to dTSEC register block
+ *ev_mask:	Mask of relevant events
+ *Call this function to obtain a bit-mask of events that are currently asserted
+ *in dTSEC, taken from IEVENT register.
+ *Returns: a bit-mask of events asserted in dTSEC.
+ */
+uint32_t fman_dtsec_get_event(struct dtsec_regs __iomem *regs,
+			      uint32_t ev_mask);
+
+/*fman_dtsec_get_interrupt_mask() - Returns a bit-mask of enabled interrupts
+ *regs:   Pointer to dTSEC register block
+ *Call this function to obtain a bit-mask of enabled interrupts
+ *in dTSEC, taken from IMASK register.
+ *Returns: a bit-mask of enabled interrupts in dTSEC.
+ */
+uint32_t fman_dtsec_get_interrupt_mask(struct dtsec_regs __iomem *regs);
+
+void fman_dtsec_clear_addr_in_paddr(struct dtsec_regs __iomem *regs,
+				    uint8_t paddr_num);
+
+void fman_dtsec_add_addr_in_paddr(struct dtsec_regs __iomem *regs,
+				  uint64_t addr, uint8_t paddr_num);
+
+void fman_dtsec_enable_tmr_interrupt(struct dtsec_regs __iomem *regs);
+
+void fman_dtsec_disable_tmr_interrupt(struct dtsec_regs __iomem *regs);
+
+/*fman_dtsec_disable_interrupt() - Disables interrupts for the specified events
+ *regs:	Pointer to dTSEC register block
+ *ev_mask:	Mask of relevant events
+ *Call this function to disable interrupts in dTSEC for the specified events.
+ *To enable interrupts use fman_dtsec_enable_interrupt().
+ */
+void fman_dtsec_disable_interrupt(struct dtsec_regs __iomem *regs,
+				  uint32_t ev_mask);
+
+/*fman_dtsec_enable_interrupt() - Enable interrupts for the specified events
+ *regs:	Pointer to dTSEC register block
+ *ev_mask:	Mask of relevant events
+ *Call this function to enable interrupts in dTSEC for the specified events.
+ *To disable interrupts use fman_dtsec_disable_interrupt().
+ */
+void fman_dtsec_enable_interrupt(struct dtsec_regs __iomem *regs,
+				 uint32_t ev_mask);
+
+/*fman_dtsec_set_ts() - Enables dTSEC timestamps
+ *regs:	Pointer to dTSEC register block
+ *en:		true to enable timestamps, false to disable them
+ *Call this function to enable/disable dTSEC timestamps.  This affects both
+ *Tx and Rx.
+ */
+void fman_dtsec_set_ts(struct dtsec_regs __iomem *regs, bool en);
+
+/*fman_dtsec_set_bucket() - Enables/disables a filter bucket
+ *regs:   Pointer to dTSEC register block
+ *bucket: Bucket index
+ *enable: true/false to enable/disable this bucket
+ *This function enables or disables the specified bucket.  Enabling a bucket
+ *associated with an address configures dTSEC to accept received packets
+ *with that destination address.
+ *Multiple addresses may be associated with the same bucket.  Disabling a
+ *bucket will affect all addresses associated with that bucket. A bucket that
+ *is enabled requires further filtering and verification in the upper layers
+ */
+void fman_dtsec_set_bucket(struct dtsec_regs __iomem *regs, int bucket,
+			   bool enable);
+
+/*dtsec_set_hash_table() - insert a crc code into thr filter table
+ *regs:	Pointer to dTSEC register block
+ *crc:	crc to insert
+ *mcast:	true is this is a multicast address
+ *ghtx:	true if we are in ghtx mode
+ *This function inserts a crc code into the filter table.
+ */
+void fman_dtsec_set_hash_table(struct dtsec_regs __iomem *regs, uint32_t crc,
+			       bool mcast, bool ghtx);
+
+/*fman_dtsec_reset_filter_table() - Resets the address filtering table
+ *regs:	Pointer to dTSEC register block
+ *mcast:	Reset multicast entries
+ *ucast:	Reset unicast entries
+ *Resets all entries in L2 address filter table.  After calling this function
+ *all buckets enabled using fman_dtsec_set_bucket() will be disabled.
+ *If dtsec_init_filter_table() was called with unicast_hash set to false,
+ *ucast argument is ignored.
+ *This does not affect the primary nor the 15 additional addresses configured
+ *using dtsec_set_address() or dtsec_set_match_address().
+ */
+void fman_dtsec_reset_filter_table(struct dtsec_regs __iomem *regs, bool mcast,
+				   bool ucast);
+
+/*fman_dtsec_set_mc_promisc() - Set multicast promiscuous mode
+ *regs:	Pointer to dTSEC register block
+ *enable:	Enable multicast promiscuous mode
+ *Call this to enable/disable L2 address filtering for multicast packets.
+ */
+void fman_dtsec_set_mc_promisc(struct dtsec_regs __iomem *regs, bool enable);
+
+/* statistics APIs */
+
+/*fman_dtsec_set_stat_level() - Enable a group of MIB statistics counters
+ *regs:	Pointer to dTSEC register block
+ *level:	Specifies a certain group of dTSEC MIB HW counters or _all_,
+ * to specify all the existing counters.
+ * If set to _none_, it disables all the counters.
+ *Enables the MIB statistics hw counters and sets up the carry interrupt
+ *masks for the counters corresponding to the level input parameter.
+ *Returns: error if invalid level value given.
+ */
+int fman_dtsec_set_stat_level(struct dtsec_regs __iomem *regs,
+			      enum dtsec_stat_level level);
+
+/*fman_dtsec_reset_stat() - Completely resets all dTSEC HW counters
+ *regs:	Pointer to dTSEC register block
+ */
+void fman_dtsec_reset_stat(struct dtsec_regs __iomem *regs);
+
+/*fman_dtsec_get_clear_carry_regs() - Read and clear carry bits
+ * (CAR1-2 registers)
+ *regs:	Pointer to dTSEC register block
+ *car1:	car1 register value
+ *car2:	car2 register value
+ *When set, the carry bits signal that an overflow occurred on the
+ *corresponding counters.
+ *Note that the carry bits (CAR1-2 registers) will assert the
+ *%DTSEC_IEVENT_MSRO interrupt if unmasked (via CAM1-2 regs).
+ *Returns: true if overflow occurred, otherwise - false
+ */
+bool fman_dtsec_get_clear_carry_regs(struct dtsec_regs __iomem *regs,
+				     uint32_t *car1, uint32_t *car2);
+
+uint32_t fman_dtsec_check_and_clear_tmr_event(struct dtsec_regs __iomem *regs);
+
+uint32_t fman_dtsec_get_stat_counter(struct dtsec_regs __iomem *regs,
+				     enum dtsec_stat_counters reg_name);
+
+void fman_dtsec_start_tx(struct dtsec_regs __iomem *regs);
+void fman_dtsec_start_rx(struct dtsec_regs __iomem *regs);
+void fman_dtsec_stop_tx(struct dtsec_regs __iomem *regs);
+void fman_dtsec_stop_rx(struct dtsec_regs __iomem *regs);
+uint32_t fman_dtsec_get_rctrl(struct dtsec_regs __iomem *regs);
+
+#endif /* __FSL_FMAN_DTSEC_H */
diff --git a/drivers/soc/fsl/fman/flib/fsl_fman_dtsec_mii_acc.h b/drivers/soc/fsl/fman/flib/fsl_fman_dtsec_mii_acc.h
new file mode 100644
index 0000000..cd8f521
--- /dev/null
+++ b/drivers/soc/fsl/fman/flib/fsl_fman_dtsec_mii_acc.h
@@ -0,0 +1,104 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __FSL_FMAN_DTSEC_MII_ACC_H
+#define __FSL_FMAN_DTSEC_MII_ACC_H
+
+#include "common/general.h"
+
+/* MII Management Configuration Register */
+#define MIIMCFG_RESET_MGMT		0x80000000
+#define MIIMCFG_MGNTCLK_MASK		0x00000007
+#define MIIMCFG_MGNTCLK_SHIFT		0
+
+/* MII  Management Command Register */
+#define MIIMCOM_SCAN_CYCLE		0x00000002
+#define MIIMCOM_READ_CYCLE		0x00000001
+
+/* MII  Management Address Register */
+#define MIIMADD_PHY_ADDR_SHIFT		8
+#define MIIMADD_PHY_ADDR_MASK		0x00001f00
+
+#define MIIMADD_REG_ADDR_SHIFT		0
+#define MIIMADD_REG_ADDR_MASK		0x0000001f
+
+/* MII Management Indicator Register */
+#define MIIMIND_BUSY			0x00000001
+
+/* PHY Control Register */
+#define PHY_CR_PHY_RESET    0x8000
+#define PHY_CR_LOOPBACK     0x4000
+#define PHY_CR_SPEED0       0x2000
+#define PHY_CR_ANE          0x1000
+#define PHY_CR_RESET_AN     0x0200
+#define PHY_CR_FULLDUPLEX   0x0100
+#define PHY_CR_SPEED1       0x0040
+
+#define PHY_TBICON_SRESET   0x8000
+#define PHY_TBICON_SPEED2   0x0020
+#define PHY_TBICON_CLK_SEL  0x0020
+#define PHY_TBIANA_SGMII    0x4001
+#define PHY_TBIANA_1000X    0x01a0
+/* register map */
+
+/* MII Configuration Control Memory Map Registers */
+struct dtsec_mii_reg {
+	uint32_t reserved1[72];
+	uint32_t miimcfg;	/* MII Mgmt:configuration */
+	uint32_t miimcom;	/* MII Mgmt:command       */
+	uint32_t miimadd;	/* MII Mgmt:address       */
+	uint32_t miimcon;	/* MII Mgmt:control 3     */
+	uint32_t miimstat;	/* MII Mgmt:status        */
+	uint32_t miimind;	/* MII Mgmt:indicators    */
+};
+
+/* dTSEC MII API */
+
+/* functions to access the mii registers for phy configuration.
+ * this functionality may not be available for all dtsecs in the system.
+ * consult the reference manual for details
+ **/
+void fman_dtsec_mii_reset(struct dtsec_mii_reg __iomem *regs);
+/* frequency is in MHz.
+ * note that dtsec clock is 1/2 of fman clock
+ **/
+void fman_dtsec_mii_init(struct dtsec_mii_reg __iomem *regs,
+			 uint16_t dtsec_freq);
+int fman_dtsec_mii_write_reg(struct dtsec_mii_reg __iomem *regs,
+			     uint8_t addr,
+			     uint8_t reg, uint16_t data, uint16_t dtsec_freq);
+
+int fman_dtsec_mii_read_reg(struct dtsec_mii_reg __iomem *regs,
+			    uint8_t addr,
+			    uint8_t reg, uint16_t *data, uint16_t dtsec_freq);
+
+#endif /* __FSL_FMAN_DTSEC_MII_ACC_H */
diff --git a/drivers/soc/fsl/fman/flib/fsl_fman_kg.h b/drivers/soc/fsl/fman/flib/fsl_fman_kg.h
new file mode 100644
index 0000000..967ca81
--- /dev/null
+++ b/drivers/soc/fsl/fman/flib/fsl_fman_kg.h
@@ -0,0 +1,506 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __FSL_FMAN_KG_H
+#define __FSL_FMAN_KG_H
+
+#include "common/general.h"
+
+#define FM_KG_NUM_OF_GENERIC_REGS	8 /* Num of generic KeyGen regs */
+#define FMAN_MAX_NUM_OF_HW_PORTS	64
+/* Total num of masks allowed on KG extractions */
+#define FM_KG_EXTRACT_MASKS_NUM		4
+#define FM_KG_NUM_CLS_PLAN_ENTR		8 /* Num of class. plan regs */
+#define FM_KG_CLS_PLAN_GRPS_NUM		32 /* Max num of class. groups */
+
+struct fman_kg_regs {
+	uint32_t fmkg_gcr;
+	uint32_t res004;
+	uint32_t res008;
+	uint32_t fmkg_eer;
+	uint32_t fmkg_eeer;
+	uint32_t res014;
+	uint32_t res018;
+	uint32_t fmkg_seer;
+	uint32_t fmkg_seeer;
+	uint32_t fmkg_gsr;
+	uint32_t fmkg_tpc;
+	uint32_t fmkg_serc;
+	uint32_t res030[4];
+	uint32_t fmkg_fdor;
+	uint32_t fmkg_gdv0r;
+	uint32_t fmkg_gdv1r;
+	uint32_t res04c[6];
+	uint32_t fmkg_feer;
+	uint32_t res068[38];
+	uint32_t fmkg_indirect[63];
+	uint32_t fmkg_ar;
+};
+
+struct fman_kg_scheme_regs {
+	uint32_t kgse_mode; /* MODE */
+	uint32_t kgse_ekfc; /* Extract Known Fields Command */
+	uint32_t kgse_ekdv; /* Extract Known Default Value */
+	uint32_t kgse_bmch; /* Bit Mask Command High */
+	uint32_t kgse_bmcl; /* Bit Mask Command Low */
+	uint32_t kgse_fqb; /* Frame Queue Base */
+	uint32_t kgse_hc; /* Hash Command */
+	uint32_t kgse_ppc; /* Policer Profile Command */
+	uint32_t kgse_gec[FM_KG_NUM_OF_GENERIC_REGS];
+				/* Generic Extract Command */
+	uint32_t kgse_spc; /* KeyGen Scheme Entry Statistic Packet Counter */
+	uint32_t kgse_dv0; /* KeyGen Scheme Entry Default Value 0 */
+	uint32_t kgse_dv1; /* KeyGen Scheme Entry Default Value 1 */
+	uint32_t kgse_ccbs; /* KeyGen Scheme Entry Coarse Classification Bit*/
+	uint32_t kgse_mv; /* KeyGen Scheme Entry Match vector */
+	uint32_t kgse_om; /* KeyGen Scheme Entry Operation Mode bits */
+	uint32_t kgse_vsp; /* KeyGen Scheme Entry Virtual Storage Profile */
+};
+
+struct fman_kg_pe_regs {
+	uint32_t fmkg_pe_sp;
+	uint32_t fmkg_pe_cpp;
+};
+
+struct fman_kg_cp_regs {
+	uint32_t kgcpe[FM_KG_NUM_CLS_PLAN_ENTR];
+};
+
+#define FM_KG_KGAR_GO				0x80000000
+#define FM_KG_KGAR_READ				0x40000000
+#define FM_KG_KGAR_WRITE			0x00000000
+#define FM_KG_KGAR_SEL_SCHEME_ENTRY		0x00000000
+#define FM_KG_KGAR_SCM_WSEL_UPDATE_CNT		0x00008000
+
+#define KG_SCH_PP_SHIFT_HIGH			0x80000000
+#define KG_SCH_PP_NO_GEN			0x10000000
+#define KG_SCH_PP_SHIFT_LOW			0x0000F000
+#define KG_SCH_MODE_NIA_PLCR			0x40000000
+#define KG_SCH_GEN_EXTRACT_TYPE			0x00008000
+#define KG_SCH_BITMASK_MASK			0x000000FF
+#define KG_SCH_GEN_VALID			0x80000000
+#define KG_SCH_GEN_MASK				0x00FF0000
+#define FM_PCD_KG_KGAR_ERR			0x20000000
+#define FM_PCD_KG_KGAR_SEL_CLS_PLAN_ENTRY	0x01000000
+#define FM_PCD_KG_KGAR_SEL_PORT_ENTRY		0x02000000
+#define FM_PCD_KG_KGAR_SEL_PORT_WSEL_SP		0x00008000
+#define FM_PCD_KG_KGAR_SEL_PORT_WSEL_CPP	0x00004000
+#define FM_PCD_KG_KGAR_WSEL_MASK		0x0000FF00
+#define KG_SCH_HASH_CONFIG_NO_FQID		0x80000000
+#define KG_SCH_HASH_CONFIG_SYM			0x40000000
+
+#define FM_EX_KG_DOUBLE_ECC			0x80000000
+#define FM_EX_KG_KEYSIZE_OVERFLOW		0x40000000
+
+/* ECC capture register */
+#define KG_FMKG_SERC_CAP			0x80000000
+#define KG_FMKG_SERC_CET			0x40000000
+#define KG_FMKG_SERC_CNT_MSK			0x00FF0000
+#define KG_FMKG_SERC_CNT_SHIFT			16
+#define KG_FMKG_SERC_ADDR_MSK			0x000003FF
+
+/* Masks */
+#define FM_KG_KGGCR_EN				0x80000000
+#define KG_SCH_GEN_VALID			0x80000000
+#define KG_SCH_GEN_EXTRACT_TYPE			0x00008000
+#define KG_ERR_TYPE_DOUBLE			0x40000000
+#define KG_ERR_ADDR_MASK			0x00000FFF
+#define KG_SCH_MODE_EN				0x80000000
+
+/* shifts */
+#define FM_KG_KGAR_NUM_SHIFT			16
+#define FM_KG_PE_CPP_MASK_SHIFT			16
+#define FM_KG_KGAR_WSEL_SHIFT			8
+
+#define FM_KG_SCH_GEN_HT_INVALID		0
+
+#define FM_KG_MASK_SEL_GEN_BASE			0x20
+
+#define KG_GET_MASK_SEL_SHIFT(shift, i) do {\
+switch (i) {				\
+case 0: \
+	(shift) = 26; \
+		  break;	\
+case 1: \
+	(shift) = 20; break;	\
+case 2: \
+	(shift) = 10; break;	\
+case 3: \
+	(shift) = 4; break;	\
+default: \
+	(shift) = 0;		\
+} \
+} while (0)
+
+#define KG_GET_MASK_OFFSET_SHIFT(shift, i) do {\
+switch (i) {				\
+case 0: \
+	(shift) = 16; break;	\
+case 1: \
+	(shift) = 0; break;	\
+case 2: \
+	(shift) = 28; break;	\
+case 3: \
+	(shift) = 24; break;	\
+default: \
+	(shift) = 0;		\
+} \
+} while (0)
+
+#define KG_GET_MASK_SHIFT(shift, i) do {\
+switch (i) {				\
+case 0: \
+	shift = 24; break;	\
+case 1: \
+	shift = 16; break;	\
+case 2: \
+	shift = 8;  break;	\
+case 3: \
+	shift = 0;  break;	\
+default: \
+	shift = 0;		\
+} \
+} while (0)
+
+/* Port entry CPP register */
+#define FMAN_KG_PE_CPP_MASK_SHIFT	16
+
+/* Scheme registers */
+#define FMAN_KG_SCH_MODE_EN		0x80000000
+#define FMAN_KG_SCH_MODE_NIA_PLCR	0x40000000
+#define FMAN_KG_SCH_MODE_CCOBASE_SHIFT	24
+
+#define FMAN_KG_SCH_DEF_MAC_ADDR_SHIFT	30
+#define FMAN_KG_SCH_DEF_VLAN_TCI_SHIFT	28
+#define FMAN_KG_SCH_DEF_ETYPE_SHIFT	26
+#define FMAN_KG_SCH_DEF_PPP_SID_SHIFT	24
+#define FMAN_KG_SCH_DEF_PPP_PID_SHIFT	22
+#define FMAN_KG_SCH_DEF_MPLS_SHIFT	20
+#define FMAN_KG_SCH_DEF_IP_ADDR_SHIFT	18
+#define FMAN_KG_SCH_DEF_PTYPE_SHIFT	16
+#define FMAN_KG_SCH_DEF_IP_TOS_TC_SHIFT	14
+#define FMAN_KG_SCH_DEF_IPV6_FL_SHIFT	12
+#define FMAN_KG_SCH_DEF_IPSEC_SPI_SHIFT	10
+#define FMAN_KG_SCH_DEF_L4_PORT_SHIFT	8
+#define FMAN_KG_SCH_DEF_TCP_FLG_SHIFT	6
+
+#define FMAN_KG_SCH_GEN_VALID		0x80000000
+#define FMAN_KG_SCH_GEN_SIZE_MAX	16
+#define FMAN_KG_SCH_GEN_OR		0x00008000
+
+#define FMAN_KG_SCH_GEN_DEF_SHIFT	29
+#define FMAN_KG_SCH_GEN_SIZE_SHIFT	24
+#define FMAN_KG_SCH_GEN_MASK_SHIFT	16
+#define FMAN_KG_SCH_GEN_HT_SHIFT	8
+
+#define FMAN_KG_SCH_HASH_HSHIFT_SHIFT	24
+#define FMAN_KG_SCH_HASH_HSHIFT_MAX	0x28
+#define FMAN_KG_SCH_HASH_SYM		0x40000000
+#define FMAN_KG_SCH_HASH_NO_FQID_GEN	0x80000000
+
+#define FMAN_KG_SCH_PP_SH_SHIFT		27
+#define FMAN_KG_SCH_PP_SL_SHIFT		12
+#define FMAN_KG_SCH_PP_SH_MASK		0x80000000
+#define FMAN_KG_SCH_PP_SL_MASK		0x0000F000
+#define FMAN_KG_SCH_PP_SHIFT_MAX	0x17
+#define FMAN_KG_SCH_PP_MASK_SHIFT	16
+#define FMAN_KG_SCH_PP_NO_GEN		0x10000000
+
+enum fman_kg_gen_extract_src {
+	E_FMAN_KG_GEN_EXTRACT_ETH,
+	E_FMAN_KG_GEN_EXTRACT_ETYPE,
+	E_FMAN_KG_GEN_EXTRACT_SNAP,
+	E_FMAN_KG_GEN_EXTRACT_VLAN_TCI_1,
+	E_FMAN_KG_GEN_EXTRACT_VLAN_TCI_N,
+	E_FMAN_KG_GEN_EXTRACT_PPPOE,
+	E_FMAN_KG_GEN_EXTRACT_MPLS_1,
+	E_FMAN_KG_GEN_EXTRACT_MPLS_2,
+	E_FMAN_KG_GEN_EXTRACT_MPLS_3,
+	E_FMAN_KG_GEN_EXTRACT_MPLS_N,
+	E_FMAN_KG_GEN_EXTRACT_IPV4_1,
+	E_FMAN_KG_GEN_EXTRACT_IPV6_1,
+	E_FMAN_KG_GEN_EXTRACT_IPV4_2,
+	E_FMAN_KG_GEN_EXTRACT_IPV6_2,
+	E_FMAN_KG_GEN_EXTRACT_MINENCAP,
+	E_FMAN_KG_GEN_EXTRACT_IP_PID,
+	E_FMAN_KG_GEN_EXTRACT_GRE,
+	E_FMAN_KG_GEN_EXTRACT_TCP,
+	E_FMAN_KG_GEN_EXTRACT_UDP,
+	E_FMAN_KG_GEN_EXTRACT_SCTP,
+	E_FMAN_KG_GEN_EXTRACT_DCCP,
+	E_FMAN_KG_GEN_EXTRACT_IPSEC_AH,
+	E_FMAN_KG_GEN_EXTRACT_IPSEC_ESP,
+	E_FMAN_KG_GEN_EXTRACT_SHIM_1,
+	E_FMAN_KG_GEN_EXTRACT_SHIM_2,
+	E_FMAN_KG_GEN_EXTRACT_FROM_DFLT,
+	E_FMAN_KG_GEN_EXTRACT_FROM_FRAME_START,
+	E_FMAN_KG_GEN_EXTRACT_FROM_PARSE_RESULT,
+	E_FMAN_KG_GEN_EXTRACT_FROM_END_OF_PARSE,
+	E_FMAN_KG_GEN_EXTRACT_FROM_FQID
+};
+
+struct fman_kg_ex_ecc_attr {
+	bool valid;
+	bool double_ecc;
+	uint16_t addr;
+	uint8_t single_ecc_count;
+};
+
+enum fman_kg_def_select {
+	E_FMAN_KG_DEF_GLOBAL_0,
+	E_FMAN_KG_DEF_GLOBAL_1,
+	E_FMAN_KG_DEF_SCHEME_0,
+	E_FMAN_KG_DEF_SCHEME_1
+};
+
+struct fman_kg_extract_def {
+	enum fman_kg_def_select mac_addr;
+	enum fman_kg_def_select vlan_tci;
+	enum fman_kg_def_select etype;
+	enum fman_kg_def_select ppp_sid;
+	enum fman_kg_def_select ppp_pid;
+	enum fman_kg_def_select mpls;
+	enum fman_kg_def_select ip_addr;
+	enum fman_kg_def_select ptype;
+	enum fman_kg_def_select ip_tos_tc;
+	enum fman_kg_def_select ipv6_fl;
+	enum fman_kg_def_select ipsec_spi;
+	enum fman_kg_def_select l4_port;
+	enum fman_kg_def_select tcp_flg;
+};
+
+enum fman_kg_gen_extract_type {
+	E_FMAN_KG_HASH_EXTRACT,
+	E_FMAN_KG_OR_EXTRACT
+};
+
+struct fman_kg_gen_extract_params {
+	/* Hash or Or-ed extract */
+	enum fman_kg_gen_extract_type type;
+	enum fman_kg_gen_extract_src src;
+	bool no_validation;
+	/* Extraction offset from the header location specified above */
+	uint8_t offset;
+	/* Size of extraction for FMAN_KG_HASH_EXTRACT,
+	 * hash result shift for FMAN_KG_OR_EXTRACT
+	 */
+	uint8_t extract;
+	uint8_t mask;
+	/* Default value to use when header specified
+	 * by fman_kg_gen_extract_src doesn't present
+	 */
+	enum fman_kg_def_select def_val;
+};
+
+struct fman_kg_extract_mask {
+	/* Indication if mask is on known field extraction or
+	 * on general extraction; true for known field
+	 */
+	bool is_known;
+	/* One of FMAN_KG_EXTRACT_xxx defines for known fields mask and
+	 * generic register index for generic extracts mask
+	 */
+	uint32_t field_or_gen_idx;
+	/* Byte offset from start of the extracted data specified
+	 * by field_or_gen_idx
+	 */
+	uint8_t offset;
+	/* Byte mask (selected bits will be used) */
+	uint8_t mask;
+};
+
+struct fman_kg_extract_params {
+	/* Or-ed mask of FMAN_KG_EXTRACT_xxx defines */
+	uint32_t known_fields;
+	struct fman_kg_extract_def known_fields_def;
+	/* Number of entries in gen_extract */
+	uint8_t gen_extract_num;
+	struct fman_kg_gen_extract_params
+	    gen_extract[FM_KG_NUM_OF_GENERIC_REGS];
+	/* Number of entries in masks */
+	uint8_t masks_num;
+	struct fman_kg_extract_mask masks[FM_KG_EXTRACT_MASKS_NUM];
+	uint32_t def_scheme_0;
+	uint32_t def_scheme_1;
+};
+
+struct fman_kg_hash_params {
+	bool use_hash;
+	uint8_t shift_r;
+	uint32_t mask;	      /* 24-bit mask */
+	bool sym;	     /* Symmetric hash for src and dest pairs */
+};
+
+struct fman_kg_pp_params {
+	uint8_t base;
+	uint8_t shift;
+	uint8_t mask;
+	bool bypass_pp_gen;
+};
+
+struct fman_kg_cc_params {
+	uint8_t base_offset;
+	uint32_t qlcv_bits_sel;
+};
+
+enum fman_pcd_engine {
+	E_FMAN_PCD_INVALID = 0,	/* Invalid PCD engine indicated*/
+	E_FMAN_PCD_DONE,	/* No PCD Engine indicated */
+	E_FMAN_PCD_KG,		/* Keygen indicated */
+	E_FMAN_PCD_CC,		/* Coarse classification indicated */
+	E_FMAN_PCD_PLCR,	/* Policer indicated */
+	E_FMAN_PCD_PRS		/* Parser indicated */
+};
+
+struct fman_kg_cls_plan_params {
+	uint8_t entries_mask;
+	uint32_t mask_vector[FM_KG_NUM_CLS_PLAN_ENTR];
+};
+
+struct fman_kg_scheme_params {
+	uint32_t match_vector;
+	struct fman_kg_extract_params extract_params;
+	struct fman_kg_hash_params hash_params;
+	uint32_t base_fqid;
+	/* What we do w/features supported per FM version ?? */
+	bool bypass_fqid_gen;
+	struct fman_kg_pp_params policer_params;
+	struct fman_kg_cc_params cc_params;
+	bool update_counter;
+	/* counter_value: Set scheme counter to the specified value;
+	 * relevant only when update_counter = true.
+	 */
+	uint32_t counter_value;
+	enum fman_pcd_engine next_engine;
+	/* Next engine action code */
+	uint32_t next_engine_action;
+};
+
+int fman_kg_write_ar_wait(struct fman_kg_regs __iomem *regs, uint32_t fmkg_ar);
+void fman_kg_write_sp(struct fman_kg_regs __iomem *regs, uint32_t sp, bool add);
+void fman_kg_write_cpp(struct fman_kg_regs __iomem *regs, uint32_t cpp);
+void fman_kg_get_event(struct fman_kg_regs __iomem *regs,
+		       uint32_t *event, uint32_t *scheme_idx);
+void fman_kg_init(struct fman_kg_regs __iomem *regs,
+		  uint32_t exceptions, uint32_t dflt_nia);
+void fman_kg_enable_scheme_interrupts(struct fman_kg_regs __iomem *regs);
+void fman_kg_enable(struct fman_kg_regs __iomem *regs);
+void fman_kg_disable(struct fman_kg_regs __iomem *regs);
+int fman_kg_write_bind_cls_plans(struct fman_kg_regs __iomem *regs,
+				 uint8_t hwport_id, uint32_t bind_cls_plans);
+int fman_kg_build_bind_cls_plans(uint8_t grp_base,
+				 uint8_t grp_mask, uint32_t *bind_cls_plans);
+int fman_kg_write_bind_schemes(struct fman_kg_regs __iomem *regs,
+			       uint8_t hwport_id, uint32_t schemes);
+int fman_kg_write_cls_plan(struct fman_kg_regs __iomem *regs,
+			   uint8_t grp_id,
+			   uint8_t entries_mask,
+			   uint8_t hwport_id,
+			   struct fman_kg_cp_regs __iomem *cls_plan_regs);
+int fman_kg_build_cls_plan(struct fman_kg_cls_plan_params *params,
+			   struct fman_kg_cp_regs *cls_plan_regs);
+uint32_t fman_kg_get_schemes_total_counter(struct fman_kg_regs __iomem *regs);
+int fman_kg_set_scheme_counter(struct fman_kg_regs __iomem *regs,
+			       uint8_t scheme_id,
+			       uint8_t hwport_id, uint32_t counter);
+int fman_kg_get_scheme_counter(struct fman_kg_regs __iomem *regs,
+			       uint8_t scheme_id,
+			       uint8_t hwport_id, uint32_t *counter);
+int fman_kg_delete_scheme(struct fman_kg_regs __iomem *regs,
+			  uint8_t scheme_id, uint8_t hwport_id);
+int fman_kg_write_scheme(struct fman_kg_regs __iomem *regs,
+			 uint8_t scheme_id,
+			 uint8_t hwport_id,
+			 struct fman_kg_scheme_regs *scheme_regs,
+			 bool update_counter);
+int fman_kg_build_scheme(struct fman_kg_scheme_params *params,
+			 struct fman_kg_scheme_regs *scheme_regs);
+void fman_kg_get_capture(struct fman_kg_regs __iomem *regs,
+			 struct fman_kg_ex_ecc_attr *ecc_attr, bool clear);
+void fman_kg_get_exception(struct fman_kg_regs __iomem *regs,
+			   uint32_t *events,
+			   uint32_t *scheme_ids, bool clear);
+void fman_kg_set_exception(struct fman_kg_regs __iomem *regs,
+			   uint32_t exception, bool enable);
+void fman_kg_set_dflt_val(struct fman_kg_regs __iomem *regs,
+			  uint8_t def_id, uint32_t val);
+void fman_kg_set_data_after_prs(struct fman_kg_regs __iomem *regs,
+				uint8_t offset);
+
+/* NIA Description */
+#define KG_NIA_ORDER_RESTOR	0x00800000
+#define KG_NIA_ENG_FM_CTL	0x00000000
+#define KG_NIA_ENG_PRS		0x00440000
+#define KG_NIA_ENG_KG		0x00480000
+#define KG_NIA_ENG_PLCR		0x004C0000
+#define KG_NIA_ENG_BMI		0x00500000
+#define KG_NIA_ENG_QMI_ENQ	0x00540000
+#define KG_NIA_ENG_QMI_DEQ	0x00580000
+#define KG_NIA_ENG_MASK		0x007C0000
+
+#define KG_NIA_AC_MASK		0x0003FFFF
+
+#define KG_NIA_INVALID		0xFFFFFFFF
+
+static inline uint32_t fm_kg_build_nia(enum fman_pcd_engine next_engine,
+				       uint32_t next_engine_action)
+{
+	uint32_t nia;
+
+	if (next_engine_action & ~KG_NIA_AC_MASK)
+		return KG_NIA_INVALID;
+
+	switch (next_engine) {
+	case E_FMAN_PCD_DONE:
+		nia = KG_NIA_ENG_BMI | next_engine_action;
+		break;
+
+	case E_FMAN_PCD_KG:
+		nia = KG_NIA_ENG_KG | next_engine_action;
+		break;
+
+	case E_FMAN_PCD_CC:
+		nia = KG_NIA_ENG_FM_CTL | next_engine_action;
+		break;
+
+	case E_FMAN_PCD_PLCR:
+		nia = KG_NIA_ENG_PLCR | next_engine_action;
+		break;
+
+	default:
+		nia = KG_NIA_INVALID;
+	}
+
+	return nia;
+}
+
+#endif /* __FSL_FMAN_KG_H */
diff --git a/drivers/soc/fsl/fman/flib/fsl_fman_memac.h b/drivers/soc/fsl/fman/flib/fsl_fman_memac.h
new file mode 100644
index 0000000..bb64103
--- /dev/null
+++ b/drivers/soc/fsl/fman/flib/fsl_fman_memac.h
@@ -0,0 +1,492 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __FSL_FMAN_MEMAC_H
+#define __FSL_FMAN_MEMAC_H
+
+#include "common/general.h"
+#include "fsl_enet.h"
+/* Num of additional exact match MAC adr regs */
+#define MEMAC_NUM_OF_PADDRS 7
+
+/* Control and Configuration Register (COMMAND_CONFIG) */
+/* 00 Magic Packet detection */
+#define CMD_CFG_MG		0x80000000
+/* 07 Rx low power indication */
+#define CMD_CFG_REG_LOWP_RXETY	0x01000000
+/* 08 Tx Low Power Idle Enable */
+#define CMD_CFG_TX_LOWP_ENA	0x00800000
+/* 10 Disable SFD check */
+#define CMD_CFG_SFD_ANY		0x00200000
+/* 12 Enable PFC */
+#define CMD_CFG_PFC_MODE	0x00080000
+/* 14 Payload length check disable */
+#define CMD_CFG_NO_LEN_CHK	0x00020000
+/* 15 Force idle generation */
+#define CMD_CFG_SEND_IDLE	0x00010000
+/* 18 Control frame rx enable */
+#define CMD_CFG_CNT_FRM_EN	0x00002000
+/* 19 S/W Reset, self clearing bit */
+#define CMD_CFG_SW_RESET	0x00001000
+/* 20 Enable Tx padding of frames */
+#define CMD_CFG_TX_PAD_EN	0x00000800
+/* 21 XGMII/GMII loopback enable */
+#define CMD_CFG_LOOPBACK_EN	0x00000400
+/* 22 Tx source MAC addr insertion */
+#define CMD_CFG_TX_ADDR_INS	0x00000200
+/* 23 Ignore Pause frame quanta */
+#define CMD_CFG_PAUSE_IGNORE	0x00000100
+/* 24 Terminate/frwd Pause frames */
+#define CMD_CFG_PAUSE_FWD	0x00000080
+/* 25 Terminate/frwd CRC of frames */
+#define CMD_CFG_CRC_FWD		0x00000040
+/* 26 Frame padding removal */
+#define CMD_CFG_PAD_EN		0x00000020
+/* 27 Promiscuous operation enable */
+#define CMD_CFG_PROMIS_EN	0x00000010
+/* 28 WAN mode enable */
+#define CMD_CFG_WAN_MODE	0x00000008
+/* 30 MAC receive path enable */
+#define CMD_CFG_RX_EN		0x00000002
+/* 31 MAC transmit path enable */
+#define CMD_CFG_TX_EN		0x00000001
+
+/* Transmit FIFO Sections Register (TX_FIFO_SECTIONS) */
+#define TX_FIFO_SECTIONS_TX_EMPTY_MASK			0xFFFF0000
+#define TX_FIFO_SECTIONS_TX_AVAIL_MASK			0x0000FFFF
+#define TX_FIFO_SECTIONS_TX_EMPTY_DEFAULT_10G		0x00400000
+#define TX_FIFO_SECTIONS_TX_EMPTY_DEFAULT_1G		0x00100000
+#define TX_FIFO_SECTIONS_TX_EMPTY_PFC_10G		0x00360000
+#define TX_FIFO_SECTIONS_TX_EMPTY_PFC_1G		0x00040000
+#define TX_FIFO_SECTIONS_TX_AVAIL_10G			0x00000019
+#define TX_FIFO_SECTIONS_TX_AVAIL_1G			0x00000020
+
+#define GET_TX_EMPTY_DEFAULT_VALUE(_val)				\
+do {									\
+	_val &= ~TX_FIFO_SECTIONS_TX_EMPTY_MASK;			\
+	((_val == TX_FIFO_SECTIONS_TX_AVAIL_10G) ?			\
+			(_val |= TX_FIFO_SECTIONS_TX_EMPTY_DEFAULT_10G) :\
+			(_val |= TX_FIFO_SECTIONS_TX_EMPTY_DEFAULT_1G));\
+} while (0)
+
+#define GET_TX_EMPTY_PFC_VALUE(_val)					\
+do {									\
+	_val &= ~TX_FIFO_SECTIONS_TX_EMPTY_MASK;			\
+	((_val == TX_FIFO_SECTIONS_TX_AVAIL_10G) ?			\
+			(_val |= TX_FIFO_SECTIONS_TX_EMPTY_PFC_10G) :	\
+			(_val |= TX_FIFO_SECTIONS_TX_EMPTY_PFC_1G));	\
+} while (0)
+
+/* Interface Mode Register (IF_MODE) */
+/* 30-31 Mask on i/f mode bits */
+#define IF_MODE_MASK		0x00000003
+/* 30-31 XGMII (10G) interface */
+#define IF_MODE_XGMII		0x00000000
+/* 30-31 GMII (1G) interface */
+#define IF_MODE_GMII		0x00000002
+#define IF_MODE_RGMII		0x00000004
+#define IF_MODE_RGMII_AUTO	0x00008000
+#define IF_MODE_RGMII_1000  0x00004000	/* 10 - 1000Mbps RGMII */
+#define IF_MODE_RGMII_100   0x00000000	/* 00 - 100Mbps RGMII */
+#define IF_MODE_RGMII_10    0x00002000	/* 01 - 10Mbps RGMII */
+#define IF_MODE_RGMII_SP_MASK 0x00006000	/* Setsp mask bits */
+#define IF_MODE_RGMII_FD    0x00001000	/* Full duplex RGMII */
+#define IF_MODE_HD          0x00000040	/* Half duplex operation */
+
+/* Hash table Control Register (HASHTABLE_CTRL) */
+#define HASH_CTRL_MCAST_SHIFT	26
+/* 23 Mcast frame rx for hash */
+#define HASH_CTRL_MCAST_EN	0x00000100
+/* 26-31 Hash table address code */
+#define HASH_CTRL_ADDR_MASK	0x0000003F
+/* MAC mcast indication */
+#define GROUP_ADDRESS		0x0000010000000000LL
+#define HASH_TABLE_SIZE		64	/* Hash tbl size */
+
+/* Transmit Inter-Packet Gap Length Register (TX_IPG_LENGTH) */
+#define MEMAC_TX_IPG_LENGTH_MASK	0x0000003F
+
+/* Statistics Configuration Register (STATN_CONFIG) */
+#define STATS_CFG_CLR		0x00000004	/* 29 Reset all counters */
+#define STATS_CFG_CLR_ON_RD	0x00000002	/* 30 Clear on read */
+/* 31 Saturate at the maximum val */
+#define STATS_CFG_SATURATE	0x00000001
+
+/* Interrupt Mask Register (IMASK) */
+/* 1 Magic pkt detect indication */
+#define MEMAC_IMASK_MGI		0x40000000
+/* 2 Timestamp FIFO ECC error evnt */
+#define MEMAC_IMASK_TSECC_ER 0x20000000
+/* 6 Transmit frame ECC error evnt */
+#define MEMAC_IMASK_TECC_ER	0x02000000
+/* 7 Receive frame ECC error evnt */
+#define MEMAC_IMASK_RECC_ER	0x01000000
+
+#define MEMAC_ALL_ERRS_IMASK					\
+		((uint32_t)(MEMAC_IMASK_TSECC_ER	|	\
+			MEMAC_IMASK_TECC_ER		|	\
+			MEMAC_IMASK_RECC_ER		|	\
+			MEMAC_IMASK_MGI))
+
+/* PCS (XG). Link sync (G) */
+#define MEMAC_IEVNT_PCS			0x80000000
+/* Auto-negotiation */
+#define MEMAC_IEVNT_AN			0x40000000
+/* Link Training/New page */
+#define MEMAC_IEVNT_LT			0x20000000
+/* Magic pkt detection */
+#define MEMAC_IEVNT_MGI			0x00004000
+/* Timestamp FIFO ECC error */
+#define MEMAC_IEVNT_TS_ECC_ER		0x00002000
+/* Rx FIFO overflow */
+#define MEMAC_IEVNT_RX_FIFO_OVFL	0x00001000
+/* Tx FIFO underflow */
+#define MEMAC_IEVNT_TX_FIFO_UNFL	0x00000800
+/* Tx FIFO overflow */
+#define MEMAC_IEVNT_TX_FIFO_OVFL	0x00000400
+/* Tx frame ECC error */
+#define MEMAC_IEVNT_TX_ECC_ER		0x00000200
+/* Rx frame ECC error */
+#define MEMAC_IEVNT_RX_ECC_ER		0x00000100
+/* Link Interruption flt */
+#define MEMAC_IEVNT_LI_FAULT		0x00000080
+/* Rx FIFO empty */
+#define MEMAC_IEVNT_RX_EMPTY		0x00000040
+/* Tx FIFO empty */
+#define MEMAC_IEVNT_TX_EMPTY		0x00000020
+/* Low Power Idle */
+#define MEMAC_IEVNT_RX_LOWP		0x00000010
+/* Phy loss of signal */
+#define MEMAC_IEVNT_PHY_LOS		0x00000004
+/* Remote fault (XGMII) */
+#define MEMAC_IEVNT_REM_FAULT		0x00000002
+/* Local fault (XGMII) */
+#define MEMAC_IEVNT_LOC_FAULT		0x00000001
+
+enum memac_counters {
+	E_MEMAC_COUNTER_R64,
+	E_MEMAC_COUNTER_R127,
+	E_MEMAC_COUNTER_R255,
+	E_MEMAC_COUNTER_R511,
+	E_MEMAC_COUNTER_R1023,
+	E_MEMAC_COUNTER_R1518,
+	E_MEMAC_COUNTER_R1519X,
+	E_MEMAC_COUNTER_RFRG,
+	E_MEMAC_COUNTER_RJBR,
+	E_MEMAC_COUNTER_RDRP,
+	E_MEMAC_COUNTER_RALN,
+	E_MEMAC_COUNTER_TUND,
+	E_MEMAC_COUNTER_ROVR,
+	E_MEMAC_COUNTER_RXPF,
+	E_MEMAC_COUNTER_TXPF,
+	E_MEMAC_COUNTER_ROCT,
+	E_MEMAC_COUNTER_RMCA,
+	E_MEMAC_COUNTER_RBCA,
+	E_MEMAC_COUNTER_RPKT,
+	E_MEMAC_COUNTER_RUCA,
+	E_MEMAC_COUNTER_RERR,
+	E_MEMAC_COUNTER_TOCT,
+	E_MEMAC_COUNTER_TMCA,
+	E_MEMAC_COUNTER_TBCA,
+	E_MEMAC_COUNTER_TUCA,
+	E_MEMAC_COUNTER_TERR
+};
+
+#define DEFAULT_PAUSE_QUANTA	0xf000
+#define DEFAULT_FRAME_LENGTH	0x600
+#define DEFAULT_TX_IPG_LENGTH	12
+
+/**
+ * memory map
+ **/
+
+struct mac_addr {
+	/* Lower 32 bits of 48-bit MAC address */
+	uint32_t mac_addr_l;
+	/* Upper 16 bits of 48-bit MAC address */
+	uint32_t mac_addr_u;
+};
+
+struct memac_regs {
+	/* General Control and Status */
+	uint32_t res0000[2];
+	/* 0x008 Ctrl and cfg */
+	uint32_t command_config;
+	/* 0x00C-0x010 MAC_ADDR_0...1 */
+	struct mac_addr mac_addr0;
+	/* 0x014 Max frame length */
+	uint32_t maxfrm;
+	uint32_t res0018[1];
+	/* Receive FIFO configuration reg */
+	uint32_t rx_fifo_sections;
+	/* Transmit FIFO configuration reg */
+	uint32_t tx_fifo_sections;
+	uint32_t res0024[2];
+	/* 0x02C Hash table control */
+	uint32_t hashtable_ctrl;
+	uint32_t res0030[4];
+	/* 0x040 Interrupt event */
+	uint32_t ievent;
+	/* 0x044 Transmitter inter-packet-gap */
+	uint32_t tx_ipg_length;
+	uint32_t res0048;
+	/* 0x04C Interrupt mask */
+	uint32_t imask;
+	uint32_t res0050;
+	/* 0x054 Pause quanta */
+	uint32_t pause_quanta[4];
+	/* 0x064 Pause quanta threshold */
+	uint32_t pause_thresh[4];
+	/* 0x074 Receive pause status */
+	uint32_t rx_pause_status;
+	uint32_t res0078[2];
+	/* 0x80-0x0B4 mac padr */
+	struct mac_addr mac_addr[MEMAC_NUM_OF_PADDRS];
+	/* 0x0B8 Low Power Wakeup Timer */
+	uint32_t lpwake_timer;
+	/* 0x0BC Transmit EEE Low Power Timer */
+	uint32_t sleep_timer;
+	uint32_t res00c0[8];
+	/* 0x0E0 Statistics configuration */
+	uint32_t statn_config;
+	uint32_t res00e4[7];
+	/* Rx Statistics Counter */
+	uint32_t reoct_l;
+	uint32_t reoct_u;
+	uint32_t roct_l;
+	uint32_t roct_u;
+	uint32_t raln_l;
+	uint32_t raln_u;
+	uint32_t rxpf_l;
+	uint32_t rxpf_u;
+	uint32_t rfrm_l;
+	uint32_t rfrm_u;
+	uint32_t rfcs_l;
+	uint32_t rfcs_u;
+	uint32_t rvlan_l;
+	uint32_t rvlan_u;
+	uint32_t rerr_l;
+	uint32_t rerr_u;
+	uint32_t ruca_l;
+	uint32_t ruca_u;
+	uint32_t rmca_l;
+	uint32_t rmca_u;
+	uint32_t rbca_l;
+	uint32_t rbca_u;
+	uint32_t rdrp_l;
+	uint32_t rdrp_u;
+	uint32_t rpkt_l;
+	uint32_t rpkt_u;
+	uint32_t rund_l;
+	uint32_t rund_u;
+	uint32_t r64_l;
+	uint32_t r64_u;
+	uint32_t r127_l;
+	uint32_t r127_u;
+	uint32_t r255_l;
+	uint32_t r255_u;
+	uint32_t r511_l;
+	uint32_t r511_u;
+	uint32_t r1023_l;
+	uint32_t r1023_u;
+	uint32_t r1518_l;
+	uint32_t r1518_u;
+	uint32_t r1519x_l;
+	uint32_t r1519x_u;
+	uint32_t rovr_l;
+	uint32_t rovr_u;
+	uint32_t rjbr_l;
+	uint32_t rjbr_u;
+	uint32_t rfrg_l;
+	uint32_t rfrg_u;
+	uint32_t rcnp_l;
+	uint32_t rcnp_u;
+	uint32_t rdrntp_l;
+	uint32_t rdrntp_u;
+	uint32_t res01d0[12];
+	/* Tx Statistics Counter */
+	uint32_t teoct_l;
+	uint32_t teoct_u;
+	uint32_t toct_l;
+	uint32_t toct_u;
+	uint32_t res0210[2];
+	uint32_t txpf_l;
+	uint32_t txpf_u;
+	uint32_t tfrm_l;
+	uint32_t tfrm_u;
+	uint32_t tfcs_l;
+	uint32_t tfcs_u;
+	uint32_t tvlan_l;
+	uint32_t tvlan_u;
+	uint32_t terr_l;
+	uint32_t terr_u;
+	uint32_t tuca_l;
+	uint32_t tuca_u;
+	uint32_t tmca_l;
+	uint32_t tmca_u;
+	uint32_t tbca_l;
+	uint32_t tbca_u;
+	uint32_t res0258[2];
+	uint32_t tpkt_l;
+	uint32_t tpkt_u;
+	uint32_t tund_l;
+	uint32_t tund_u;
+	uint32_t t64_l;
+	uint32_t t64_u;
+	uint32_t t127_l;
+	uint32_t t127_u;
+	uint32_t t255_l;
+	uint32_t t255_u;
+	uint32_t t511_l;
+	uint32_t t511_u;
+	uint32_t t1023_l;
+	uint32_t t1023_u;
+	uint32_t t1518_l;
+	uint32_t t1518_u;
+	uint32_t t1519x_l;
+	uint32_t t1519x_u;
+	uint32_t res02a8[6];
+	uint32_t tcnp_l;
+	uint32_t tcnp_u;
+	uint32_t res02c8[14];
+	/* Line Interface Control */
+	uint32_t if_mode;	/* 0x300 Interface Mode Control */
+	uint32_t if_status;	/* 0x304 Interface Status */
+	uint32_t res0308[14];
+	/* HiGig/2 */
+	uint32_t hg_config;	/* 0x340 Control and cfg */
+	uint32_t res0344[3];
+	uint32_t hg_pause_quanta;	/* 0x350 Pause quanta */
+	uint32_t res0354[3];
+	uint32_t hg_pause_thresh;	/* 0x360 Pause quanta threshold */
+	uint32_t res0364[3];
+	uint32_t hgrx_pause_status;	/* 0x370 Receive pause status */
+	uint32_t hg_fifos_status;	/* 0x374 fifos status */
+	uint32_t rhm;		/* 0x378 rx messages counter */
+	uint32_t thm;		/* 0x37C tx messages counter */
+};
+
+struct memac_cfg {
+	bool reset_on_init;
+	bool rx_error_discard;
+	bool pause_ignore;
+	bool pause_forward_enable;
+	bool no_length_check_enable;
+	bool cmd_frame_enable;
+	bool send_idle_enable;
+	bool wan_mode_enable;
+	bool promiscuous_mode_enable;
+	bool tx_addr_ins_enable;
+	bool loopback_enable;
+	bool lgth_check_nostdr;
+	bool time_stamp_enable;
+	bool pad_enable;
+	bool phy_tx_ena_on;
+	bool rx_sfd_any;
+	bool rx_pbl_fwd;
+	bool tx_pbl_fwd;
+	bool debug_mode;
+	bool wake_on_lan;
+	uint16_t max_frame_length;
+	uint16_t pause_quanta;
+	uint32_t tx_ipg_length;
+};
+
+/**
+*fman_memac_defconfig() - Get default MEMAC configuration
+*@cfg:    pointer to configuration structure.
+ *
+*Call this function to obtain a default set of configuration values for
+*initializing MEMAC. The user can overwrite any of the values before calling
+*fman_memac_init(), if specific configuration needs to be applied.
+ */
+void fman_memac_defconfig(struct memac_cfg *cfg);
+
+int fman_memac_init(struct memac_regs __iomem *regs,
+		    struct memac_cfg *cfg,
+		    enum enet_interface enet_interface,
+		    enum enet_speed enet_speed, uint32_t exceptions);
+
+void fman_memac_enable(struct memac_regs __iomem *regs, bool apply_rx,
+		       bool apply_tx);
+
+void fman_memac_disable(struct memac_regs __iomem *regs, bool apply_rx,
+			bool apply_tx);
+
+void fman_memac_set_promiscuous(struct memac_regs __iomem *regs, bool val);
+
+void fman_memac_add_addr_in_paddr(struct memac_regs __iomem *regs,
+				  uint8_t *adr, uint8_t paddr_num);
+
+void fman_memac_clear_addr_in_paddr(struct memac_regs __iomem *regs,
+				    uint8_t paddr_num);
+
+uint64_t fman_memac_get_counter(struct memac_regs __iomem *regs,
+				enum memac_counters reg_name);
+
+void fman_memac_set_tx_pause_frames(struct memac_regs __iomem *regs,
+				    uint8_t priority, uint16_t pause_time,
+				    uint16_t thresh_time);
+
+uint16_t fman_memac_get_max_frame_len(struct memac_regs __iomem *regs);
+
+void fman_memac_set_exception(struct memac_regs __iomem *regs, uint32_t val,
+			      bool enable);
+
+void fman_memac_reset_stat(struct memac_regs __iomem *regs);
+
+void fman_memac_reset(struct memac_regs __iomem *regs);
+
+void fman_memac_reset_filter_table(struct memac_regs __iomem *regs);
+
+void fman_memac_set_hash_table_entry(struct memac_regs __iomem *regs,
+				     uint32_t crc);
+
+void fman_memac_set_hash_table(struct memac_regs __iomem *regs, uint32_t val);
+
+void fman_memac_set_rx_ignore_pause_frames(struct memac_regs __iomem *regs,
+					   bool enable);
+
+void fman_memac_set_wol(struct memac_regs __iomem *regs, bool enable);
+
+uint32_t fman_memac_get_event(struct memac_regs __iomem *regs,
+			      uint32_t ev_mask);
+
+void fman_memac_ack_event(struct memac_regs __iomem *regs, uint32_t ev_mask);
+
+uint32_t fman_memac_get_interrupt_mask(struct memac_regs __iomem *regs);
+
+void fman_memac_adjust_link(struct memac_regs __iomem *regs,
+			    enum enet_interface iface_mode,
+			    enum enet_speed speed, bool full_dx);
+
+#endif /*__FSL_FMAN_MEMAC_H*/
diff --git a/drivers/soc/fsl/fman/flib/fsl_fman_memac_mii_acc.h b/drivers/soc/fsl/fman/flib/fsl_fman_memac_mii_acc.h
new file mode 100644
index 0000000..2efd2a0
--- /dev/null
+++ b/drivers/soc/fsl/fman/flib/fsl_fman_memac_mii_acc.h
@@ -0,0 +1,77 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __FSL_FMAN_MEMAC_MII_ACC_H
+#define __FSL_FMAN_MEMAC_MII_ACC_H
+
+#include "common/general.h"
+#include "fsl_enet.h"
+/* MII Management Registers */
+#define MDIO_CFG_CLK_DIV_MASK       0x0080ff80
+#define MDIO_CFG_HOLD_MASK          0x0000001c
+#define MDIO_CFG_ENC45              0x00000040
+#define MDIO_CFG_READ_ERR           0x00000002
+#define MDIO_CFG_BSY                0x00000001
+
+#define MDIO_CTL_PHY_ADDR_SHIFT     5
+#define MDIO_CTL_READ               0x00008000
+
+#define MDIO_DATA_BSY               0x80000000
+
+/*MEMAC Internal PHY Registers - SGMII */
+#define PHY_SGMII_CR_PHY_RESET          0x8000
+#define PHY_SGMII_CR_RESET_AN           0x0200
+#define PHY_SGMII_CR_DEF_VAL            0x1140
+#define PHY_SGMII_DEV_ABILITY_SGMII     0x4001
+#define PHY_SGMII_DEV_ABILITY_1000X     0x01A0
+#define PHY_SGMII_IF_MODE_AN            0x0002
+#define PHY_SGMII_IF_MODE_SGMII         0x0001
+#define PHY_SGMII_IF_MODE_1000X         0x0000
+
+/*----------------------------------------------------*/
+/* MII Configuration Control Memory Map Registers     */
+/*----------------------------------------------------*/
+struct memac_mii_access_mem_map {
+	uint32_t mdio_cfg;	/* 0x030  */
+	uint32_t mdio_ctrl;	/* 0x034  */
+	uint32_t mdio_data;	/* 0x038  */
+	uint32_t mdio_addr;	/* 0x03c  */
+};
+
+int fman_memac_mii_read_phy_reg(struct memac_mii_access_mem_map __iomem
+				*mii_regs, uint8_t phy_addr, uint8_t reg,
+				uint16_t *data, enum enet_speed enet_speed);
+int fman_memac_mii_write_phy_reg(struct memac_mii_access_mem_map __iomem
+				 *mii_regs, uint8_t phy_addr, uint8_t reg,
+				 uint16_t data, enum enet_speed enet_speed);
+
+#endif /* __MAC_API_MEMAC_MII_ACC_H */
diff --git a/drivers/soc/fsl/fman/flib/fsl_fman_port.h b/drivers/soc/fsl/fman/flib/fsl_fman_port.h
new file mode 100644
index 0000000..d9568e0
--- /dev/null
+++ b/drivers/soc/fsl/fman/flib/fsl_fman_port.h
@@ -0,0 +1,602 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __FSL_FMAN_PORT_H
+#define __FSL_FMAN_PORT_H
+
+#include "fsl_fman_sp.h"
+
+/* Registers bit fields */
+
+/* BMI defines */
+#define BMI_EBD_EN				0x80000000
+
+#define BMI_PORT_CFG_EN				0x80000000
+#define BMI_PORT_CFG_FDOVR			0x02000000
+#define BMI_PORT_CFG_IM				0x01000000
+
+#define BMI_PORT_STATUS_BSY			0x80000000
+
+#define BMI_DMA_ATTR_SWP_SHIFT			FMAN_SP_DMA_ATTR_SWP_SHIFT
+#define BMI_DMA_ATTR_IC_STASH_ON		0x10000000
+#define BMI_DMA_ATTR_HDR_STASH_ON		0x04000000
+#define BMI_DMA_ATTR_SG_STASH_ON		0x01000000
+#define BMI_DMA_ATTR_WRITE_OPTIMIZE		FMAN_SP_DMA_ATTR_WRITE_OPTIMIZE
+
+#define BMI_RX_FIFO_PRI_ELEVATION_SHIFT		16
+#define BMI_RX_FIFO_THRESHOLD_ETHE		0x80000000
+
+#define BMI_TX_FRAME_END_CS_IGNORE_SHIFT	24
+#define BMI_RX_FRAME_END_CS_IGNORE_SHIFT	24
+#define BMI_RX_FRAME_END_CUT_SHIFT		16
+
+#define BMI_IC_TO_EXT_SHIFT			FMAN_SP_IC_TO_EXT_SHIFT
+#define BMI_IC_FROM_INT_SHIFT			FMAN_SP_IC_FROM_INT_SHIFT
+
+#define BMI_INT_BUF_MARG_SHIFT			28
+#define BMI_EXT_BUF_MARG_START_SHIFT		FMAN_SP_EXT_BUF_MARG_START_SHIFT
+
+#define BMI_CMD_MR_LEAC				0x00200000
+#define BMI_CMD_MR_SLEAC			0x00100000
+#define BMI_CMD_MR_MA				0x00080000
+#define BMI_CMD_MR_DEAS				0x00040000
+#define BMI_CMD_RX_MR_DEF			(BMI_CMD_MR_LEAC | \
+						BMI_CMD_MR_SLEAC | \
+						BMI_CMD_MR_MA | \
+						BMI_CMD_MR_DEAS)
+#define BMI_CMD_TX_MR_DEF			0
+#define BMI_CMD_OP_MR_DEF			(BMI_CMD_MR_DEAS | \
+						BMI_CMD_MR_MA)
+
+#define BMI_CMD_ATTR_ORDER			0x80000000
+#define BMI_CMD_ATTR_SYNC			0x02000000
+#define BMI_CMD_ATTR_COLOR_SHIFT		26
+
+#define BMI_FIFO_PIPELINE_DEPTH_SHIFT           12
+#define BMI_NEXT_ENG_FD_BITS_SHIFT		24
+#define BMI_FRAME_END_CS_IGNORE_SHIFT           24
+
+#define BMI_COUNTERS_EN				0x80000000
+
+#define BMI_EXT_BUF_POOL_VALID			FMAN_SP_EXT_BUF_POOL_VALID
+#define BMI_EXT_BUF_POOL_EN_COUNTER		FMAN_SP_EXT_BUF_POOL_EN_COUNTER
+#define BMI_EXT_BUF_POOL_BACKUP			FMAN_SP_EXT_BUF_POOL_BACKUP
+#define BMI_EXT_BUF_POOL_ID_SHIFT		16
+#define BMI_EXT_BUF_POOL_ID_MASK		0x003F0000
+#define BMI_POOL_DEP_NUM_OF_POOLS_SHIFT		16
+
+#define BMI_TX_FIFO_MIN_FILL_SHIFT		16
+#define BMI_TX_FIFO_PIPELINE_DEPTH_SHIFT	12
+
+#define MAX_PERFORMANCE_TASK_COMP		64
+#define MAX_PERFORMANCE_RX_QUEUE_COMP		64
+#define MAX_PERFORMANCE_TX_QUEUE_COMP		8
+#define MAX_PERFORMANCE_DMA_COMP		16
+#define MAX_PERFORMANCE_FIFO_COMP		1024
+
+#define BMI_PERFORMANCE_TASK_COMP_SHIFT		24
+#define BMI_PERFORMANCE_QUEUE_COMP_SHIFT	16
+#define BMI_PERFORMANCE_DMA_COMP_SHIFT		12
+
+#define BMI_RATE_LIMIT_GRAN_TX			16000	/* In Kbps */
+#define BMI_RATE_LIMIT_GRAN_OP			10000	/* In frames */
+#define BMI_RATE_LIMIT_MAX_RATE_IN_GRAN_UNITS	1024
+#define BMI_RATE_LIMIT_MAX_BURST_SIZE		1024	/* In KBytes */
+#define BMI_RATE_LIMIT_MAX_BURST_SHIFT		16
+#define BMI_RATE_LIMIT_HIGH_BURST_SIZE_GRAN	0x80000000
+#define BMI_RATE_LIMIT_SCALE_TSBS_SHIFT		16
+#define BMI_RATE_LIMIT_SCALE_EN			0x80000000
+#define BMI_SG_DISABLE                          FMAN_SP_SG_DISABLE
+
+/* QMI defines */
+#define QMI_PORT_CFG_EN				0x80000000
+#define QMI_PORT_CFG_EN_COUNTERS		0x10000000
+
+#define QMI_PORT_STATUS_DEQ_TNUM_BSY		0x80000000
+#define QMI_PORT_STATUS_DEQ_FD_BSY		0x20000000
+
+#define QMI_DEQ_CFG_PRI				0x80000000
+#define QMI_DEQ_CFG_TYPE1			0x10000000
+#define QMI_DEQ_CFG_TYPE2			0x20000000
+#define QMI_DEQ_CFG_TYPE3			0x30000000
+#define QMI_DEQ_CFG_PREFETCH_PARTIAL		0x01000000
+#define QMI_DEQ_CFG_PREFETCH_FULL		0x03000000
+#define QMI_DEQ_CFG_SP_MASK			0xf
+#define QMI_DEQ_CFG_SP_SHIFT			20
+
+/* General port defines */
+#define FMAN_PORT_EXT_POOLS_NUM(fm_rev_maj) \
+		(((fm_rev_maj) == 4) ? 4 : 8)
+#define FMAN_PORT_MAX_EXT_POOLS_NUM	8
+#define FMAN_PORT_OBS_EXT_POOLS_NUM	2
+#define FMAN_PORT_CG_MAP_NUM		8
+#define FMAN_PORT_PRS_RESULT_WORDS_NUM	8
+#define FMAN_PORT_BMI_FIFO_UNITS	0x100
+#define FMAN_PORT_IC_OFFSET_UNITS	0x10
+
+/* FM Port Register Map */
+
+/* BMI Rx port register map */
+struct fman_port_rx_bmi_regs {
+	uint32_t fmbm_rcfg;		/* Rx Configuration */
+	uint32_t fmbm_rst;		/* Rx Status */
+	uint32_t fmbm_rda;		/* Rx DMA attributes*/
+	uint32_t fmbm_rfp;		/* Rx FIFO Parameters*/
+	uint32_t fmbm_rfed;		/* Rx Frame End Data*/
+	uint32_t fmbm_ricp;		/* Rx Internal Context Parameters*/
+	uint32_t fmbm_rim;		/* Rx Internal Buffer Margins*/
+	uint32_t fmbm_rebm;		/* Rx External Buffer Margins*/
+	uint32_t fmbm_rfne;		/* Rx Frame Next Engine*/
+	uint32_t fmbm_rfca;		/* Rx Frame Command Attributes.*/
+	uint32_t fmbm_rfpne;		/* Rx Frame Parser Next Engine*/
+	uint32_t fmbm_rpso;		/* Rx Parse Start Offset*/
+	uint32_t fmbm_rpp;		/* Rx Policer Profile  */
+	uint32_t fmbm_rccb;		/* Rx Coarse Classification Base */
+	uint32_t fmbm_reth;		/* Rx Excessive Threshold */
+	uint32_t reserved003c[1];	/* (0x03C 0x03F) */
+	uint32_t fmbm_rprai[FMAN_PORT_PRS_RESULT_WORDS_NUM];
+					/* Rx Parse Results Array Init*/
+	uint32_t fmbm_rfqid;		/* Rx Frame Queue ID*/
+	uint32_t fmbm_refqid;		/* Rx Error Frame Queue ID*/
+	uint32_t fmbm_rfsdm;		/* Rx Frame Status Discard Mask*/
+	uint32_t fmbm_rfsem;		/* Rx Frame Status Error Mask*/
+	uint32_t fmbm_rfene;		/* Rx Frame Enqueue Next Engine */
+	uint32_t reserved0074[0x2];	/* (0x074-0x07C)  */
+	uint32_t fmbm_rcmne; /* Rx Frame Continuous Mode Next Engine */
+	uint32_t reserved0080[0x20];/* (0x080 0x0FF)  */
+	uint32_t fmbm_ebmpi[FMAN_PORT_MAX_EXT_POOLS_NUM];
+					/* Buffer Manager pool Information-*/
+	uint32_t fmbm_acnt[FMAN_PORT_MAX_EXT_POOLS_NUM];
+					/* Allocate Counter-*/
+	uint32_t reserved0130[8];
+					/* 0x130/0x140 - 0x15F reserved -*/
+	uint32_t fmbm_rcgm[FMAN_PORT_CG_MAP_NUM];
+					/* Congestion Group Map*/
+	uint32_t fmbm_mpd;		/* BM Pool Depletion  */
+	uint32_t reserved0184[0x1F];	/* (0x184 0x1FF) */
+	uint32_t fmbm_rstc;		/* Rx Statistics Counters*/
+	uint32_t fmbm_rfrc;		/* Rx Frame Counter*/
+	uint32_t fmbm_rfbc;		/* Rx Bad Frames Counter*/
+	uint32_t fmbm_rlfc;		/* Rx Large Frames Counter*/
+	uint32_t fmbm_rffc;		/* Rx Filter Frames Counter*/
+	uint32_t fmbm_rfdc;		/* Rx Frame Discard Counter*/
+	uint32_t fmbm_rfldec;		/* Rx Frames List DMA Error Counter*/
+	uint32_t fmbm_rodc;		/* Rx Out of Buffers Discard nntr*/
+	uint32_t fmbm_rbdc;		/* Rx Buffers Deallocate Counter*/
+	uint32_t reserved0224[0x17];	/* (0x224 0x27F) */
+	uint32_t fmbm_rpc;		/* Rx Performance Counters*/
+	uint32_t fmbm_rpcp;		/* Rx Performance Count Parameters*/
+	uint32_t fmbm_rccn;		/* Rx Cycle Counter*/
+	uint32_t fmbm_rtuc;		/* Rx Tasks Utilization Counter*/
+	uint32_t fmbm_rrquc;		/* Rx Receive Queue Utilization cntr*/
+	uint32_t fmbm_rduc;		/* Rx DMA Utilization Counter*/
+	uint32_t fmbm_rfuc;		/* Rx FIFO Utilization Counter*/
+	uint32_t fmbm_rpac;		/* Rx Pause Activation Counter*/
+	uint32_t reserved02a0[0x18];	/* (0x2A0 0x2FF) */
+	uint32_t fmbm_rdbg;		/* Rx Debug-*/
+};
+
+/* BMI Tx port register map */
+struct fman_port_tx_bmi_regs {
+	uint32_t fmbm_tcfg;		/* Tx Configuration */
+	uint32_t fmbm_tst;		/* Tx Status */
+	uint32_t fmbm_tda;		/* Tx DMA attributes */
+	uint32_t fmbm_tfp;		/* Tx FIFO Parameters */
+	uint32_t fmbm_tfed;		/* Tx Frame End Data */
+	uint32_t fmbm_ticp;		/* Tx Internal Context Parameters */
+	uint32_t fmbm_tfdne;		/* Tx Frame Dequeue Next Engine. */
+	uint32_t fmbm_tfca;		/* Tx Frame Command attribute. */
+	uint32_t fmbm_tcfqid;		/* Tx Confirmation Frame Queue ID. */
+	uint32_t fmbm_tefqid;		/* Tx Frame Error Queue ID */
+	uint32_t fmbm_tfene;		/* Tx Frame Enqueue Next Engine */
+	uint32_t fmbm_trlmts;		/* Tx Rate Limiter Scale */
+	uint32_t fmbm_trlmt;		/* Tx Rate Limiter */
+	uint32_t reserved0034[0x0e];	/* (0x034-0x6c) */
+	uint32_t fmbm_tccb;		/* Tx Coarse Classification base */
+	uint32_t fmbm_tfne;		/* Tx Frame Next Engine */
+	/* Tx Priority based Flow Control (PFC) Mapping */
+	uint32_t fmbm_tpfcm[0x02];
+	/* Tx Frame Continuous Mode Next Engine */
+	uint32_t fmbm_tcmne;
+	uint32_t reserved0080[0x60];	/* (0x080-0x200) */
+	uint32_t fmbm_tstc;		/* Tx Statistics Counters */
+	uint32_t fmbm_tfrc;		/* Tx Frame Counter */
+	uint32_t fmbm_tfdc;		/* Tx Frames Discard Counter */
+	uint32_t fmbm_tfledc;		/* Tx Frame len error discard cntr */
+	uint32_t fmbm_tfufdc;		/* Tx Frame unsprt frmt discard cntr*/
+	uint32_t fmbm_tbdc;		/* Tx Buffers Deallocate Counter */
+	uint32_t reserved0218[0x1A];	/* (0x218-0x280) */
+	uint32_t fmbm_tpc;		/* Tx Performance Counters*/
+	uint32_t fmbm_tpcp;		/* Tx Performance Count Parameters*/
+	uint32_t fmbm_tccn;		/* Tx Cycle Counter*/
+	uint32_t fmbm_ttuc;		/* Tx Tasks Utilization Counter*/
+	uint32_t fmbm_ttcquc;		/* Tx Transmit conf Q util Counter*/
+	uint32_t fmbm_tduc;		/* Tx DMA Utilization Counter*/
+	uint32_t fmbm_tfuc;		/* Tx FIFO Utilization Counter*/
+};
+
+/* BMI O/H port register map */
+struct fman_port_oh_bmi_regs {
+	uint32_t fmbm_ocfg;		/* O/H Configuration  */
+	uint32_t fmbm_ost;		/* O/H Status */
+	uint32_t fmbm_oda;		/* O/H DMA attributes  */
+	uint32_t fmbm_oicp;		/* O/H Internal Context Parameters */
+	uint32_t fmbm_ofdne;		/* O/H Frame Dequeue Next Engine  */
+	uint32_t fmbm_ofne;		/* O/H Frame Next Engine  */
+	uint32_t fmbm_ofca;		/* O/H Frame Command Attributes.  */
+	uint32_t fmbm_ofpne;		/* O/H Frame Parser Next Engine  */
+	uint32_t fmbm_opso;		/* O/H Parse Start Offset  */
+	uint32_t fmbm_opp;		/* O/H Policer Profile */
+	uint32_t fmbm_occb;		/* O/H Coarse Classification base */
+	uint32_t fmbm_oim;		/* O/H Internal margins*/
+	uint32_t fmbm_ofp;		/* O/H Fifo Parameters*/
+	uint32_t fmbm_ofed;		/* O/H Frame End Data*/
+	uint32_t reserved0030[2];	/* (0x038 - 0x03F) */
+	uint32_t fmbm_oprai[FMAN_PORT_PRS_RESULT_WORDS_NUM];
+				/* O/H Parse Results Array Initialization  */
+	uint32_t fmbm_ofqid;		/* O/H Frame Queue ID  */
+	uint32_t fmbm_oefqid;		/* O/H Error Frame Queue ID  */
+	uint32_t fmbm_ofsdm;		/* O/H Frame Status Discard Mask  */
+	uint32_t fmbm_ofsem;		/* O/H Frame Status Error Mask  */
+	uint32_t fmbm_ofene;		/* O/H Frame Enqueue Next Engine  */
+	uint32_t fmbm_orlmts;		/* O/H Rate Limiter Scale  */
+	uint32_t fmbm_orlmt;		/* O/H Rate Limiter  */
+	uint32_t fmbm_ocmne;		/* O/H Continuous Mode Next Engine  */
+	uint32_t reserved0080[0x20];	/* 0x080 - 0x0FF Reserved */
+	uint32_t fmbm_oebmpi[2];	/* Buf Mngr Observed Pool Info */
+	uint32_t reserved0108[0x16];	/* 0x108 - 0x15F Reserved */
+	uint32_t fmbm_ocgm;		/* Observed Congestion Group Map */
+	uint32_t reserved0164[0x7];	/* 0x164 - 0x17F Reserved */
+	uint32_t fmbm_ompd;		/* Observed BMan Pool Depletion */
+	uint32_t reserved0184[0x1F];	/* 0x184 - 0x1FF Reserved */
+	uint32_t fmbm_ostc;		/* O/H Statistics Counters  */
+	uint32_t fmbm_ofrc;		/* O/H Frame Counter  */
+	uint32_t fmbm_ofdc;		/* O/H Frames Discard Counter  */
+	uint32_t fmbm_ofledc;		/* O/H Frames Len Err Discard Cntr */
+	uint32_t fmbm_ofufdc;		/* O/H Frames Unsprtd Discard Cutr  */
+	uint32_t fmbm_offc;		/* O/H Filter Frames Counter  */
+	uint32_t fmbm_ofwdc;		/* Rx Frames WRED Discard Counter  */
+	uint32_t fmbm_ofldec;		/* O/H Frames List DMA Error Cntr */
+	uint32_t fmbm_obdc;		/* O/H Buffers Deallocate Counter */
+	uint32_t reserved0218[0x17];	/* (0x218 - 0x27F) */
+	uint32_t fmbm_opc;		/* O/H Performance Counters  */
+	uint32_t fmbm_opcp;		/* O/H Performance Count Parameters */
+	uint32_t fmbm_occn;		/* O/H Cycle Counter  */
+	uint32_t fmbm_otuc;		/* O/H Tasks Utilization Counter  */
+	uint32_t fmbm_oduc;		/* O/H DMA Utilization Counter */
+	uint32_t fmbm_ofuc;		/* O/H FIFO Utilization Counter */
+};
+
+/* BMI port register map */
+union fman_port_bmi_regs {
+	struct fman_port_rx_bmi_regs rx;
+	struct fman_port_tx_bmi_regs tx;
+	struct fman_port_oh_bmi_regs oh;
+};
+
+/* QMI port register map */
+struct fman_port_qmi_regs {
+	uint32_t fmqm_pnc;		/* PortID n Configuration Register */
+	uint32_t fmqm_pns;		/* PortID n Status Register */
+	uint32_t fmqm_pnts;		/* PortID n Task Status Register */
+	uint32_t reserved00c[4];	/* 0xn00C - 0xn01B */
+	uint32_t fmqm_pnen;		/* PortID n Enqueue NIA Register */
+	uint32_t fmqm_pnetfc;		/* PortID n Enq Total Frame Counter */
+	uint32_t reserved024[2];	/* 0xn024 - 0x02B */
+	uint32_t fmqm_pndn;		/* PortID n Dequeue NIA Register */
+	uint32_t fmqm_pndc;		/* PortID n Dequeue Config Register */
+	uint32_t fmqm_pndtfc;		/* PortID n Dequeue tot Frame cntr */
+	uint32_t fmqm_pndfdc;		/* PortID n Dequeue FQID Dflt Cntr */
+	uint32_t fmqm_pndcc;		/* PortID n Dequeue Confirm Counter */
+};
+
+enum fman_port_dma_swap {
+	E_FMAN_PORT_DMA_NO_SWAP,	/* No swap, transfer data as is */
+	E_FMAN_PORT_DMA_SWAP_LE,
+	/* The transferred data should be swapped in PPC Little Endian mode */
+	E_FMAN_PORT_DMA_SWAP_BE
+	/* The transferred data should be swapped in Big Endian mode */
+};
+
+/* Default port color */
+enum fman_port_color {
+	E_FMAN_PORT_COLOR_GREEN,	/* Default port color is green */
+	E_FMAN_PORT_COLOR_YELLOW,	/* Default port color is yellow */
+	E_FMAN_PORT_COLOR_RED,		/* Default port color is red */
+	E_FMAN_PORT_COLOR_OVERRIDE	/* Ignore color */
+};
+
+/* QMI dequeue from the SP channel - types */
+enum fman_port_deq_type {
+	E_FMAN_PORT_DEQ_BY_PRI,
+	/* Priority precedence and Intra-Class scheduling */
+	E_FMAN_PORT_DEQ_ACTIVE_FQ,
+	/* Active FQ precedence and Intra-Class scheduling */
+	E_FMAN_PORT_DEQ_ACTIVE_FQ_NO_ICS
+	/* Active FQ precedence and override Intra-Class scheduling */
+};
+
+/* QMI dequeue prefetch modes */
+enum fman_port_deq_prefetch {
+	E_FMAN_PORT_DEQ_NO_PREFETCH, /* No prefetch mode */
+	E_FMAN_PORT_DEQ_PART_PREFETCH, /* Partial prefetch mode */
+	E_FMAN_PORT_DEQ_FULL_PREFETCH /* Full prefetch mode */
+};
+
+/* Parameters for defining performance counters behavior */
+struct fman_port_perf_cnt_params {
+	uint8_t task_val;	/* Task compare value */
+	uint8_t queue_val;
+	/* Rx or Tx conf queue compare value (unused for O/H ports) */
+	uint8_t dma_val;	/* Dma compare value */
+	uint32_t fifo_val;	/* Fifo compare value (in bytes) */
+};
+
+/* FM Port configuration structure, used at init */
+struct fman_port_cfg {
+	struct fman_port_perf_cnt_params perf_cnt_params;
+	/* BMI parameters */
+	enum fman_port_dma_swap dma_swap_data;
+	bool dma_ic_stash_on;
+	bool dma_header_stash_on;
+	bool dma_sg_stash_on;
+	bool dma_write_optimize;
+	uint16_t ic_ext_offset;
+	uint8_t ic_int_offset;
+	uint16_t ic_size;
+	enum fman_port_color color;
+	bool sync_req;
+	bool discard_override;
+	uint8_t checksum_bytes_ignore;
+	uint8_t rx_cut_end_bytes;
+	uint32_t rx_pri_elevation;
+	uint32_t rx_fifo_thr;
+	uint8_t rx_fd_bits;
+	uint8_t int_buf_start_margin;
+	uint16_t ext_buf_start_margin;
+	uint16_t ext_buf_end_margin;
+	uint32_t tx_fifo_min_level;
+	uint32_t tx_fifo_low_comf_level;
+	uint8_t tx_fifo_deq_pipeline_depth;
+	bool stats_counters_enable;
+	bool perf_counters_enable;
+	/* QMI parameters */
+	bool deq_high_pri;
+	enum fman_port_deq_type deq_type;
+	enum fman_port_deq_prefetch deq_prefetch_opt;
+	uint16_t deq_byte_cnt;
+	bool queue_counters_enable;
+	bool no_scatter_gather;
+	int errata_A006675;
+	int errata_A006320;
+	int excessive_threshold_register;
+	int fmbm_rebm_has_sgd;
+	int fmbm_tfne_has_features;
+	int qmi_deq_options_support;
+};
+
+enum fman_port_type {
+	E_FMAN_PORT_TYPE_OP = 0,
+	/* Offline parsing port, shares id-s with
+	 * host command, so must have exclusive id-s
+	 */
+	E_FMAN_PORT_TYPE_RX,	    /* 1G Rx port */
+	E_FMAN_PORT_TYPE_RX_10G,    /* 10G Rx port */
+	E_FMAN_PORT_TYPE_TX,	    /* 1G Tx port */
+	E_FMAN_PORT_TYPE_TX_10G,     /* 10G Tx port */
+	E_FMAN_PORT_TYPE_DUMMY,
+	E_FMAN_PORT_TYPE_HC = E_FMAN_PORT_TYPE_DUMMY
+	/* Host command port, shares id-s with
+	 * offline parsing ports, so must have exclusive id-s
+	 */
+};
+
+struct fman_port_params {
+	uint32_t discard_mask;
+	uint32_t err_mask;
+	uint32_t dflt_fqid;
+	uint32_t err_fqid;
+	uint8_t deq_sp;
+	bool dont_release_buf;
+};
+
+/* Port context - used by most API functions */
+struct fman_port {
+	enum fman_port_type type;
+	uint8_t fm_rev_maj;
+	uint8_t fm_rev_min;
+	union fman_port_bmi_regs __iomem *bmi_regs;
+	struct fman_port_qmi_regs __iomem *qmi_regs;
+	uint8_t ext_pools_num;
+};
+
+/* External buffer pools configuration */
+struct fman_port_bpools {
+	uint8_t count;			/* Num of pools to set up */
+	bool counters_enable;		/* Enable allocate counters */
+	uint8_t grp_bp_depleted_num;
+	/* Number of depleted pools - if reached the BMI indicates
+	 * the MAC to send a pause frame
+	 */
+	struct {
+		uint8_t bpid;		/* BM pool ID */
+		uint16_t size;
+		/* Pool's size - must be in ascending order */
+		bool is_backup;
+		/* If this is a backup pool */
+		bool grp_bp_depleted;
+		/* Consider this buffer in multiple pools depletion criteria*/
+		bool single_bp_depleted;
+		/* Consider this buffer in single pool depletion criteria */
+		bool pfc_priorities_en;
+	} bpool[FMAN_PORT_MAX_EXT_POOLS_NUM];
+};
+
+enum fman_port_rate_limiter_scale_down {
+	E_FMAN_PORT_RATE_DOWN_NONE,
+	E_FMAN_PORT_RATE_DOWN_BY_2,
+	E_FMAN_PORT_RATE_DOWN_BY_4,
+	E_FMAN_PORT_RATE_DOWN_BY_8
+};
+
+/* Rate limiter configuration */
+struct fman_port_rate_limiter {
+	uint8_t count_1micro_bit;
+	bool high_burst_size_gran;
+	/* Defines burst_size granularity for OP ports; when true,
+	 * burst_size below counts in frames, otherwise in 10^3 frames
+	 */
+	uint16_t burst_size;
+	/* Max burst size, in KBytes for Tx port, according to
+	 * high_burst_size_gran definition for OP port
+	 */
+	uint32_t rate;
+	/* In Kbps for Tx port, in frames/sec for OP port */
+	enum fman_port_rate_limiter_scale_down rate_factor;
+};
+
+/* BMI statistics counters */
+enum fman_port_stats_counters {
+	E_FMAN_PORT_STATS_CNT_FRAME,
+	/* Number of processed frames; valid for all ports */
+	E_FMAN_PORT_STATS_CNT_DISCARD,
+	/* For Rx ports - frames discarded by QMAN, for Tx or O/H ports -
+	 * frames discarded due to DMA error; valid for all ports
+	 */
+	E_FMAN_PORT_STATS_CNT_DEALLOC_BUF,
+	/* Number of buffer deallocate operations; valid for all ports */
+	E_FMAN_PORT_STATS_CNT_RX_BAD_FRAME,
+	/* Number of bad Rx frames, like CRC error, Rx FIFO overflow etc;
+	 * valid for Rx ports only
+	 */
+	E_FMAN_PORT_STATS_CNT_RX_LARGE_FRAME,
+	/* Number of Rx oversized frames, that is frames exceeding max frame
+	 * size configured for the corresponding ETH controller;
+	 * valid for Rx ports only
+	 */
+	E_FMAN_PORT_STATS_CNT_RX_OUT_OF_BUF,
+	/* Frames discarded due to lack of external buffers; valid for
+	 * Rx ports only
+	 */
+	E_FMAN_PORT_STATS_CNT_LEN_ERR,
+	/* Frames discarded due to frame length error; valid for Tx and
+	 * O/H ports only
+	 */
+	E_FMAN_PORT_STATS_CNT_UNSUPPORTED_FORMAT,
+	/* Frames discarded due to unsupported FD format; valid for Tx
+	 * and O/H ports only
+	 */
+	E_FMAN_PORT_STATS_CNT_FILTERED_FRAME,
+	/* Number of frames filtered out by PCD module; valid for
+	 * Rx and OP ports only
+	 */
+	E_FMAN_PORT_STATS_CNT_DMA_ERR,
+	/* Frames rejected by QMAN that were not able to release their
+	 * buffers due to DMA error; valid for Rx and O/H ports only
+	 */
+	E_FMAN_PORT_STATS_CNT_WRED_DISCARD
+	/* Frames going through O/H port that were not able to to enter the
+	 * return queue due to WRED algorithm; valid for O/H ports only
+	 */
+};
+
+/* BMI performance counters */
+enum fman_port_perf_counters {
+	E_FMAN_PORT_PERF_CNT_CYCLE,	/* Cycle counter */
+	E_FMAN_PORT_PERF_CNT_TASK_UTIL,	/* Tasks utilization counter */
+	E_FMAN_PORT_PERF_CNT_QUEUE_UTIL,
+	/* For Rx ports - Rx queue utilization, for Tx ports - Tx conf queue
+	 * utilization; not valid for O/H ports
+	 */
+	E_FMAN_PORT_PERF_CNT_DMA_UTIL,	/* DMA utilization counter */
+	E_FMAN_PORT_PERF_CNT_FIFO_UTIL,	/* FIFO utilization counter */
+	E_FMAN_PORT_PERF_CNT_RX_PAUSE
+	/* Number of cycles in which Rx pause activation control is on;
+	 * valid for Rx ports only
+	 */
+};
+
+/* QMI counters */
+enum fman_port_qmi_counters {
+	E_FMAN_PORT_ENQ_TOTAL,	/* EnQ tot frame cntr */
+	E_FMAN_PORT_DEQ_TOTAL,	/* DeQ tot frame cntr; invalid for Rx ports*/
+	E_FMAN_PORT_DEQ_FROM_DFLT,
+	/* Dequeue from default FQID counter not valid for Rx ports */
+	E_FMAN_PORT_DEQ_CONFIRM	/* DeQ confirm cntr invalid for Rx ports */
+};
+
+/*   FM Port API */
+void fman_port_defconfig(struct fman_port_cfg *cfg, enum fman_port_type type);
+int fman_port_init(struct fman_port *port,
+		   struct fman_port_cfg *cfg, struct fman_port_params *params);
+int fman_port_enable(struct fman_port *port);
+int fman_port_disable(const struct fman_port *port);
+int fman_port_set_bpools(const struct fman_port *port,
+			 const struct fman_port_bpools *bp);
+int fman_port_set_rate_limiter(struct fman_port *port,
+			       struct fman_port_rate_limiter *rate_limiter);
+int fman_port_delete_rate_limiter(struct fman_port *port);
+int fman_port_set_err_mask(struct fman_port *port, uint32_t err_mask);
+int fman_port_set_discard_mask(struct fman_port *port, uint32_t discard_mask);
+int fman_port_modify_rx_fd_bits(struct fman_port *port,
+				uint8_t rx_fd_bits, bool add);
+int fman_port_set_perf_cnt_params(struct fman_port *port,
+				  struct fman_port_perf_cnt_params *params);
+int fman_port_set_stats_cnt_mode(struct fman_port *port, bool enable);
+int fman_port_set_perf_cnt_mode(struct fman_port *port, bool enable);
+int fman_port_set_queue_cnt_mode(struct fman_port *port, bool enable);
+int fman_port_set_bpool_cnt_mode(struct fman_port *port,
+				 uint8_t bpid, bool enable);
+uint32_t fman_port_get_stats_counter(struct fman_port *port,
+				     enum fman_port_stats_counters counter);
+void fman_port_set_stats_counter(struct fman_port *port,
+				 enum fman_port_stats_counters counter,
+				 uint32_t value);
+uint32_t fman_port_get_perf_counter(struct fman_port *port,
+				    enum fman_port_perf_counters counter);
+void fman_port_set_perf_counter(struct fman_port *port,
+				enum fman_port_perf_counters counter,
+				uint32_t value);
+uint32_t fman_port_get_qmi_counter(struct fman_port *port,
+				   enum fman_port_qmi_counters counter);
+void fman_port_set_qmi_counter(struct fman_port *port,
+			       enum fman_port_qmi_counters counter,
+			       uint32_t value);
+uint32_t fman_port_get_bpool_counter(struct fman_port *port, uint8_t bpid);
+void fman_port_set_bpool_counter(struct fman_port *port,
+				 uint8_t bpid, uint32_t value);
+int fman_port_add_congestion_grps(struct fman_port *port,
+				  uint32_t grps_map[FMAN_PORT_CG_MAP_NUM]);
+int fman_port_remove_congestion_grps(struct fman_port *port,
+				     uint32_t grps_map[FMAN_PORT_CG_MAP_NUM]);
+
+#endif /* __FSL_FMAN_PORT_H */
diff --git a/drivers/soc/fsl/fman/flib/fsl_fman_prs.h b/drivers/soc/fsl/fman/flib/fsl_fman_prs.h
new file mode 100644
index 0000000..0482b04
--- /dev/null
+++ b/drivers/soc/fsl/fman/flib/fsl_fman_prs.h
@@ -0,0 +1,106 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __FSL_FMAN_PRS_H
+#define __FSL_FMAN_PRS_H
+
+#include "common/general.h"
+
+#define FM_PCD_EX_PRS_DOUBLE_ECC	0x02000000
+#define FM_PCD_EX_PRS_SINGLE_ECC	0x01000000
+
+#define FM_PCD_PRS_PPSC_ALL_PORTS	0xffff0000
+#define FM_PCD_PRS_RPIMAC_EN		0x00000001
+#define FM_PCD_PRS_PORT_IDLE_STS	0xffff0000
+#define FM_PCD_PRS_SINGLE_ECC		0x00004000
+#define FM_PCD_PRS_DOUBLE_ECC		0x00004000
+#define PRS_MAX_CYCLE_LIMIT		8191
+
+#define DEFAULT_MAX_PRS_CYC_LIM		0
+
+struct fman_prs_regs {
+	uint32_t fmpr_rpclim;
+	uint32_t fmpr_rpimac;
+	uint32_t pmeec;
+	uint32_t res00c[5];
+	uint32_t fmpr_pevr;
+	uint32_t fmpr_pever;
+	uint32_t res028;
+	uint32_t fmpr_perr;
+	uint32_t fmpr_perer;
+	uint32_t res034;
+	uint32_t res038[10];
+	uint32_t fmpr_ppsc;
+	uint32_t res064;
+	uint32_t fmpr_pds;
+	uint32_t fmpr_l2rrs;
+	uint32_t fmpr_l3rrs;
+	uint32_t fmpr_l4rrs;
+	uint32_t fmpr_srrs;
+	uint32_t fmpr_l2rres;
+	uint32_t fmpr_l3rres;
+	uint32_t fmpr_l4rres;
+	uint32_t fmpr_srres;
+	uint32_t fmpr_spcs;
+	uint32_t fmpr_spscs;
+	uint32_t fmpr_hxscs;
+	uint32_t fmpr_mrcs;
+	uint32_t fmpr_mwcs;
+	uint32_t fmpr_mrscs;
+	uint32_t fmpr_mwscs;
+	uint32_t fmpr_fcscs;
+};
+
+struct fman_prs_cfg {
+	uint32_t port_id_stat;
+	uint16_t max_prs_cyc_lim;
+	uint32_t prs_exceptions;
+};
+
+uint32_t fman_prs_get_err_event(struct fman_prs_regs __iomem *regs,
+				uint32_t ev_mask);
+uint32_t fman_prs_get_err_ev_mask(struct fman_prs_regs __iomem *regs);
+void fman_prs_ack_err_event(struct fman_prs_regs __iomem *regs,
+			    uint32_t event);
+uint32_t fman_prs_get_expt_event(struct fman_prs_regs __iomem *regs,
+				 uint32_t ev_mask);
+uint32_t fman_prs_get_expt_ev_mask(struct fman_prs_regs __iomem *regs);
+void fman_prs_ack_expt_event(struct fman_prs_regs __iomem *regs,
+			     uint32_t event);
+void fman_prs_defconfig(struct fman_prs_cfg *cfg);
+int fman_prs_init(struct fman_prs_regs __iomem *regs, struct fman_prs_cfg *cfg);
+void fman_prs_enable(struct fman_prs_regs __iomem *regs);
+void fman_prs_disable(struct fman_prs_regs __iomem *regs);
+void fman_prs_set_stst_port_msk(struct fman_prs_regs __iomem *regs,
+				uint32_t pid_msk);
+void fman_prs_set_stst(struct fman_prs_regs __iomem *regs, bool enable);
+#endif /* __FSL_FMAN_PRS_H */
diff --git a/drivers/soc/fsl/fman/flib/fsl_fman_rtc.h b/drivers/soc/fsl/fman/flib/fsl_fman_rtc.h
new file mode 100644
index 0000000..c98a526
--- /dev/null
+++ b/drivers/soc/fsl/fman/flib/fsl_fman_rtc.h
@@ -0,0 +1,415 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __FSL_FMAN_RTC_H
+#define __FSL_FMAN_RTC_H
+
+#include "common/general.h"
+
+/* FM RTC Registers definitions */
+#define FMAN_RTC_TMR_CTRL_ALMP1                  0x80000000
+#define FMAN_RTC_TMR_CTRL_ALMP2                  0x40000000
+#define FMAN_RTC_TMR_CTRL_FS                     0x10000000
+#define FMAN_RTC_TMR_CTRL_PP1L                   0x08000000
+#define FMAN_RTC_TMR_CTRL_PP2L                   0x04000000
+#define FMAN_RTC_TMR_CTRL_TCLK_PERIOD_MASK       0x03FF0000
+#define FMAN_RTC_TMR_CTRL_FRD                    0x00004000
+#define FMAN_RTC_TMR_CTRL_SLV                    0x00002000
+#define FMAN_RTC_TMR_CTRL_ETEP1                  0x00000100
+#define FMAN_RTC_TMR_CTRL_COPH                   0x00000080
+#define FMAN_RTC_TMR_CTRL_CIPH                   0x00000040
+#define FMAN_RTC_TMR_CTRL_TMSR                   0x00000020
+#define FMAN_RTC_TMR_CTRL_DBG                    0x00000010
+#define FMAN_RTC_TMR_CTRL_BYP                    0x00000008
+#define FMAN_RTC_TMR_CTRL_TE                     0x00000004
+#define FMAN_RTC_TMR_CTRL_CKSEL_OSC_CLK          0x00000003
+#define FMAN_RTC_TMR_CTRL_CKSEL_MAC_CLK          0x00000001
+#define FMAN_RTC_TMR_CTRL_CKSEL_EXT_CLK          0x00000000
+#define FMAN_RTC_TMR_CTRL_TCLK_PERIOD_SHIFT      16
+
+#define FMAN_RTC_TMR_TEVENT_ETS2                 0x02000000
+#define FMAN_RTC_TMR_TEVENT_ETS1                 0x01000000
+#define FMAN_RTC_TMR_TEVENT_ALM2                 0x00020000
+#define FMAN_RTC_TMR_TEVENT_ALM1                 0x00010000
+#define FMAN_RTC_TMR_TEVENT_PP1                  0x00000080
+#define FMAN_RTC_TMR_TEVENT_PP2                  0x00000040
+#define FMAN_RTC_TMR_TEVENT_PP3                  0x00000020
+#define FMAN_RTC_TMR_TEVENT_ALL                  (FMAN_RTC_TMR_TEVENT_ETS2 |\
+						FMAN_RTC_TMR_TEVENT_ETS1 |\
+						FMAN_RTC_TMR_TEVENT_ALM2 |\
+						FMAN_RTC_TMR_TEVENT_ALM1 |\
+						FMAN_RTC_TMR_TEVENT_PP1 |\
+						FMAN_RTC_TMR_TEVENT_PP2 |\
+						FMAN_RTC_TMR_TEVENT_PP3)
+
+#define FMAN_RTC_TMR_PRSC_OCK_MASK               0x0000FFFF
+
+/* FM RTC Alarm Polarity Options. */
+enum fman_rtc_alarm_polarity {
+	FMAN_RTC_ALARM_POLARITY_ACTIVE_HIGH,
+					    /* Active-high output polarity */
+	FMAN_RTC_ALARM_POLARITY_ACTIVE_LOW/* Active-low output polarity */
+};
+
+/* FM RTC Trigger Polarity Options. */
+enum fman_rtc_trigger_polarity {
+	FMAN_RTC_TRIGGER_ON_RISING_EDGE,/* Trigger on rising edge */
+	FMAN_RTC_TRIGGER_ON_FALLING_EDGE/* Trigger on falling edge */
+};
+
+/* IEEE1588 Timer Module FM RTC Optional Clock Sources. */
+enum fman_src_clock {
+	FMAN_RTC_SOURCE_CLOCK_EXTERNAL,
+				       /* external high precision timer
+					* reference clock
+					*/
+	FMAN_RTC_SOURCE_CLOCK_SYSTEM,/* MAC system clock */
+	FMAN_RTC_SOURCE_CLOCK_OSCILATOR
+				       /* RTC clock oscilator */
+};
+
+/* RTC default values */
+#define DEFAULT_SRC_CLOCK                FMAN_RTC_SOURCE_CLOCK_SYSTEM
+#define DEFAULT_INVERT_INPUT_CLK_PHASE   false
+#define DEFAULT_INVERT_OUTPUT_CLK_PHASE  false
+#define DEFAULT_ALARM_POLARITY           FMAN_RTC_ALARM_POLARITY_ACTIVE_HIGH
+#define DEFAULT_TRIGGER_POLARITY         FMAN_RTC_TRIGGER_ON_FALLING_EDGE
+#define DEFAULT_PULSE_REALIGN            false
+
+#define FMAN_RTC_MAX_NUM_OF_ALARMS 3
+#define FMAN_RTC_MAX_NUM_OF_PERIODIC_PULSES 4
+#define FMAN_RTC_MAX_NUM_OF_EXT_TRIGGERS 3
+
+/*  FM RTC timer alarm */
+struct tmr_alarm_t {
+	uint32_t tmr_alarm_h;  /*  */
+	uint32_t tmr_alarm_l;  /*  */
+};
+
+/* FM RTC timer Ex trigger */
+struct tmr_ext_trigger_t {
+	uint32_t tmr_etts_h;   /*  */
+	uint32_t tmr_etts_l;   /*  */
+};
+
+struct rtc_regs {
+	uint32_t tmr_id;	/* 0x000 Module ID register */
+	uint32_t tmr_id2;	/* 0x004 Controller ID register */
+	uint32_t reserved0008[30];
+	uint32_t tmr_ctrl;	/* 0x0080 timer control register */
+	uint32_t tmr_tevent;	/* 0x0084 timer event register */
+	uint32_t tmr_temask;	/* 0x0088 timer event mask register */
+	uint32_t reserved008c[3];
+	uint32_t tmr_cnt_h;	/* 0x0098 timer counter high register */
+	uint32_t tmr_cnt_l;	/* 0x009c timer counter low register */
+	/* 0x00a0 timer drift compensation addend register */
+	uint32_t tmr_add;
+	uint32_t tmr_acc;	/* 0x00a4 timer accumulator register */
+	uint32_t tmr_prsc;	/* 0x00a8 timer prescale */
+	uint32_t reserved00ac;
+	uint32_t tmr_off_h;	/* 0x00b0 timer offset high */
+	uint32_t tmr_off_l;	/* 0x00b4 timer offset low  */
+	/* 0x00b8 timer alarm */
+	struct tmr_alarm_t tmr_alarm[FMAN_RTC_MAX_NUM_OF_ALARMS];
+	/* 0x00d0 timer fixed period interval */
+	uint32_t tmr_fiper[FMAN_RTC_MAX_NUM_OF_PERIODIC_PULSES];
+	struct tmr_ext_trigger_t tmr_etts[FMAN_RTC_MAX_NUM_OF_EXT_TRIGGERS];
+	/* 0x00e0 time stamp general purpose external */
+	uint32_t reserved00f0[4];
+};
+
+struct rtc_cfg {
+	enum fman_src_clock src_clk;
+	uint32_t ext_src_clk_freq;
+	uint32_t rtc_freq_hz;
+	bool timer_slave_mode;
+	bool invert_input_clk_phase;
+	bool invert_output_clk_phase;
+	uint32_t events_mask;
+	bool bypass;		    /* Indicates if frequency compensation
+				     * is bypassed
+				     */
+	bool pulse_realign;
+	enum fman_rtc_alarm_polarity alarm_polarity[FMAN_RTC_MAX_NUM_OF_ALARMS];
+	enum fman_rtc_trigger_polarity trigger_polarity
+	    [FMAN_RTC_MAX_NUM_OF_EXT_TRIGGERS];
+};
+
+/* fman_rtc_defconfig() - Get default RTC configuration
+ * cfg:	pointer to configuration structure.
+ * Call this function to obtain a default set of configuration values for
+ * initializing RTC.  The user can overwrite any of the values before calling
+ * fman_rtc_init(), if specific configuration needs to be applied.
+ */
+void fman_rtc_defconfig(struct rtc_cfg *cfg);
+
+/* fman_rtc_get_events() - Get the events
+ * regs:		Pointer to RTC register block
+ * Returns: The events
+ */
+uint32_t fman_rtc_get_events(struct rtc_regs __iomem *regs);
+
+/* fman_rtc_get_interrupt_mask() - Get the events mask
+ * regs:		Pointer to RTC register block
+ * Returns: The events mask
+ */
+uint32_t fman_rtc_get_interrupt_mask(struct rtc_regs __iomem *regs);
+
+/* fman_rtc_set_interrupt_mask() - Set the events mask
+ * regs:		Pointer to RTC register block
+ * mask:		The mask to set
+ */
+void fman_rtc_set_interrupt_mask(struct rtc_regs __iomem *regs, uint32_t mask);
+
+/* fman_rtc_get_event() - Check if specific events occurred
+ * regs:		Pointer to RTC register block
+ * ev_mask:	a mask of the events to check
+ * Returns: 0 if the events did not occur.
+ * Non zero if one of the events occurred
+ */
+uint32_t fman_rtc_get_event(struct rtc_regs __iomem *regs, uint32_t ev_mask);
+
+/* fman_rtc_check_and_clear_event() - Clear events which are on
+ * regs:		Pointer to RTC register block
+ * Returns: A mask of the events which were cleared
+ */
+uint32_t fman_rtc_check_and_clear_event(struct rtc_regs __iomem *regs);
+
+/* fman_rtc_ack_event() - Clear events
+ * regs:		Pointer to RTC register block
+ * events:		The events to disable
+ */
+void fman_rtc_ack_event(struct rtc_regs __iomem *regs, uint32_t events);
+
+/* fman_rtc_enable_interrupt() - Enable events interrupts
+ * regs:		Pointer to RTC register block
+ * mask:		The events to disable
+ */
+void fman_rtc_enable_interrupt(struct rtc_regs __iomem *regs, uint32_t mask);
+
+/* fman_rtc_disable_interrupt() - Disable events interrupts
+ * regs:		Pointer to RTC register block
+ * mask:		The events to disable
+ */
+void fman_rtc_disable_interrupt(struct rtc_regs __iomem *regs, uint32_t mask);
+
+/* fman_rtc_get_timer_ctrl() - Get the control register
+ * regs:		Pointer to RTC register block
+ * Returns: The control register value
+ */
+uint32_t fman_rtc_get_timer_ctrl(struct rtc_regs __iomem *regs);
+
+/* fman_rtc_set_timer_ctrl() - Set timer control register
+ * regs:		Pointer to RTC register block
+ * val:		The value to set
+ */
+void fman_rtc_set_timer_ctrl(struct rtc_regs __iomem *regs, uint32_t val);
+
+/* fman_rtc_get_frequency_compensation() - Get the frequency compensation
+ * regs:		Pointer to RTC register block
+ *
+ * Returns: The timer counter
+ */
+uint32_t fman_rtc_get_frequency_compensation(struct rtc_regs __iomem *regs);
+
+/* fman_rtc_set_frequency_compensation() - Set frequency compensation
+ * regs:		Pointer to RTC register block
+ * val:		The value to set
+ */
+void fman_rtc_set_frequency_compensation(struct rtc_regs __iomem *regs,
+					 uint32_t val);
+
+/* fman_rtc_get_trigger_stamp() - Get a trigger stamp
+ * regs:		Pointer to RTC register block
+ * id:	The id of the trigger stamp
+ *
+ * Returns: The time stamp
+ */
+uint64_t fman_rtc_get_trigger_stamp(struct rtc_regs __iomem *regs, int id);
+
+/* fman_rtc_set_timer_alarm_l() - Set timer alarm low register
+ * regs:		Pointer to RTC register block
+ * index:		The index of alarm to set
+ * val:		The value to set
+ */
+void fman_rtc_set_timer_alarm_l(struct rtc_regs __iomem *regs, int index,
+				uint32_t val);
+
+/* fman_rtc_set_timer_alarm() - Set timer alarm
+ * regs:		Pointer to RTC register block
+ * index:		The index of alarm to set
+ * val:		The value to set
+ */
+void fman_rtc_set_timer_alarm(struct rtc_regs __iomem *regs, int index,
+			      int64_t val);
+
+/* fman_rtc_set_timer_fiper() - Set timer fiper
+ * regs:		Pointer to RTC register block
+ * index:		The index of fiper to set
+ * val:		The value to set
+ */
+void fman_rtc_set_timer_fiper(struct rtc_regs __iomem *regs, int index,
+			      uint32_t val);
+
+/* fman_rtc_set_timer_offset() - Set timer offset
+ * regs:		Pointer to RTC register block
+ * val:		The value to set
+ */
+void fman_rtc_set_timer_offset(struct rtc_regs __iomem *regs, int64_t val);
+
+/* fman_rtc_get_timer() - Get the timer counter
+ * regs:		Pointer to RTC register block
+ * Returns: The timer counter
+ */
+static inline uint64_t fman_rtc_get_timer(struct rtc_regs __iomem *regs)
+{
+	uint64_t time;
+	/* TMR_CNT_L must be read first to get an accurate value */
+	time = (uint64_t)ioread32be(&regs->tmr_cnt_l);
+	time |= ((uint64_t)ioread32be(&regs->tmr_cnt_h) << 32);
+
+	return time;
+}
+
+/* fman_rtc_set_timer() - Set timer counter
+ * regs:		Pointer to RTC register block
+ * val:		The value to set
+ */
+static inline void fman_rtc_set_timer(struct rtc_regs __iomem *regs,
+				      int64_t val)
+{
+	iowrite32be((uint32_t)val, &regs->tmr_cnt_l);
+	iowrite32be((uint32_t)(val >> 32), &regs->tmr_cnt_h);
+}
+
+/* fman_rtc_timers_soft_reset() - Soft reset
+ * regs:		Pointer to RTC register block
+ * Resets all the timer registers and state machines for the 1588 IP and
+ * the attached client 1588
+ */
+void fman_rtc_timers_soft_reset(struct rtc_regs __iomem *regs);
+
+/* fman_rtc_clear_external_trigger() - Clear an external trigger
+ * regs:		Pointer to RTC register block
+ * id: The id of the trigger to clear
+ */
+void fman_rtc_clear_external_trigger(struct rtc_regs __iomem *regs, int id);
+
+/* fman_rtc_clear_periodic_pulse() - Clear periodic pulse
+ * regs:		Pointer to RTC register block
+ * id: The id of the fiper to clear
+ */
+void fman_rtc_clear_periodic_pulse(struct rtc_regs __iomem *regs, int id);
+
+/* fman_rtc_enable() - Enable RTC hardware block
+ * regs:		Pointer to RTC register block
+ */
+void fman_rtc_enable(struct rtc_regs __iomem *regs, bool reset_clock);
+
+/* fman_rtc_is_enabled() - Is RTC hardware block enabled
+ * regs:		Pointer to RTC register block
+ * Return: true if enabled
+ */
+bool fman_rtc_is_enabled(struct rtc_regs __iomem *regs);
+
+/* fman_rtc_disable() - Disable RTC hardware block
+ * regs:		Pointer to RTC register block
+ */
+void fman_rtc_disable(struct rtc_regs __iomem *regs);
+
+/* fman_rtc_init() - Init RTC hardware block
+ * cfg:		RTC configuration data
+ * regs:		Pointer to RTC register block
+ * num_alarms:		Number of alarms in RTC
+ * num_fipers:		Number of fipers in RTC
+ * num_ext_triggers:	Number of external triggers in RTC
+ * freq_compensation:		Frequency compensation
+ * output_clock_divisor:		Output clock divisor
+ * This function initializes RTC and applies basic configuration.
+ */
+void fman_rtc_init(struct rtc_cfg *cfg, struct rtc_regs __iomem *regs,
+		   int num_alarms, int num_fipers, int num_ext_triggers,
+		   bool init_freq_comp, uint32_t freq_compensation,
+		   uint32_t output_clock_divisor);
+
+/* fman_rtc_set_alarm() - Set an alarm
+ * regs:		Pointer to RTC register block
+ * id:			id of alarm
+ * val:		value to write
+ * enable:		should interrupt be enabled
+ */
+void fman_rtc_set_alarm(struct rtc_regs __iomem *regs, int id, uint32_t val,
+			bool enable);
+
+/* fman_rtc_set_periodic_pulse() - Set an alarm
+ * regs:		Pointer to RTC register block
+ * id:			id of fiper
+ * val:		value to write
+ * enable:		should interrupt be enabled
+ */
+void fman_rtc_set_periodic_pulse(struct rtc_regs __iomem *regs, int id,
+				 uint32_t val, bool enable);
+
+/* fman_rtc_set_ext_trigger() - Set an external trigger
+ * regs:		Pointer to RTC register block
+ * id:			id of trigger
+ * enable:		should interrupt be enabled
+ * use_pulse_as_input: use the pulse as input
+ */
+void fman_rtc_set_ext_trigger(struct rtc_regs __iomem *regs, int id,
+			      bool enable, bool use_pulse_as_input);
+
+struct fm_rtc_alarm_params {
+	uint8_t alarm_id;		/* 0 or 1 */
+	uint64_t alarm_time;		/* In nanoseconds, the time when the
+					 * alarm should go off - must be a
+					 * multiple of the RTC period
+					 */
+	void (*f_alarm_callback)(void *app, uint8_t id);/* This routine will
+							 * be called when RTC
+							 * reaches alarm_time
+							 */
+	bool clear_on_expiration;	/* true to turn off the alarm once
+					 * expired.
+					 */
+};
+
+struct fm_rtc_periodic_pulse_params {
+	uint8_t periodic_pulse_id;	/* 0 or 1 */
+	uint64_t periodic_pulse_period;	/* In Nanoseconds. Must be a multiple
+					 * of the RTC period
+					 */
+	/* This routine will be called every periodic_pulse_period. */
+	void (*f_periodic_pulse_callback)(void *app, uint8_t id);
+};
+
+#endif /* __FSL_FMAN_RTC_H */
diff --git a/drivers/soc/fsl/fman/flib/fsl_fman_sp.h b/drivers/soc/fsl/fman/flib/fsl_fman_sp.h
new file mode 100644
index 0000000..e3e6888
--- /dev/null
+++ b/drivers/soc/fsl/fman/flib/fsl_fman_sp.h
@@ -0,0 +1,133 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __FSL_FMAN_SP_H
+#define __FSL_FMAN_SP_H
+
+#include "common/general.h"
+#include "fsl_fman.h"
+
+struct fm_pcd_storage_profile_regs {
+	uint32_t fm_sp_ebmpi[8];
+	/*offset 0 - 0xc */
+					/* Buffer Manager pool Information */
+
+	uint32_t fm_sp_acnt;	/*offset 0x20 */
+	uint32_t fm_sp_ebm;	/*offset 0x24 */
+	uint32_t fm_sp_da;	/*offset 0x28 */
+	uint32_t fm_sp_icp;	/*offset 0x2c */
+	uint32_t fm_sp_mpd;	/*offset 0x30 */
+	uint32_t res1[2];	/*offset 0x34 - 0x38 */
+	uint32_t fm_sp_spliodn;	/*offset 0x3c */
+};
+
+/* structure for defining internal context copying */
+struct fman_sp_int_context_data_copy {
+	uint16_t ext_buf_offset;     /* Offset in External buffer to which
+				      * internal context is copied to (Rx)
+				      * or taken from (Tx, Op).
+				      */
+	uint8_t int_context_offset; /* Offset within internal context to copy
+				     * from (Rx) or to copy to (Tx, Op).
+				     */
+	uint16_t size;		   /* Internal offset size to be copied */
+};
+
+/*struct for defining external buffer margins */
+struct fman_sp_buf_margins {
+	uint16_t start_margins;	/* Number of bytes to be left at the
+				 * beginning of the external buffer (must be
+				 * divisible by 16)
+				 */
+	uint16_t end_margins;	/* number of bytes to be left at the end of
+				 * the external buffer(must be divisible by 16)
+				 */
+};
+
+struct fm_storage_profile_params {
+	struct fman_ext_pools fm_ext_pools;
+	struct fman_backup_bm_pools backup_pools;
+	struct fman_sp_int_context_data_copy *int_context;
+	struct fman_sp_buf_margins *buf_margins;
+	enum fman_dma_swap_option dma_swap_data;
+	enum fman_dma_cache_option int_context_cache_attr;
+	enum fman_dma_cache_option header_cache_attr;
+	enum fman_dma_cache_option scatter_gather_cache_attr;
+	bool dma_write_optimize;
+	uint16_t liodn_offset;
+	bool no_scather_gather;
+	struct fman_buf_pool_depletion buf_pool_depletion;
+};
+
+/* Registers bit fields */
+#define FMAN_SP_EXT_BUF_POOL_EN_COUNTER             0x40000000
+#define FMAN_SP_EXT_BUF_POOL_VALID                  0x80000000
+#define FMAN_SP_EXT_BUF_POOL_BACKUP                 0x20000000
+#define FMAN_SP_DMA_ATTR_WRITE_OPTIMIZE             0x00100000
+#define FMAN_SP_SG_DISABLE                          0x80000000
+
+/* shifts */
+#define FMAN_SP_EXT_BUF_POOL_ID_SHIFT               16
+#define FMAN_SP_POOL_DEP_NUM_OF_POOLS_SHIFT         16
+#define FMAN_SP_EXT_BUF_MARG_START_SHIFT            16
+#define FMAN_SP_EXT_BUF_MARG_END_SHIFT              0
+#define FMAN_SP_DMA_ATTR_SWP_SHIFT                  30
+#define FMAN_SP_DMA_ATTR_IC_CACHE_SHIFT             28
+#define FMAN_SP_DMA_ATTR_HDR_CACHE_SHIFT            26
+#define FMAN_SP_DMA_ATTR_SG_CACHE_SHIFT             24
+#define FMAN_SP_IC_TO_EXT_SHIFT                     16
+#define FMAN_SP_IC_FROM_INT_SHIFT                   8
+#define FMAN_SP_IC_SIZE_SHIFT                       0
+
+/* defaults */
+#define DEFAULT_FMAN_SP_DMA_SWAP_DATA                         FMAN_DMA_NO_SWP
+#define DEFAULT_FMAN_SP_DMA_INT_CONTEXT_CACHE_ATTR            FMAN_DMA_NO_STASH
+#define DEFAULT_FMAN_SP_DMA_HEADER_CACHE_ATTR                 FMAN_DMA_NO_STASH
+#define DEFAULT_FMAN_SP_DMA_SCATTER_GATHER_CACHE_ATTR         FMAN_DMA_NO_STASH
+#define DEFAULT_FMAN_SP_DMA_WRITE_OPTIMIZE                    true
+#define DEFAULT_FMAN_SP_NO_SCATTER_GATHER                     false
+
+void fman_vsp_defconfig(struct fm_storage_profile_params *cfg);
+
+void fman_vsp_init(struct fm_pcd_storage_profile_regs *regs,
+		   uint16_t index,
+		   struct fm_storage_profile_params *fm_vsp_params,
+		   int port_max_num_of_ext_pools, int bm_max_num_of_pools,
+		   int max_num_of_pfc_priorities);
+
+uint32_t fman_vsp_get_statistics(struct fm_pcd_storage_profile_regs *regs,
+				 uint16_t index);
+
+void fman_vsp_set_statistics(struct fm_pcd_storage_profile_regs *regs,
+			     uint16_t index, uint32_t value);
+
+#endif /* __FSL_FMAN_SP_H */
diff --git a/drivers/soc/fsl/fman/flib/fsl_fman_tgec.h b/drivers/soc/fsl/fman/flib/fsl_fman_tgec.h
new file mode 100644
index 0000000..e7b3c4f
--- /dev/null
+++ b/drivers/soc/fsl/fman/flib/fsl_fman_tgec.h
@@ -0,0 +1,484 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __FSL_FMAN_TGEC_H
+#define __FSL_FMAN_TGEC_H
+
+#include "common/general.h"
+#include "fsl_enet.h"
+
+/* Transmit Inter-Packet Gap Length Register (TX_IPG_LENGTH) */
+#define TGEC_TX_IPG_LENGTH_MASK	0x000003ff
+
+enum tgec_counters {
+	E_TGEC_COUNTER_R64,
+	E_TGEC_COUNTER_R127,
+	E_TGEC_COUNTER_R255,
+	E_TGEC_COUNTER_R511,
+	E_TGEC_COUNTER_R1023,
+	E_TGEC_COUNTER_R1518,
+	E_TGEC_COUNTER_R1519X,
+	E_TGEC_COUNTER_TRFRG,
+	E_TGEC_COUNTER_TRJBR,
+	E_TGEC_COUNTER_RDRP,
+	E_TGEC_COUNTER_RALN,
+	E_TGEC_COUNTER_TRUND,
+	E_TGEC_COUNTER_TROVR,
+	E_TGEC_COUNTER_RXPF,
+	E_TGEC_COUNTER_TXPF,
+	E_TGEC_COUNTER_ROCT,
+	E_TGEC_COUNTER_RMCA,
+	E_TGEC_COUNTER_RBCA,
+	E_TGEC_COUNTER_RPKT,
+	E_TGEC_COUNTER_RUCA,
+	E_TGEC_COUNTER_RERR,
+	E_TGEC_COUNTER_TOCT,
+	E_TGEC_COUNTER_TMCA,
+	E_TGEC_COUNTER_TBCA,
+	E_TGEC_COUNTER_TUCA,
+	E_TGEC_COUNTER_TERR
+};
+
+/* Command and Configuration Register (COMMAND_CONFIG) */
+#define CMD_CFG_EN_TIMESTAMP	0x00100000
+#define CMD_CFG_TX_ADDR_INS_SEL	0x00080000
+#define CMD_CFG_NO_LEN_CHK	0x00020000
+#define CMD_CFG_SEND_IDLE	0x00010000
+#define CMD_CFG_RX_ER_DISC	0x00004000
+#define CMD_CFG_CMD_FRM_EN	0x00002000
+#define CMD_CFG_STAT_CLR	0x00001000
+#define CMD_CFG_LOOPBACK_EN	0x00000400
+#define CMD_CFG_TX_ADDR_INS	0x00000200
+#define CMD_CFG_PAUSE_IGNORE	0x00000100
+#define CMD_CFG_PAUSE_FWD	0x00000080
+#define CMD_CFG_PROMIS_EN	0x00000010
+#define CMD_CFG_WAN_MODE	0x00000008
+#define CMD_CFG_RX_EN		0x00000002
+#define CMD_CFG_TX_EN		0x00000001
+
+/* Interrupt Mask Register (IMASK) */
+#define TGEC_IMASK_MDIO_SCAN_EVENT	0x00010000
+#define TGEC_IMASK_MDIO_CMD_CMPL	0x00008000
+#define TGEC_IMASK_REM_FAULT		0x00004000
+#define TGEC_IMASK_LOC_FAULT		0x00002000
+#define TGEC_IMASK_TX_ECC_ER		0x00001000
+#define TGEC_IMASK_TX_FIFO_UNFL		0x00000800
+#define TGEC_IMASK_TX_FIFO_OVFL		0x00000400
+#define TGEC_IMASK_TX_ER			0x00000200
+#define TGEC_IMASK_RX_FIFO_OVFL		0x00000100
+#define TGEC_IMASK_RX_ECC_ER		0x00000080
+#define TGEC_IMASK_RX_JAB_FRM		0x00000040
+#define TGEC_IMASK_RX_OVRSZ_FRM		0x00000020
+#define TGEC_IMASK_RX_RUNT_FRM		0x00000010
+#define TGEC_IMASK_RX_FRAG_FRM		0x00000008
+#define TGEC_IMASK_RX_LEN_ER		0x00000004
+#define TGEC_IMASK_RX_CRC_ER		0x00000002
+#define TGEC_IMASK_RX_ALIGN_ER		0x00000001
+
+#define TGEC_EVENTS_MASK					\
+	((uint32_t)(TGEC_IMASK_MDIO_SCAN_EVENT			| \
+				TGEC_IMASK_MDIO_CMD_CMPL	| \
+				TGEC_IMASK_REM_FAULT		| \
+				TGEC_IMASK_LOC_FAULT		| \
+				TGEC_IMASK_TX_ECC_ER		| \
+				TGEC_IMASK_TX_FIFO_UNFL		| \
+				TGEC_IMASK_TX_FIFO_OVFL		| \
+				TGEC_IMASK_TX_ER		| \
+				TGEC_IMASK_RX_FIFO_OVFL		| \
+				TGEC_IMASK_RX_ECC_ER		| \
+				TGEC_IMASK_RX_JAB_FRM		| \
+				TGEC_IMASK_RX_OVRSZ_FRM		| \
+				TGEC_IMASK_RX_RUNT_FRM		| \
+				TGEC_IMASK_RX_FRAG_FRM		| \
+				TGEC_IMASK_RX_LEN_ER		| \
+				TGEC_IMASK_RX_CRC_ER		| \
+				TGEC_IMASK_RX_ALIGN_ER))
+
+/* Hashtable Control Register (HASHTABLE_CTRL) */
+#define TGEC_HASH_MCAST_SHIFT	23
+#define TGEC_HASH_MCAST_EN	0x00000200
+#define TGEC_HASH_ADR_MSK	0x000001ff
+
+#define DEFAULT_WAN_MODE_ENABLE		false
+#define DEFAULT_PROMISCUOUS_MODE_ENABLE	false
+#define DEFAULT_PAUSE_FORWARD_ENABLE	false
+#define DEFAULT_PAUSE_IGNORE		false
+#define DEFAULT_TX_ADDR_INS_ENABLE	false
+#define DEFAULT_LOOPBACK_ENABLE		false
+#define DEFAULT_CMD_FRAME_ENABLE	false
+#define DEFAULT_RX_ERROR_DISCARD	false
+#define DEFAULT_SEND_IDLE_ENABLE	false
+#define DEFAULT_NO_LENGTH_CHECK_ENABLE	true
+#define DEFAULT_LGTH_CHECK_NOSTDR	false
+#define DEFAULT_TIME_STAMP_ENABLE	false
+#define DEFAULT_TX_IPG_LENGTH		12
+#define DEFAULT_MAX_FRAME_LENGTH	0x600
+#define DEFAULT_PAUSE_QUANT		0xf000
+
+/**
+ * 10G memory map
+ **/
+struct tgec_regs {
+	uint32_t tgec_id;	/* 0x000 Controller ID */
+	uint32_t reserved001[1];	/* 0x004 */
+	uint32_t command_config;	/* 0x008 Control and configuration */
+	uint32_t mac_addr_0;	/* 0x00c Lower 32 bits of the MAC adr */
+	uint32_t mac_addr_1;	/* 0x010 Upper 16 bits of the MAC adr */
+	uint32_t maxfrm;	/* 0x014 Maximum frame length */
+	uint32_t pause_quant;	/* 0x018 Pause quanta */
+	uint32_t rx_fifo_sections;	/* 0x01c  */
+	uint32_t tx_fifo_sections;	/* 0x020  */
+	uint32_t rx_fifo_almost_f_e;	/* 0x024  */
+	uint32_t tx_fifo_almost_f_e;	/* 0x028  */
+	uint32_t hashtable_ctrl;	/* 0x02c Hash table control */
+	uint32_t mdio_cfg_status;	/* 0x030  */
+	uint32_t mdio_command;	/* 0x034  */
+	uint32_t mdio_data;	/* 0x038  */
+	uint32_t mdio_regaddr;	/* 0x03c  */
+	uint32_t status;	/* 0x040  */
+	uint32_t tx_ipg_len;	/* 0x044 Transmitter inter-packet-gap */
+	uint32_t mac_addr_2;	/* 0x048 Lower 32 bits of 2nd MAC adr */
+	uint32_t mac_addr_3;	/* 0x04c Upper 16 bits of 2nd MAC adr */
+	uint32_t rx_fifo_ptr_rd;	/* 0x050  */
+	uint32_t rx_fifo_ptr_wr;	/* 0x054  */
+	uint32_t tx_fifo_ptr_rd;	/* 0x058  */
+	uint32_t tx_fifo_ptr_wr;	/* 0x05c  */
+	uint32_t imask;		/* 0x060 Interrupt mask */
+	uint32_t ievent;	/* 0x064 Interrupt event */
+	uint32_t udp_port;	/* 0x068 Defines a UDP Port number */
+	uint32_t type_1588v2;	/* 0x06c Type field for 1588v2 */
+	uint32_t reserved070[4];	/* 0x070 */
+	/*10Ge Statistics Counter */
+	uint32_t tfrm_u;	/* 80 aFramesTransmittedOK */
+	uint32_t tfrm_l;	/* 84 aFramesTransmittedOK */
+	uint32_t rfrm_u;	/* 88 aFramesReceivedOK */
+	uint32_t rfrm_l;	/* 8c aFramesReceivedOK */
+	uint32_t rfcs_u;	/* 90 aFrameCheckSequenceErrors */
+	uint32_t rfcs_l;	/* 94 aFrameCheckSequenceErrors */
+	uint32_t raln_u;	/* 98 aAlignmentErrors */
+	uint32_t raln_l;	/* 9c aAlignmentErrors */
+	uint32_t txpf_u;	/* A0 aPAUSEMACCtrlFramesTransmitted */
+	uint32_t txpf_l;	/* A4 aPAUSEMACCtrlFramesTransmitted */
+	uint32_t rxpf_u;	/* A8 aPAUSEMACCtrlFramesReceived */
+	uint32_t rxpf_l;	/* Ac aPAUSEMACCtrlFramesReceived */
+	uint32_t rlong_u;	/* B0 aFrameTooLongErrors */
+	uint32_t rlong_l;	/* B4 aFrameTooLongErrors */
+	uint32_t rflr_u;	/* B8 aInRangeLengthErrors */
+	uint32_t rflr_l;	/* Bc aInRangeLengthErrors */
+	uint32_t tvlan_u;	/* C0 VLANTransmittedOK */
+	uint32_t tvlan_l;	/* C4 VLANTransmittedOK */
+	uint32_t rvlan_u;	/* C8 VLANReceivedOK */
+	uint32_t rvlan_l;	/* Cc VLANReceivedOK */
+	uint32_t toct_u;	/* D0 if_out_octets */
+	uint32_t toct_l;	/* D4 if_out_octets */
+	uint32_t roct_u;	/* D8 if_in_octets */
+	uint32_t roct_l;	/* Dc if_in_octets */
+	uint32_t ruca_u;	/* E0 if_in_ucast_pkts */
+	uint32_t ruca_l;	/* E4 if_in_ucast_pkts */
+	uint32_t rmca_u;	/* E8 ifInMulticastPkts */
+	uint32_t rmca_l;	/* Ec ifInMulticastPkts */
+	uint32_t rbca_u;	/* F0 ifInBroadcastPkts */
+	uint32_t rbca_l;	/* F4 ifInBroadcastPkts */
+	uint32_t terr_u;	/* F8 if_out_errors */
+	uint32_t terr_l;	/* Fc if_out_errors */
+	uint32_t reserved100[2];	/* 100-108 */
+	uint32_t tuca_u;	/* 108 if_out_ucast_pkts */
+	uint32_t tuca_l;	/* 10c if_out_ucast_pkts */
+	uint32_t tmca_u;	/* 110 ifOutMulticastPkts */
+	uint32_t tmca_l;	/* 114 ifOutMulticastPkts */
+	uint32_t tbca_u;	/* 118 ifOutBroadcastPkts */
+	uint32_t tbca_l;	/* 11c ifOutBroadcastPkts */
+	uint32_t rdrp_u;	/* 120 etherStatsDropEvents */
+	uint32_t rdrp_l;	/* 124 etherStatsDropEvents */
+	uint32_t reoct_u;	/* 128 etherStatsOctets */
+	uint32_t reoct_l;	/* 12c etherStatsOctets */
+	uint32_t rpkt_u;	/* 130 etherStatsPkts */
+	uint32_t rpkt_l;	/* 134 etherStatsPkts */
+	uint32_t trund_u;	/* 138 etherStatsUndersizePkts */
+	uint32_t trund_l;	/* 13c etherStatsUndersizePkts */
+	uint32_t r64_u;		/* 140 etherStatsPkts64Octets */
+	uint32_t r64_l;		/* 144 etherStatsPkts64Octets */
+	uint32_t r127_u;	/* 148 etherStatsPkts65to127Octets */
+	uint32_t r127_l;	/* 14c etherStatsPkts65to127Octets */
+	uint32_t r255_u;	/* 150 etherStatsPkts128to255Octets */
+	uint32_t r255_l;	/* 154 etherStatsPkts128to255Octets */
+	uint32_t r511_u;	/* 158 etherStatsPkts256to511Octets */
+	uint32_t r511_l;	/* 15c etherStatsPkts256to511Octets */
+	uint32_t r1023_u;	/* 160 etherStatsPkts512to1023Octets */
+	uint32_t r1023_l;	/* 164 etherStatsPkts512to1023Octets */
+	uint32_t r1518_u;	/* 168 etherStatsPkts1024to1518Octets */
+	uint32_t r1518_l;	/* 16c etherStatsPkts1024to1518Octets */
+	uint32_t r1519x_u;	/* 170 etherStatsPkts1519toX */
+	uint32_t r1519x_l;	/* 174 etherStatsPkts1519toX */
+	uint32_t trovr_u;	/* 178 etherStatsOversizePkts */
+	uint32_t trovr_l;	/* 17c etherStatsOversizePkts */
+	uint32_t trjbr_u;	/* 180 etherStatsJabbers */
+	uint32_t trjbr_l;	/* 184 etherStatsJabbers */
+	uint32_t trfrg_u;	/* 188 etherStatsFragments */
+	uint32_t trfrg_l;	/* 18C etherStatsFragments */
+	uint32_t rerr_u;	/* 190 if_in_errors */
+	uint32_t rerr_l;	/* 194 if_in_errors */
+};
+
+/**
+*struct tgec_cfg - TGEC configuration
+ *
+*@rx_error_discard:    Receive Erroneous Frame Discard Enable. When set to 1
+*           any frame received with an error is discarded in the
+*           Core and not forwarded to the Client interface.
+*           When set to 0 (Reset value), erroneous Frames are
+*           forwarded to the Client interface with ff_rx_err
+*           asserted.
+*@pause_ignore:    Ignore Pause Frame Quanta. If set to 1 received pause
+*           frames are ignored by the MAC. When set to 0
+*           (Reset value) the transmit process is stopped for the
+*           amount of time specified in the pause quanta received
+*           within a pause frame.
+*@pause_forward_enable:
+*           Terminate / Forward Pause Frames. If set to 1 pause
+*           frames are forwarded to the user application. When set
+*           to 0 (Reset value) pause frames are terminated and
+*           discarded within the MAC.
+*@no_length_check_enable:
+*           Payload Length Check Disable. When set to 0
+*           (Reset value), the Core checks the frame's payload
+*           length with the Frame Length/Type field, when set to 1
+*           the payload length check is disabled.
+*@cmd_frame_enable:    Enables reception of all command frames. When set to 1
+*           all Command Frames are accepted, when set to 0
+*           (Reset Value) only Pause Frames are accepted and all
+*           other Command Frames are rejected.
+*@send_idle_enable:    Force Idle Generation. When set to 1, the MAC
+*           permanently sends XGMII Idle sequences even when faults
+*           are received.
+*@wan_mode_enable:    WAN Mode Enable. Sets WAN mode (1) or LAN mode
+*           (0, default) of operation.
+*@promiscuous_mode_enable:
+*           Enables MAC promiscuous operation. When set to 1, all
+*           frames are received without any MAC address filtering,
+*           when set to 0 (Reset value) Unicast Frames with a
+*           destination address not matching the Core MAC Address
+*           (MAC Address programmed in Registers MAC_ADDR_0 and
+*           MAC_ADDR_1 or the MAC address programmed in Registers
+*           MAC_ADDR_2 and MAC_ADDR_3) are rejected.
+*@tx_addr_ins_enable:    Set Source MAC Address on Transmit. If set to 1 the
+*           MAC overwrites the source MAC address received from the
+*           Client Interface with one of the MAC addresses. If set
+*           to 0 (Reset value), the source MAC address from the
+*           Client Interface is transmitted unmodified to the line.
+*@loopback_enable:    PHY Interface Loopback. When set to 1, the signal
+*           loop_ena is set to '1', when set to 0 (Reset value)
+*           the signal loop_ena is set to 0.
+*@lgth_check_nostdr:    The Core interprets the Length/Type field differently
+*           depending on the value of this Bit
+*@time_stamp_enable:    This bit selects between enabling and disabling the
+*           IEEE 1588 functionality. 1: IEEE 1588 is enabled
+*           0: IEEE 1588 is disabled
+*@max_frame_length:    Maximum supported received frame length.
+*           The 10GEC MAC supports reception of any frame size up
+*           to 16,352 bytes (0x3FE0). Typical settings are
+*           0x05EE (1,518 bytes) for standard frames.
+*           Default setting is 0x0600 (1,536 bytes).
+*           Received frames that exceed this stated maximum
+*           are truncated.
+*@pause_quant:    Pause quanta value used with transmitted pause frames.
+*           Each quanta represents a 512 bit-times.
+*@tx_ipg_length:    Transmit Inter-Packet-Gap (IPG) value. A 6-bit value:
+*           Depending on LAN or WAN mode of operation the value has
+*           the following meaning: - LAN Mode: Number of octets in
+*           steps of 4. Valid values are 8, 12, 16, ... 100. DIC is
+*           fully supported (see 10.6.1 page 49) for any setting. A
+*           default of 12 (reset value) must be set to conform to
+*           IEEE802.3ae. Warning: When set to 8, PCS layers may not
+*           be able to perform clock rate compensation. - WAN Mode:
+*           Stretch factor. Valid values are 4..15. The stretch
+*           factor is calculated as (value+1)*8. A default of 12
+*           (reset value) must be set to conform to IEEE 802.3ae
+*           (i.e. 13*8=104). A larger value shrinks the IPG
+*           (increasing bandwidth).
+ *
+*This structure contains basic TGEC configuration and must be passed to
+*fman_tgec_init() function.  A default set of configuration values can be
+*obtained by calling fman_tgec_defconfig().
+ */
+struct tgec_cfg {
+	bool rx_error_discard;
+	bool pause_ignore;
+	bool pause_forward_enable;
+	bool no_length_check_enable;
+	bool cmd_frame_enable;
+	bool send_idle_enable;
+	bool wan_mode_enable;
+	bool promiscuous_mode_enable;
+	bool tx_addr_ins_enable;
+	bool loopback_enable;
+	bool lgth_check_nostdr;
+	bool time_stamp_enable;
+	uint16_t max_frame_length;
+	uint16_t pause_quant;
+	uint32_t tx_ipg_length;
+	bool skip_fman11_workaround;
+};
+
+void fman_tgec_defconfig(struct tgec_cfg *cfg);
+
+/**
+*fman_tgec_init() - Init tgec hardware block
+*@regs:        Pointer to tgec register block
+*@cfg:        tgec configuration data
+*@exceptions_mask:    initial exceptions mask
+ *
+*This function initializes the tgec controller and applies its
+*basic configuration.
+ *
+*Returns: 0 if successful, an error code otherwise.
+ */
+
+int fman_tgec_init(struct tgec_regs __iomem *regs, struct tgec_cfg *cfg,
+		   uint32_t exception_mask);
+
+void fman_tgec_enable(struct tgec_regs __iomem *regs, bool apply_rx,
+		      bool apply_tx);
+
+void fman_tgec_disable(struct tgec_regs __iomem *regs, bool apply_rx,
+		       bool apply_tx);
+
+uint32_t fman_tgec_get_revision(struct tgec_regs __iomem *regs);
+
+void fman_tgec_set_mac_address(struct tgec_regs __iomem *regs,
+			       uint8_t *macaddr);
+
+void fman_tgec_set_promiscuous(struct tgec_regs __iomem *regs, bool val);
+
+/**
+*fman_tgec_reset_stat() - Completely resets all TGEC HW counters
+*@regs:    Pointer to TGEC register block
+ */
+void fman_tgec_reset_stat(struct tgec_regs __iomem *regs);
+
+/**
+*fman_tgec_get_counter() - Reads TGEC HW counters
+*@regs:    Pointer to TGEC register block
+*@reg_name:    Counter name according to the appropriate enum
+ *
+*Returns:    Required counter value
+ */
+uint64_t fman_tgec_get_counter(struct tgec_regs __iomem *regs,
+			       enum tgec_counters reg_name);
+
+/**
+*fman_tgec_set_hash_table() - Sets the Hashtable Control Register
+*@regs:    Pointer to TGEC register block
+*@value:    Value to be written in Hashtable Control Register
+ */
+void fman_tgec_set_hash_table(struct tgec_regs __iomem *regs, uint32_t value);
+
+/**
+*fman_tgec_set_tx_pause_frames() - Sets the Pause Quanta Register
+*@regs:    Pointer to TGEC register block
+*@pause_time:    Pause quanta value used with transmitted pause frames.
+*       Each quanta represents a 512 bit-times
+ */
+void fman_tgec_set_tx_pause_frames(struct tgec_regs __iomem *regs,
+				   uint16_t pause_time);
+
+/**
+*fman_tgec_set_rx_ignore_pause_frames() - Changes the policy WRT pause frames
+*@regs:    Pointer to TGEC register block
+*@en:        Ignore/Respond to pause frame quanta
+ *
+*Sets the value of PAUSE_IGNORE field in the COMMAND_CONFIG Register
+*0 - MAC stops transmit process for the duration specified
+*in the Pause frame quanta of a received Pause frame.
+*1 - MAC ignores received Pause frames.
+ */
+void fman_tgec_set_rx_ignore_pause_frames(struct tgec_regs __iomem *regs,
+					  bool en);
+
+/**
+*fman_tgec_enable_1588_time_stamp() - change timestamp functionality
+*@regs:    Pointer to TGEC register block
+*@en:        enable/disable timestamp functionality
+ *
+*Sets the value of EN_TIMESTAMP field in the COMMAND_CONFIG Register
+*IEEE 1588 timestamp functionality control:
+*0 disabled, 1 enabled
+ */
+
+void fman_tgec_enable_1588_time_stamp(struct tgec_regs __iomem *regs, bool en);
+
+uint32_t fman_tgec_get_event(struct tgec_regs __iomem *regs, uint32_t ev_mask);
+
+void fman_tgec_ack_event(struct tgec_regs __iomem *regs, uint32_t ev_mask);
+
+uint32_t fman_tgec_get_interrupt_mask(struct tgec_regs __iomem *regs);
+
+/**
+*fman_tgec_add_addr_in_paddr() - Sets additional exact match MAC address
+*@regs:    Pointer to TGEC register block
+*@addr_ptr:    Pointer to 6-byte array containing the MAC address
+ *
+*Sets the additional station MAC address
+ */
+void fman_tgec_add_addr_in_paddr(struct tgec_regs __iomem *regs,
+				 uint8_t *addr_ptr);
+
+void fman_tgec_clear_addr_in_paddr(struct tgec_regs __iomem *regs);
+
+void fman_tgec_enable_interrupt(struct tgec_regs __iomem *regs,
+				uint32_t ev_mask);
+
+void fman_tgec_disable_interrupt(struct tgec_regs __iomem *regs,
+				 uint32_t ev_mask);
+
+void fman_tgec_reset_filter_table(struct tgec_regs __iomem *regs);
+
+void fman_tgec_set_hash_table_entry(struct tgec_regs __iomem *regs,
+				    uint32_t crc);
+
+/**
+*fman_tgec_get_max_frame_len() - Returns the maximum frame length value
+*@regs:    Pointer to TGEC register block
+ */
+uint16_t fman_tgec_get_max_frame_len(struct tgec_regs __iomem *regs);
+
+/**
+*fman_tgec_set_erratum_tx_fifo_corruption_10gmac_a007() - Initialize the
+*main tgec configuration parameters
+*@regs:    Pointer to TGEC register block
+ *
+*TODO
+ */
+void fman_tgec_set_erratum_tx_fifo_corruption_10gmac_a007(struct tgec_regs
+							  __iomem *regs);
+
+#endif /* __FSL_FMAN_TGEC_H */
-- 
2.3.1
