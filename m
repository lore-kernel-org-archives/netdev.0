From: Andreas Mohr <andi@rhlx01.fht-esslingen.de>
Subject: [PATCH -mm] constify Tigon3 ether firmware structs
Date: Fri, 11 Aug 2006 22:04:51 +0200
Message-ID: <20060811200451.GA10504@rhlx01.fht-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.fht-esslingen.de ([129.143.116.10]:62624 "EHLO
	rhlx01.fht-esslingen.de") by vger.kernel.org with ESMTP
	id S964782AbWHKUE4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 16:04:56 -0400
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Constify largish areas of firmware data in Tigon3 ethernet driver.


non-const:

lsmod:
tg3                   101404  0

objdump -x:
.rodata 000003e8
.data 00004a0c

ls -l:
-rw-r--r-- 1 root root 114404 2006-08-19 21:36 drivers/net/tg3.ko


const:

lsmod:
tg3                   101404  0

objdump -x:
.rodata 000042c8
.data 00000b4c

ls -l:
-rw-r--r-- 1 root root 114532 2006-08-19 21:06 drivers/net/tg3.ko



Compile- and run-tested with tg3 card on 2.6.18-rc3-mm2.

Any objections?


Signed-off-by: Andreas Mohr <andi@lisas.de>


diff -urN linux-2.6.18-rc3-mm2.orig/drivers/net/tg3.c linux-2.6.18-rc3-mm2/drivers/net/tg3.c
--- linux-2.6.18-rc3-mm2.orig/drivers/net/tg3.c	2006-08-07 11:15:17.000000000 +0200
+++ linux-2.6.18-rc3-mm2/drivers/net/tg3.c	2006-08-08 16:49:43.000000000 +0200
@@ -267,7 +267,7 @@
 
 MODULE_DEVICE_TABLE(pci, tg3_pci_tbl);
 
-static struct {
+static const struct {
 	const char string[ETH_GSTRING_LEN];
 } ethtool_stats_keys[TG3_NUM_STATS] = {
 	{ "rx_octets" },
@@ -348,7 +348,7 @@
 	{ "nic_tx_threshold_hit" }
 };
 
-static struct {
+static const struct {
 	const char string[ETH_GSTRING_LEN];
 } ethtool_test_keys[TG3_NUM_TEST] = {
 	{ "nvram test     (online) " },
@@ -4963,7 +4963,7 @@
 #define TG3_FW_BSS_ADDR		0x08000a70
 #define TG3_FW_BSS_LEN		0x10
 
-static u32 tg3FwText[(TG3_FW_TEXT_LEN / sizeof(u32)) + 1] = {
+static const u32 tg3FwText[(TG3_FW_TEXT_LEN / sizeof(u32)) + 1] = {
 	0x00000000, 0x10000003, 0x00000000, 0x0000000d, 0x0000000d, 0x3c1d0800,
 	0x37bd3ffc, 0x03a0f021, 0x3c100800, 0x26100000, 0x0e000018, 0x00000000,
 	0x0000000d, 0x3c1d0800, 0x37bd3ffc, 0x03a0f021, 0x3c100800, 0x26100034,
@@ -5057,7 +5057,7 @@
 	0x27bd0008, 0x03e00008, 0x00000000, 0x00000000, 0x00000000
 };
 
-static u32 tg3FwRodata[(TG3_FW_RODATA_LEN / sizeof(u32)) + 1] = {
+static const u32 tg3FwRodata[(TG3_FW_RODATA_LEN / sizeof(u32)) + 1] = {
 	0x35373031, 0x726c7341, 0x00000000, 0x00000000, 0x53774576, 0x656e7430,
 	0x00000000, 0x726c7045, 0x76656e74, 0x31000000, 0x556e6b6e, 0x45766e74,
 	0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x66617461, 0x6c457272,
@@ -5122,13 +5122,13 @@
 struct fw_info {
 	unsigned int text_base;
 	unsigned int text_len;
-	u32 *text_data;
+	const u32 *text_data;
 	unsigned int rodata_base;
 	unsigned int rodata_len;
-	u32 *rodata_data;
+	const u32 *rodata_data;
 	unsigned int data_base;
 	unsigned int data_len;
-	u32 *data_data;
+	const u32 *data_data;
 };
 
 /* tp->lock is held. */
@@ -5260,7 +5260,7 @@
 #define TG3_TSO_FW_BSS_ADDR		0x08001b80
 #define TG3_TSO_FW_BSS_LEN		0x894
 
-static u32 tg3TsoFwText[(TG3_TSO_FW_TEXT_LEN / 4) + 1] = {
+static const u32 tg3TsoFwText[(TG3_TSO_FW_TEXT_LEN / 4) + 1] = {
 	0x0e000003, 0x00000000, 0x08001b24, 0x00000000, 0x10000003, 0x00000000,
 	0x0000000d, 0x0000000d, 0x3c1d0800, 0x37bd4000, 0x03a0f021, 0x3c100800,
 	0x26100000, 0x0e000010, 0x00000000, 0x0000000d, 0x27bdffe0, 0x3c04fefe,
@@ -5547,7 +5547,7 @@
 	0xac470014, 0xac4a0018, 0x03e00008, 0xac4b001c, 0x00000000, 0x00000000,
 };
 
-static u32 tg3TsoFwRodata[] = {
+static const u32 tg3TsoFwRodata[] = {
 	0x4d61696e, 0x43707542, 0x00000000, 0x4d61696e, 0x43707541, 0x00000000,
 	0x00000000, 0x00000000, 0x73746b6f, 0x66666c64, 0x496e0000, 0x73746b6f,
 	0x66662a2a, 0x00000000, 0x53774576, 0x656e7430, 0x00000000, 0x00000000,
@@ -5555,7 +5555,7 @@
 	0x00000000,
 };
 
-static u32 tg3TsoFwData[] = {
+static const u32 tg3TsoFwData[] = {
 	0x00000000, 0x73746b6f, 0x66666c64, 0x5f76312e, 0x362e3000, 0x00000000,
 	0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
 	0x00000000,
@@ -5577,7 +5577,7 @@
 #define TG3_TSO5_FW_BSS_ADDR		0x00010f50
 #define TG3_TSO5_FW_BSS_LEN		0x88
 
-static u32 tg3Tso5FwText[(TG3_TSO5_FW_TEXT_LEN / 4) + 1] = {
+static const u32 tg3Tso5FwText[(TG3_TSO5_FW_TEXT_LEN / 4) + 1] = {
 	0x0c004003, 0x00000000, 0x00010f04, 0x00000000, 0x10000003, 0x00000000,
 	0x0000000d, 0x0000000d, 0x3c1d0001, 0x37bde000, 0x03a0f021, 0x3c100001,
 	0x26100000, 0x0c004010, 0x00000000, 0x0000000d, 0x27bdffe0, 0x3c04fefe,
@@ -5736,14 +5736,14 @@
 	0x00000000, 0x00000000, 0x00000000,
 };
 
-static u32 tg3Tso5FwRodata[(TG3_TSO5_FW_RODATA_LEN / 4) + 1] = {
+static const u32 tg3Tso5FwRodata[(TG3_TSO5_FW_RODATA_LEN / 4) + 1] = {
 	0x4d61696e, 0x43707542, 0x00000000, 0x4d61696e, 0x43707541, 0x00000000,
 	0x00000000, 0x00000000, 0x73746b6f, 0x66666c64, 0x00000000, 0x00000000,
 	0x73746b6f, 0x66666c64, 0x00000000, 0x00000000, 0x66617461, 0x6c457272,
 	0x00000000, 0x00000000, 0x00000000,
 };
 
-static u32 tg3Tso5FwData[(TG3_TSO5_FW_DATA_LEN / 4) + 1] = {
+static const u32 tg3Tso5FwData[(TG3_TSO5_FW_DATA_LEN / 4) + 1] = {
 	0x00000000, 0x73746b6f, 0x66666c64, 0x5f76312e, 0x322e3000, 0x00000000,
 	0x00000000, 0x00000000, 0x00000000,
 };
