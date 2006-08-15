From: akpm@osdl.org
Subject: [patch 11/13] constify Tigon3 ether firmware structs
Date: Mon, 14 Aug 2006 23:03:45 -0700
Message-ID: <200608150603.k7F63jC4012954@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	andi@rhlx01.fht-esslingen.de, andi@lisas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:53651 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965166AbWHOGD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:03:59 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andreas Mohr <andi@rhlx01.fht-esslingen.de>

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

Signed-off-by: Andreas Mohr <andi@lisas.de>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/tg3.c |   26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff -puN drivers/net/tg3.c~constify-tigon3-ether-firmware-structs drivers/net/tg3.c
--- a/drivers/net/tg3.c~constify-tigon3-ether-firmware-structs
+++ a/drivers/net/tg3.c
@@ -264,7 +264,7 @@ static struct pci_device_id tg3_pci_tbl[
 
 MODULE_DEVICE_TABLE(pci, tg3_pci_tbl);
 
-static struct {
+static const struct {
 	const char string[ETH_GSTRING_LEN];
 } ethtool_stats_keys[TG3_NUM_STATS] = {
 	{ "rx_octets" },
@@ -345,7 +345,7 @@ static struct {
 	{ "nic_tx_threshold_hit" }
 };
 
-static struct {
+static const struct {
 	const char string[ETH_GSTRING_LEN];
 } ethtool_test_keys[TG3_NUM_TEST] = {
 	{ "nvram test     (online) " },
@@ -4969,7 +4969,7 @@ static int tg3_halt(struct tg3 *tp, int 
 #define TG3_FW_BSS_ADDR		0x08000a70
 #define TG3_FW_BSS_LEN		0x10
 
-static u32 tg3FwText[(TG3_FW_TEXT_LEN / sizeof(u32)) + 1] = {
+static const u32 tg3FwText[(TG3_FW_TEXT_LEN / sizeof(u32)) + 1] = {
 	0x00000000, 0x10000003, 0x00000000, 0x0000000d, 0x0000000d, 0x3c1d0800,
 	0x37bd3ffc, 0x03a0f021, 0x3c100800, 0x26100000, 0x0e000018, 0x00000000,
 	0x0000000d, 0x3c1d0800, 0x37bd3ffc, 0x03a0f021, 0x3c100800, 0x26100034,
@@ -5063,7 +5063,7 @@ static u32 tg3FwText[(TG3_FW_TEXT_LEN / 
 	0x27bd0008, 0x03e00008, 0x00000000, 0x00000000, 0x00000000
 };
 
-static u32 tg3FwRodata[(TG3_FW_RODATA_LEN / sizeof(u32)) + 1] = {
+static const u32 tg3FwRodata[(TG3_FW_RODATA_LEN / sizeof(u32)) + 1] = {
 	0x35373031, 0x726c7341, 0x00000000, 0x00000000, 0x53774576, 0x656e7430,
 	0x00000000, 0x726c7045, 0x76656e74, 0x31000000, 0x556e6b6e, 0x45766e74,
 	0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x66617461, 0x6c457272,
@@ -5128,13 +5128,13 @@ static int tg3_halt_cpu(struct tg3 *tp, 
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
@@ -5266,7 +5266,7 @@ static int tg3_load_5701_a0_firmware_fix
 #define TG3_TSO_FW_BSS_ADDR		0x08001b80
 #define TG3_TSO_FW_BSS_LEN		0x894
 
-static u32 tg3TsoFwText[(TG3_TSO_FW_TEXT_LEN / 4) + 1] = {
+static const u32 tg3TsoFwText[(TG3_TSO_FW_TEXT_LEN / 4) + 1] = {
 	0x0e000003, 0x00000000, 0x08001b24, 0x00000000, 0x10000003, 0x00000000,
 	0x0000000d, 0x0000000d, 0x3c1d0800, 0x37bd4000, 0x03a0f021, 0x3c100800,
 	0x26100000, 0x0e000010, 0x00000000, 0x0000000d, 0x27bdffe0, 0x3c04fefe,
@@ -5553,7 +5553,7 @@ static u32 tg3TsoFwText[(TG3_TSO_FW_TEXT
 	0xac470014, 0xac4a0018, 0x03e00008, 0xac4b001c, 0x00000000, 0x00000000,
 };
 
-static u32 tg3TsoFwRodata[] = {
+static const u32 tg3TsoFwRodata[] = {
 	0x4d61696e, 0x43707542, 0x00000000, 0x4d61696e, 0x43707541, 0x00000000,
 	0x00000000, 0x00000000, 0x73746b6f, 0x66666c64, 0x496e0000, 0x73746b6f,
 	0x66662a2a, 0x00000000, 0x53774576, 0x656e7430, 0x00000000, 0x00000000,
@@ -5561,7 +5561,7 @@ static u32 tg3TsoFwRodata[] = {
 	0x00000000,
 };
 
-static u32 tg3TsoFwData[] = {
+static const u32 tg3TsoFwData[] = {
 	0x00000000, 0x73746b6f, 0x66666c64, 0x5f76312e, 0x362e3000, 0x00000000,
 	0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
 	0x00000000,
@@ -5583,7 +5583,7 @@ static u32 tg3TsoFwData[] = {
 #define TG3_TSO5_FW_BSS_ADDR		0x00010f50
 #define TG3_TSO5_FW_BSS_LEN		0x88
 
-static u32 tg3Tso5FwText[(TG3_TSO5_FW_TEXT_LEN / 4) + 1] = {
+static const u32 tg3Tso5FwText[(TG3_TSO5_FW_TEXT_LEN / 4) + 1] = {
 	0x0c004003, 0x00000000, 0x00010f04, 0x00000000, 0x10000003, 0x00000000,
 	0x0000000d, 0x0000000d, 0x3c1d0001, 0x37bde000, 0x03a0f021, 0x3c100001,
 	0x26100000, 0x0c004010, 0x00000000, 0x0000000d, 0x27bdffe0, 0x3c04fefe,
@@ -5742,14 +5742,14 @@ static u32 tg3Tso5FwText[(TG3_TSO5_FW_TE
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
_
