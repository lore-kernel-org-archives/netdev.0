From: Alejandro Martinez Ruiz <alex@flawedcode.org>
Subject: [PATCH] netdev: convert non-obvious instances to use ARRAY_SIZE()
Date: Mon, 15 Oct 2007 03:37:43 +0200
Message-ID: <20071015013743.GB21622@inspiron>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:48295 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751706AbXJOBe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 21:34:59 -0400
Received: by ug-out-1314.google.com with SMTP id z38so812917ugc
        for <netdev@vger.kernel.org>; Sun, 14 Oct 2007 18:34:57 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This will convert remaining non-obvious or naive calculations of array
sizes to use ARRAY_SIZE() macro.

Signed-off-by: Alejandro Martinez Ruiz <alex@flawedcode.org>
---
 drivers/net/cassini.c       |    2 +-
 drivers/net/irda/donauboe.c |    2 +-
 drivers/net/ne-h8300.c      |    4 ++--
 drivers/net/tg3.c           |    2 +-
 drivers/net/tulip/de4x5.c   |    4 ++--
 drivers/net/wan/sdla.c      |    8 ++++----
 6 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 563bf5f..7df31b5 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -4443,7 +4443,7 @@ static struct {
 	{REG_MAC_COLL_EXCESS},
 	{REG_MAC_COLL_LATE}
 };
-#define CAS_REG_LEN 	(sizeof(ethtool_register_table)/sizeof(int))
+#define CAS_REG_LEN 	ARRAY_SIZE(ethtool_register_table)
 #define CAS_MAX_REGS 	(sizeof (u32)*CAS_REG_LEN)
 
 static void cas_read_regs(struct cas *cp, u8 *ptr, int len)
diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index 3e5eca1..a82d8f9 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -840,7 +840,7 @@ toshoboe_probe (struct toshoboe_cb *self)
 
   /* test 1: SIR filter and back to back */
 
-  for (j = 0; j < (sizeof (bauds) / sizeof (int)); ++j)
+  for (j = 0; j < ARRAY_SIZE(bauds); ++j)
     {
       int fir = (j > 1);
       toshoboe_stopchip (self);
diff --git a/drivers/net/ne-h8300.c b/drivers/net/ne-h8300.c
index 368f256..fbc7531 100644
--- a/drivers/net/ne-h8300.c
+++ b/drivers/net/ne-h8300.c
@@ -93,7 +93,7 @@ static int __init init_reg_offset(struct net_device *dev,unsigned long base_addr
 	bus_width = *(volatile unsigned char *)ABWCR;
 	bus_width &= 1 << ((base_addr >> 21) & 7);
 
-	for (i = 0; i < sizeof(reg_offset) / sizeof(u32); i++)
+	for (i = 0; i < ARRAY_SIZE(reg_offset); i++)
 		if (bus_width == 0)
 			reg_offset[i] = i * 2 + 1;
 		else
@@ -115,7 +115,7 @@ static int h8300_ne_irq[] = {EXT_IRQ5};
 
 static inline int init_dev(struct net_device *dev)
 {
-	if (h8300_ne_count < (sizeof(h8300_ne_base) / sizeof(unsigned long))) {
+	if (h8300_ne_count < ARRAY_SIZE(h8300_ne_base)) {
 		dev->base_addr = h8300_ne_base[h8300_ne_count];
 		dev->irq       = h8300_ne_irq[h8300_ne_count];
 		h8300_ne_count++;
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 30b1cca..76efb3f 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -9034,7 +9034,7 @@ static int tg3_do_mem_test(struct tg3 *tp, u32 offset, u32 len)
 	int i;
 	u32 j;
 
-	for (i = 0; i < sizeof(test_pattern)/sizeof(u32); i++) {
+	for (i = 0; i < ARRAY_SIZE(test_pattern); i++) {
 		for (j = 0; j < len; j += 4) {
 			u32 val;
 
diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index 9b9cd83..41f34bb 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -1041,7 +1041,7 @@ static struct InfoLeaf infoleaf_array[] = {
     {DC21142, dc21142_infoleaf},
     {DC21143, dc21143_infoleaf}
 };
-#define INFOLEAF_SIZE (sizeof(infoleaf_array)/(sizeof(int)+sizeof(int *)))
+#define INFOLEAF_SIZE ARRAY_SIZE(infoleaf_array)
 
 /*
 ** List the SROM info block functions
@@ -1056,7 +1056,7 @@ static int (*dc_infoblock[])(struct net_device *dev, u_char, u_char *) = {
     compact_infoblock
 };
 
-#define COMPACT (sizeof(dc_infoblock)/sizeof(int *) - 1)
+#define COMPACT (ARRAY_SIZE(dc_infoblock) - 1)
 
 /*
 ** Miscellaneous defines...
diff --git a/drivers/net/wan/sdla.c b/drivers/net/wan/sdla.c
index b39a541..05df0a3 100644
--- a/drivers/net/wan/sdla.c
+++ b/drivers/net/wan/sdla.c
@@ -1342,11 +1342,11 @@ static int sdla_set_config(struct net_device *dev, struct ifmap *map)
 	if (flp->initialized)
 		return(-EINVAL);
 
-	for(i=0;i < sizeof(valid_port) / sizeof (int) ; i++)
+	for(i=0; i < ARRAY_SIZE(valid_port); i++)
 		if (valid_port[i] == map->base_addr)
 			break;   
 
-	if (i == sizeof(valid_port) / sizeof(int))
+	if (i == ARRAY_SIZE(valid_port))
 		return(-EINVAL);
 
 	if (!request_region(map->base_addr, SDLA_IO_EXTENTS, dev->name)){
@@ -1487,12 +1487,12 @@ got_type:
 		}
 	}
 
-	for(i=0;i < sizeof(valid_mem) / sizeof (int) ; i++)
+	for(i=0; i < ARRAY_SIZE(valid_mem); i++)
 		if (valid_mem[i] == map->mem_start)
 			break;   
 
 	err = -EINVAL;
-	if (i == sizeof(valid_mem) / sizeof(int))
+	if (i == ARRAY_SIZE(valid_mem))
 		goto fail2;
 
 	if (flp->type == SDLA_S502A && (map->mem_start & 0xF000) >> 12 == 0x0E)
-- 
1.5.3.4


