From: Kevin Curtis <Kevin.Curtis@farsite.com>
Subject: [PATCH 003/007] WAN Drivers: Update farsync driver and introduce
 fsflex driver
Date: Wed, 18 Sep 2013 11:12:02 +0100
Message-ID: <E603DC592C92B54A89CEF6B0919A0B1CAAAA787DA2@SOLO.hq.farsitecommunications.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	Dermot Smith <dermot.smith@farsite.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Language: en-US
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Farsite Communications FarSync driver update

Patch 3 of 7

Introduce a new include file required by the fsflex driver.

Signed-off-by: Kevin Curtis <kevin.curtis@farsite.com>

---

diff -uprN -X linux-3.10.1/Documentation/dontdiff linux-3.10.1/drivers/net/wan/fscmn.h linux-3.10.1_new/drivers/net/wan/fscmn.h
--- linux-3.10.1/drivers/net/wan/fscmn.h	1970-01-01 01:00:00.000000000 +0100
+++ linux-3.10.1_new/drivers/net/wan/fscmn.h	2013-09-16 16:30:06.779104868 +0100
@@ -0,0 +1,136 @@
+/*
+ *      FarSync driver for Linux
+ *
+ *      Copyright (C) 2001-2013 FarSite Communications Ltd.
+ *      www.farsite.com
+ *
+ *      This program is free software; you can redistribute it and/or
+ *      modify it under the terms of the GNU General Public License
+ *      as published by the Free Software Foundation; either version
+ *      2 of the License, or (at your option) any later version.
+ *
+ * File        : fscmn.h
+ *
+ * Description : Common FarSync Configuration Parameter Defines
+ *
+ */
+
+#ifndef INC_FSCMN
+#define INC_FSCMN
+
+#ifdef UINT32
+#define u32 UINT32
+#define u16 UINT16
+#define u8  UCHAR
+#endif
+
+#ifdef USSTYPES_H
+#define u32 U32
+#define u16 U16
+#define u8  U8
+#endif
+
+/* Interface defines */
+
+#define FSCMN_INTERFACE_AUTO        0
+#define FSCMN_INTERFACE_V24         1
+#define FSCMN_INTERFACE_X21         2
+#define FSCMN_INTERFACE_V35         3
+#define FSCMN_INTERFACE_X21D        4
+#define FSCMN_INTERFACE_NO_CABLE    5
+#define FSCMN_INTERFACE_RS530       6
+#define FSCMN_INTERFACE_RS485       7
+#define FSCMN_INTERFACE_RS485_FDX   8
+
+#define FSCMN_INTERFACE_DEFAULT     FSCMN_INTERFACE_V24
+
+/* Clock source defines */
+
+#define FSCMN_CLOCK_EXTERNAL        0
+#define FSCMN_CLOCK_INTERNAL        1
+
+#define FSCMN_CLOCK_DEFAULT         FSCMN_CLOCK_EXTERNAL
+
+/* Data encoding defines */
+
+#define FSCMN_ENCODING_NRZ          0x80
+#define FSCMN_ENCODING_NRZI         0xa0
+#define FSCMN_ENCODING_FM0          0xc0
+#define FSCMN_ENCODING_FM1          0xd0
+#define FSCMN_ENCODING_MANCHESTER   0xe0
+#define FSCMN_ENCODING_DMAN         0xf0
+
+#define FSCMN_ENCODING_DEFAULT      FSCMN_ENCODING_NRZ
+
+/* Data type defines */
+
+#define FSCMN_MODE_HDLC             0
+#define FSCMN_MODE_TRANSPARENT      1
+#define FSCMN_MODE_BISYNC           2
+#define FSCMN_MODE_ASYNC            3
+
+#define FSCMN_MODE_DEFAULT          FSCMN_MODE_HDLC
+
+/* Defines if MS or LS bit is transmitted first, LSB first for
+ * HDLC and MSB first for transparent is the usual setting
+ */
+
+#define FSCMN_BIT_ORDER_LSB_FIRST   0
+#define FSCMN_BIT_ORDER_MSB_FIRST   1
+
+#define FSCMN_BIT_ORDER_DEFAULT     FSCMN_BIT_ORDER_LSB_FIRST
+
+/* Receive clock inversion defines */
+
+#define FSCMN_RXCLOCK_NORMAL        0
+#define FSCMN_RXCLOCK_INVERTED      1
+
+#define FSCMN_RXCLOCK_DEFAULT       FSCMN_RXCLOCK_NORMAL
+
+/* Start type defines */
+
+#define FSCMN_START_TX              1
+#define FSCMN_START_RX              2
+#define FSCMN_START_TX_AND_RX       (FSCMN_START_TX | FSCMN_START_RX)
+#define FSCMN_START_DEFAULT         FSCMN_START_TX_AND_RX
+
+/* Termination defines */
+
+#define FSCMN_TERMINATION_NONE      0
+#define FSCMN_TERMINATION_RESISTIVE 1
+
+#define FSCMN_TERMINATION_DEFAULT FSCMN_TERMINATION_NONE
+
+/* Async rxFifos data format */
+
+/* Char => 1-byte data (default)
+ * Status + Char => 1-byte status + 1-byte char
+ * Status + Char + Timestamp =>  1-byte status + 1-byte char + 4-byte timestamp
+ */
+
+#define FSCMN_ASYNC_RX_CHAR             0
+#define FSCMN_ASYNC_RX_STATUS_CHAR      1
+#define FSCMN_ASYNC_RX_STATUS_CHAR_TIME 2
+#define FSCMN_ASYNC_RX_CHAR_NO_ERROR    3
+
+#define FSCMN_ASYNC_RX_DEFAULT FSCMN_ASYNC_RX_CHAR
+
+typedef struct _FSCMN_TXRX_PREAMBLE {
+	u32 timestamp;		/* 0x00000000 from driver to card in transmit
+				 * frames 32-bit timestamp when 1st byte of
+				 * receive frames
+				 */
+	u16 length;		/* length of frame in bytes (excl preamble) */
+	u8 port;		/* port A or B */
+	u8 status;		/* 0x00 from driver to card in transmit frames
+				 * RSTA status byte for receive frames
+				 */
+} FSCMN_TXRX_PREAMBLE, *PFSCMN_TXRX_PREAMBLE;
+
+/* conditional features */
+#define FSCMN_FEATURE_DMAN     0x01
+#define FSCMN_FEATURE_FDX485   0x02
+#define FSCMN_FEATURE_DIV      0x04
+#define FSCMN_FEATURE_TT       0x08
+
+#endif /* INC_FSCMN */
