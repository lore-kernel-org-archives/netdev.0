From: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Subject: [PATCH] LIB82596: correct data types for hardware addresses
Date: Fri, 30 Nov 2007 23:13:16 +0100 (CET)
Message-ID: <20071130221316.3CDBEC2EAD@solo.franken.de>
Cc: jgarzik@pobox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from elvis.franken.de ([193.175.24.41]:39731 "EHLO elvis.franken.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753753AbXK3WNZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 17:13:25 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dma_addr_t is 64bit wide on some architectures (for example 64bit MIPS),
so it's not a good idea to use it for 32bit wide addresses in descriptors.

Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
---

 drivers/net/lib82596.c |   50 ++++++++++++++++++++++++------------------------
 1 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/drivers/net/lib82596.c b/drivers/net/lib82596.c
index 9a855e5..b59f442 100644
--- a/drivers/net/lib82596.c
+++ b/drivers/net/lib82596.c
@@ -176,8 +176,8 @@ struct i596_reg {
 struct i596_tbd {
 	unsigned short size;
 	unsigned short pad;
-	dma_addr_t     next;
-	dma_addr_t     data;
+	u32            next;
+	u32            data;
 	u32 cache_pad[5];		/* Total 32 bytes... */
 };
 
@@ -195,12 +195,12 @@ struct i596_cmd {
 	struct i596_cmd *v_next;	/* Address from CPUs viewpoint */
 	unsigned short status;
 	unsigned short command;
-	dma_addr_t     b_next;	/* Address from i596 viewpoint */
+	u32            b_next;	/* Address from i596 viewpoint */
 };
 
 struct tx_cmd {
 	struct i596_cmd cmd;
-	dma_addr_t     tbd;
+	u32            tbd;
 	unsigned short size;
 	unsigned short pad;
 	struct sk_buff *skb;		/* So we can free it after tx */
@@ -237,8 +237,8 @@ struct cf_cmd {
 struct i596_rfd {
 	unsigned short stat;
 	unsigned short cmd;
-	dma_addr_t     b_next;	/* Address from i596 viewpoint */
-	dma_addr_t     rbd;
+	u32            b_next;	/* Address from i596 viewpoint */
+	u32            rbd;
 	unsigned short count;
 	unsigned short size;
 	struct i596_rfd *v_next;	/* Address from CPUs viewpoint */
@@ -249,18 +249,18 @@ struct i596_rfd {
 };
 
 struct i596_rbd {
-    /* hardware data */
-    unsigned short count;
-    unsigned short zero1;
-    dma_addr_t     b_next;
-    dma_addr_t     b_data;		/* Address from i596 viewpoint */
-    unsigned short size;
-    unsigned short zero2;
-    /* driver data */
-    struct sk_buff *skb;
-    struct i596_rbd *v_next;
-    dma_addr_t     b_addr;		/* This rbd addr from i596 view */
-    unsigned char *v_data;		/* Address from CPUs viewpoint */
+	/* hardware data */
+	unsigned short count;
+	unsigned short zero1;
+	u32            b_next;
+	u32            b_data;		/* Address from i596 viewpoint */
+	unsigned short size;
+	unsigned short zero2;
+	/* driver data */
+	struct sk_buff *skb;
+	struct i596_rbd *v_next;
+	u32            b_addr;		/* This rbd addr from i596 view */
+	unsigned char *v_data;		/* Address from CPUs viewpoint */
 					/* Total 32 bytes... */
 #ifdef __LP64__
     u32 cache_pad[4];
@@ -275,8 +275,8 @@ struct i596_rbd {
 struct i596_scb {
 	unsigned short status;
 	unsigned short command;
-	dma_addr_t    cmd;
-	dma_addr_t    rfd;
+	u32           cmd;
+	u32           rfd;
 	u32           crc_err;
 	u32           align_err;
 	u32           resource_err;
@@ -288,14 +288,14 @@ struct i596_scb {
 };
 
 struct i596_iscp {
-	u32           stat;
-	dma_addr_t    scb;
+	u32 stat;
+	u32 scb;
 };
 
 struct i596_scp {
-	u32           sysbus;
-	u32           pad;
-	dma_addr_t    iscp;
+	u32 sysbus;
+	u32 pad;
+	u32 iscp;
 };
 
 struct i596_dma {
