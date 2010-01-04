From: Joe Perches <joe@perches.com>
Subject: [PATCH 4/5] drivers/net/mac8390.c: Checkpatch cleanups
Date: Mon,  4 Jan 2010 13:53:02 -0800
Message-ID: <734e2e1fee3d2d2cd83d4597d91569e7153aea6a.1262630406.git.joe@perches.com>
References: <cover.1262630406.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: Paul Gortmaker <p_gortmaker@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1495 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753437Ab0ADVxI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2010 16:53:08 -0500
In-Reply-To: <cover.1262630406.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use #include <linux/ not #include <asm/
Add spaces after arguments
Comment neatening
Make a couple of arrays static const
Align function arguments
Wrap text at 80 columns where reasonable
Cuddle brace else

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/mac8390.c |  229 ++++++++++++++++++++++++++-----------------------
 1 files changed, 122 insertions(+), 107 deletions(-)

diff --git a/drivers/net/mac8390.c b/drivers/net/mac8390.c
index 8bd09e2..8f16889 100644
--- a/drivers/net/mac8390.c
+++ b/drivers/net/mac8390.c
@@ -36,9 +36,9 @@
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
 #include <linux/bitops.h>
+#include <linux/io.h>
 
 #include <asm/system.h>
-#include <asm/io.h>
 #include <asm/dma.h>
 #include <asm/hwtest.h>
 #include <asm/macints.h>
@@ -47,20 +47,25 @@ static char version[] =
 	"v0.4 2001-05-15 David Huggins-Daines <dhd@debian.org> and others\n";
 
 #define EI_SHIFT(x)	(ei_local->reg_offset[x])
-#define ei_inb(port)   in_8(port)
-#define ei_outb(val,port)  out_8(port,val)
-#define ei_inb_p(port)   in_8(port)
-#define ei_outb_p(val,port)  out_8(port,val)
+#define ei_inb(port)	in_8(port)
+#define ei_outb(val, port)	out_8(port, val)
+#define ei_inb_p(port)	in_8(port)
+#define ei_outb_p(val, port)	out_8(port, val)
 
 #include "lib8390.c"
 
 #define WD_START_PG			0x00	/* First page of TX buffer */
 #define CABLETRON_RX_START_PG		0x00    /* First page of RX buffer */
 #define CABLETRON_RX_STOP_PG		0x30    /* Last page +1 of RX ring */
-#define CABLETRON_TX_START_PG		CABLETRON_RX_STOP_PG  /* First page of TX buffer */
+#define CABLETRON_TX_START_PG		CABLETRON_RX_STOP_PG
+						/* First page of TX buffer */
 
-/* Unfortunately it seems we have to hardcode these for the moment */
-/* Shouldn't the card know about this? Does anyone know where to read it off the card? Do we trust the data provided by the card? */
+/*
+ * Unfortunately it seems we have to hardcode these for the moment
+ * Shouldn't the card know about this?
+ * Does anyone know where to read it off the card?
+ * Do we trust the data provided by the card?
+ */
 
 #define DAYNA_8390_BASE		0x80000
 #define DAYNA_8390_MEM		0x00000
@@ -82,7 +87,7 @@ enum mac8390_type {
 	MAC8390_KINETICS,
 };
 
-static const char * cardname[] = {
+static const char *cardname[] = {
 	"apple",
 	"asante",
 	"farallon",
@@ -92,7 +97,7 @@ static const char * cardname[] = {
 	"kinetics",
 };
 
-static int word16[] = {
+static const int word16[] = {
 	1, /* apple */
 	1, /* asante */
 	1, /* farallon */
@@ -103,7 +108,7 @@ static int word16[] = {
 };
 
 /* on which cards do we use NuBus resources? */
-static int useresources[] = {
+static const int useresources[] = {
 	1, /* apple */
 	1, /* asante */
 	1, /* farallon */
@@ -119,22 +124,22 @@ enum mac8390_access {
 	ACCESS_16,
 };
 
-extern int mac8390_memtest(struct net_device * dev);
-static int mac8390_initdev(struct net_device * dev, struct nubus_dev * ndev,
+extern int mac8390_memtest(struct net_device *dev);
+static int mac8390_initdev(struct net_device *dev, struct nubus_dev *ndev,
 			   enum mac8390_type type);
 
-static int mac8390_open(struct net_device * dev);
-static int mac8390_close(struct net_device * dev);
+static int mac8390_open(struct net_device *dev);
+static int mac8390_close(struct net_device *dev);
 static void mac8390_no_reset(struct net_device *dev);
 static void interlan_reset(struct net_device *dev);
 
 /* Sane (32-bit chunk memory read/write) - Some Farallon and Apple do this*/
 static void sane_get_8390_hdr(struct net_device *dev,
 			      struct e8390_pkt_hdr *hdr, int ring_page);
-static void sane_block_input(struct net_device * dev, int count,
-			     struct sk_buff * skb, int ring_offset);
-static void sane_block_output(struct net_device * dev, int count,
-			      const unsigned char * buf, const int start_page);
+static void sane_block_input(struct net_device *dev, int count,
+			     struct sk_buff *skb, int ring_offset);
+static void sane_block_output(struct net_device *dev, int count,
+			      const unsigned char *buf, const int start_page);
 
 /* dayna_memcpy to and from card */
 static void dayna_memcpy_fromcard(struct net_device *dev, void *to,
@@ -150,8 +155,8 @@ static void dayna_block_input(struct net_device *dev, int count,
 static void dayna_block_output(struct net_device *dev, int count,
 			       const unsigned char *buf, int start_page);
 
-#define memcpy_fromio(a,b,c)	memcpy((a),(void *)(b),(c))
-#define memcpy_toio(a,b,c)	memcpy((void *)(a),(b),(c))
+#define memcpy_fromio(a, b, c)	memcpy((a), (void *)(b), (c))
+#define memcpy_toio(a, b, c)	memcpy((void *)(a), (b), (c))
 
 /* Slow Sane (16-bit chunk memory read/write) Cabletron uses this */
 static void slow_sane_get_8390_hdr(struct net_device *dev,
@@ -222,10 +227,12 @@ static enum mac8390_type __init mac8390_ident(struct nubus_dev *dev)
 		break;
 
 	case NUBUS_DRSW_DAYNA:
-		// These correspond to Dayna Sonic cards
-		// which use the macsonic driver
+		/*
+		 * These correspond to Dayna Sonic cards
+		 * which use the macsonic driver
+		 */
 		if (dev->dr_hw == NUBUS_DRHW_SMC9194 ||
-		    dev->dr_hw == NUBUS_DRHW_INTERLAN )
+		    dev->dr_hw == NUBUS_DRHW_INTERLAN)
 			return MAC8390_NONE;
 		else
 			return MAC8390_DAYNA;
@@ -260,7 +267,7 @@ static int __init mac8390_memsize(unsigned long membase)
 	local_irq_save(flags);
 	/* Check up to 32K in 4K increments */
 	for (i = 0; i < 8; i++) {
-		volatile unsigned short *m = (unsigned short *) (membase + (i * 0x1000));
+		volatile unsigned short *m = (unsigned short *)(membase + (i * 0x1000));
 
 		/* Unwriteable - we have a fully decoded card and the
 		   RAM end located */
@@ -275,22 +282,24 @@ static int __init mac8390_memsize(unsigned long membase)
 
 		/* check for partial decode and wrap */
 		for (j = 0; j < i; j++) {
-			volatile unsigned short *p = (unsigned short *) (membase + (j * 0x1000));
+			volatile unsigned short *p = (unsigned short *)(membase + (j * 0x1000));
 			if (*p != (0xA5A0 | j))
 				break;
- 		}
- 	}
+		}
+	}
 	local_irq_restore(flags);
-	/* in any case, we stopped once we tried one block too many,
-           or once we reached 32K */
- 	return i * 0x1000;
+	/*
+	 * in any case, we stopped once we tried one block too many,
+	 * or once we reached 32K
+	 */
+	return i * 0x1000;
 }
 
 struct net_device * __init mac8390_probe(int unit)
 {
 	struct net_device *dev;
 	volatile unsigned short *i;
-	struct nubus_dev * ndev = NULL;
+	struct nubus_dev *ndev = NULL;
 	int err = -ENODEV;
 
 	struct nubus_dir dir;
@@ -312,20 +321,23 @@ struct net_device * __init mac8390_probe(int unit)
 	if (unit >= 0)
 		sprintf(dev->name, "eth%d", unit);
 
-	while ((ndev = nubus_find_type(NUBUS_CAT_NETWORK, NUBUS_TYPE_ETHERNET, ndev))) {
+	while ((ndev = nubus_find_type(NUBUS_CAT_NETWORK, NUBUS_TYPE_ETHERNET,
+				       ndev))) {
 		/* Have we seen it already? */
 		if (slots & (1<<ndev->board->slot))
 			continue;
 		slots |= 1<<ndev->board->slot;
 
-		if ((cardtype = mac8390_ident(ndev)) == MAC8390_NONE)
+		cardtype = mac8390_ident(ndev);
+		if (cardtype == MAC8390_NONE)
 			continue;
 
 		printk_once(KERN_INFO pr_fmt(version));
 
 		dev->irq = SLOT2IRQ(ndev->board->slot);
 		/* This is getting to be a habit */
-		dev->base_addr = ndev->board->slot_addr | ((ndev->board->slot&0xf) << 20);
+		dev->base_addr = (ndev->board->slot_addr |
+				  ((ndev->board->slot & 0xf) << 20));
 
 		/* Get some Nubus info - we will trust the card's idea
 		   of where its memory and registers are. */
@@ -337,7 +349,7 @@ struct net_device * __init mac8390_probe(int unit)
 		}
 
 		/* Get the MAC address */
-		if ((nubus_find_rsrc(&dir, NUBUS_RESID_MAC_ADDRESS, &ent)) == -1) {
+		if (nubus_find_rsrc(&dir, NUBUS_RESID_MAC_ADDRESS, &ent) == -1) {
 			pr_info("%s: Couldn't get MAC address!\n", dev->name);
 			continue;
 		} else {
@@ -346,7 +358,8 @@ struct net_device * __init mac8390_probe(int unit)
 
 		if (useresources[cardtype] == 1) {
 			nubus_rewinddir(&dir);
-			if (nubus_find_rsrc(&dir, NUBUS_RESID_MINOR_BASEOS, &ent) == -1) {
+			if (nubus_find_rsrc(&dir, NUBUS_RESID_MINOR_BASEOS,
+					    &ent) == -1) {
 				pr_err("%s: Memory offset resource for slot %X not found!\n",
 				       dev->name, ndev->board->slot);
 				continue;
@@ -356,7 +369,8 @@ struct net_device * __init mac8390_probe(int unit)
 			/* yes, this is how the Apple driver does it */
 			dev->base_addr = dev->mem_start + 0x10000;
 			nubus_rewinddir(&dir);
-			if (nubus_find_rsrc(&dir, NUBUS_RESID_MINOR_LENGTH, &ent) == -1) {
+			if (nubus_find_rsrc(&dir, NUBUS_RESID_MINOR_LENGTH,
+					    &ent) == -1) {
 				pr_info("%s: Memory length resource for slot %X not found, probing\n",
 					dev->name, ndev->board->slot);
 				offset = mac8390_memsize(dev->mem_start);
@@ -485,22 +499,23 @@ static const struct net_device_ops mac8390_netdev_ops = {
 #endif
 };
 
-static int __init mac8390_initdev(struct net_device * dev, struct nubus_dev * ndev,
-			    enum mac8390_type type)
+static int __init mac8390_initdev(struct net_device *dev,
+				  struct nubus_dev *ndev,
+				  enum mac8390_type type)
 {
-	static u32 fwrd4_offsets[16]={
+	static u32 fwrd4_offsets[16] = {
 		0,      4,      8,      12,
 		16,     20,     24,     28,
 		32,     36,     40,     44,
 		48,     52,     56,     60
 	};
-	static u32 back4_offsets[16]={
+	static u32 back4_offsets[16] = {
 		60,     56,     52,     48,
 		44,     40,     36,     32,
 		28,     24,     20,     16,
 		12,     8,      4,      0
 	};
-	static u32 fwrd2_offsets[16]={
+	static u32 fwrd2_offsets[16] = {
 		0,      2,      4,      6,
 		8,     10,     12,     14,
 		16,    18,     20,     22,
@@ -518,17 +533,17 @@ static int __init mac8390_initdev(struct net_device * dev, struct nubus_dev * nd
 
 	/* Cabletron's TX/RX buffers are backwards */
 	if (type == MAC8390_CABLETRON) {
-               ei_status.tx_start_page = CABLETRON_TX_START_PG;
-               ei_status.rx_start_page = CABLETRON_RX_START_PG;
-               ei_status.stop_page = CABLETRON_RX_STOP_PG;
-               ei_status.rmem_start = dev->mem_start;
-               ei_status.rmem_end = dev->mem_start + CABLETRON_RX_STOP_PG*256;
+		ei_status.tx_start_page = CABLETRON_TX_START_PG;
+		ei_status.rx_start_page = CABLETRON_RX_START_PG;
+		ei_status.stop_page = CABLETRON_RX_STOP_PG;
+		ei_status.rmem_start = dev->mem_start;
+		ei_status.rmem_end = dev->mem_start + CABLETRON_RX_STOP_PG*256;
 	} else {
-               ei_status.tx_start_page = WD_START_PG;
-               ei_status.rx_start_page = WD_START_PG + TX_PAGES;
-               ei_status.stop_page = (dev->mem_end - dev->mem_start)/256;
-               ei_status.rmem_start = dev->mem_start + TX_PAGES*256;
-               ei_status.rmem_end = dev->mem_end;
+		ei_status.tx_start_page = WD_START_PG;
+		ei_status.rx_start_page = WD_START_PG + TX_PAGES;
+		ei_status.stop_page = (dev->mem_end - dev->mem_start)/256;
+		ei_status.rmem_start = dev->mem_start + TX_PAGES*256;
+		ei_status.rmem_end = dev->mem_end;
 	}
 
 	/* Fill in model-specific information and functions */
@@ -600,8 +615,8 @@ static int __init mac8390_initdev(struct net_device * dev, struct nubus_dev * nd
 		ei_status.block_input = &slow_sane_block_input;
 		ei_status.block_output = &slow_sane_block_output;
 		ei_status.get_8390_hdr = &slow_sane_get_8390_hdr;
-	        ei_status.reg_offset = fwrd4_offsets;
-	        break;
+		ei_status.reg_offset = fwrd4_offsets;
+		break;
 
 	default:
 		pr_err("Card type %s is unsupported, sorry\n",
@@ -649,7 +664,7 @@ static void mac8390_no_reset(struct net_device *dev)
 
 static void interlan_reset(struct net_device *dev)
 {
-	unsigned char *target=nubus_slot_addr(IRQ2SLOT(dev->irq));
+	unsigned char *target = nubus_slot_addr(IRQ2SLOT(dev->irq));
 	if (ei_debug > 1)
 		pr_info("Need to reset the NS8390 t=%lu...", jiffies);
 	ei_status.txing = 0;
@@ -661,54 +676,53 @@ static void interlan_reset(struct net_device *dev)
 
 /* dayna_memcpy_fromio/dayna_memcpy_toio */
 /* directly from daynaport.c by Alan Cox */
-static void dayna_memcpy_fromcard(struct net_device *dev, void *to, int from, int count)
+static void dayna_memcpy_fromcard(struct net_device *dev, void *to, int from,
+				  int count)
 {
 	volatile unsigned char *ptr;
-	unsigned char *target=to;
-	from<<=1;	/* word, skip overhead */
-	ptr=(unsigned char *)(dev->mem_start+from);
+	unsigned char *target = to;
+	from <<= 1;	/* word, skip overhead */
+	ptr = (unsigned char *)(dev->mem_start+from);
 	/* Leading byte? */
-	if (from&2) {
+	if (from & 2) {
 		*target++ = ptr[-1];
 		ptr += 2;
 		count--;
 	}
-	while(count>=2)
-	{
+	while (count >= 2) {
 		*(unsigned short *)target = *(unsigned short volatile *)ptr;
 		ptr += 4;			/* skip cruft */
 		target += 2;
-		count-=2;
+		count -= 2;
 	}
 	/* Trailing byte? */
-	if(count)
+	if (count)
 		*target = *ptr;
 }
 
-static void dayna_memcpy_tocard(struct net_device *dev, int to, const void *from, int count)
+static void dayna_memcpy_tocard(struct net_device *dev, int to,
+				const void *from, int count)
 {
 	volatile unsigned short *ptr;
-	const unsigned char *src=from;
-	to<<=1;	/* word, skip overhead */
-	ptr=(unsigned short *)(dev->mem_start+to);
+	const unsigned char *src = from;
+	to <<= 1;	/* word, skip overhead */
+	ptr = (unsigned short *)(dev->mem_start+to);
 	/* Leading byte? */
-	if (to&2) { /* avoid a byte write (stomps on other data) */
+	if (to & 2) {		/* avoid a byte write (stomps on other data) */
 		ptr[-1] = (ptr[-1]&0xFF00)|*src++;
 		ptr++;
 		count--;
 	}
-	while(count>=2)
-	{
-		*ptr++=*(unsigned short *)src;		/* Copy and */
+	while (count >= 2) {
+		*ptr++ = *(unsigned short *)src;	/* Copy and */
 		ptr++;			/* skip cruft */
 		src += 2;
-		count-=2;
+		count -= 2;
 	}
 	/* Trailing byte? */
-	if(count)
-	{
+	if (count) {
 		/* card doesn't like byte writes */
-		*ptr=(*ptr&0x00FF)|(*src << 8);
+		*ptr = (*ptr & 0x00FF) | (*src << 8);
 	}
 }
 
@@ -731,11 +745,14 @@ static void sane_block_input(struct net_device *dev, int count,
 	if (xfer_start + count > ei_status.rmem_end) {
 		/* We must wrap the input move. */
 		int semi_count = ei_status.rmem_end - xfer_start;
-		memcpy_fromio(skb->data, (char *)dev->mem_start + xfer_base, semi_count);
+		memcpy_fromio(skb->data, (char *)dev->mem_start + xfer_base,
+			      semi_count);
 		count -= semi_count;
-		memcpy_toio(skb->data + semi_count, (char *)ei_status.rmem_start, count);
+		memcpy_toio(skb->data + semi_count,
+			    (char *)ei_status.rmem_start, count);
 	} else {
-		memcpy_fromio(skb->data, (char *)dev->mem_start + xfer_base, count);
+		memcpy_fromio(skb->data, (char *)dev->mem_start + xfer_base,
+			      count);
 	}
 }
 
@@ -748,16 +765,18 @@ static void sane_block_output(struct net_device *dev, int count,
 }
 
 /* dayna block input/output */
-static void dayna_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr, int ring_page)
+static void dayna_get_8390_hdr(struct net_device *dev,
+			       struct e8390_pkt_hdr *hdr, int ring_page)
 {
 	unsigned long hdr_start = (ring_page - WD_START_PG)<<8;
 
 	dayna_memcpy_fromcard(dev, hdr, hdr_start, 4);
 	/* Fix endianness */
-	hdr->count=(hdr->count&0xFF)<<8|(hdr->count>>8);
+	hdr->count = (hdr->count & 0xFF) << 8 | (hdr->count >> 8);
 }
 
-static void dayna_block_input(struct net_device *dev, int count, struct sk_buff *skb, int ring_offset)
+static void dayna_block_input(struct net_device *dev, int count,
+			      struct sk_buff *skb, int ring_offset)
 {
 	unsigned long xfer_base = ring_offset - (WD_START_PG<<8);
 	unsigned long xfer_start = xfer_base+dev->mem_start;
@@ -765,8 +784,7 @@ static void dayna_block_input(struct net_device *dev, int count, struct sk_buff
 	/* Note the offset math is done in card memory space which is word
 	   per long onto our space. */
 
-	if (xfer_start + count > ei_status.rmem_end)
-	{
+	if (xfer_start + count > ei_status.rmem_end) {
 		/* We must wrap the input move. */
 		int semi_count = ei_status.rmem_end - xfer_start;
 		dayna_memcpy_fromcard(dev, skb->data, xfer_base, semi_count);
@@ -774,15 +792,14 @@ static void dayna_block_input(struct net_device *dev, int count, struct sk_buff
 		dayna_memcpy_fromcard(dev, skb->data + semi_count,
 				      ei_status.rmem_start - dev->mem_start,
 				      count);
-	}
-	else
-	{
+	} else {
 		dayna_memcpy_fromcard(dev, skb->data, xfer_base, count);
 	}
 }
 
-static void dayna_block_output(struct net_device *dev, int count, const unsigned char *buf,
-				int start_page)
+static void dayna_block_output(struct net_device *dev, int count,
+			       const unsigned char *buf,
+			       int start_page)
 {
 	long shmem = (start_page - WD_START_PG)<<8;
 
@@ -790,8 +807,9 @@ static void dayna_block_output(struct net_device *dev, int count, const unsigned
 }
 
 /* Cabletron block I/O */
-static void slow_sane_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr,
-	int ring_page)
+static void slow_sane_get_8390_hdr(struct net_device *dev,
+				   struct e8390_pkt_hdr *hdr,
+				   int ring_page)
 {
 	unsigned long hdr_start = (ring_page - WD_START_PG)<<8;
 	word_memcpy_fromcard(hdr, (char *)dev->mem_start + hdr_start, 4);
@@ -799,14 +817,13 @@ static void slow_sane_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr
 	hdr->count = (hdr->count&0xFF)<<8|(hdr->count>>8);
 }
 
-static void slow_sane_block_input(struct net_device *dev, int count, struct sk_buff *skb,
-	int ring_offset)
+static void slow_sane_block_input(struct net_device *dev, int count,
+				  struct sk_buff *skb, int ring_offset)
 {
 	unsigned long xfer_base = ring_offset - (WD_START_PG<<8);
 	unsigned long xfer_start = xfer_base+dev->mem_start;
 
-	if (xfer_start + count > ei_status.rmem_end)
-	{
+	if (xfer_start + count > ei_status.rmem_end) {
 		/* We must wrap the input move. */
 		int semi_count = ei_status.rmem_end - xfer_start;
 		word_memcpy_fromcard(skb->data,
@@ -815,16 +832,14 @@ static void slow_sane_block_input(struct net_device *dev, int count, struct sk_b
 		count -= semi_count;
 		word_memcpy_fromcard(skb->data + semi_count,
 				     (char *)ei_status.rmem_start, count);
-	}
-	else
-	{
+	} else {
 		word_memcpy_fromcard(skb->data,
 				     (char *)dev->mem_start + xfer_base, count);
 	}
 }
 
-static void slow_sane_block_output(struct net_device *dev, int count, const unsigned char *buf,
-	int start_page)
+static void slow_sane_block_output(struct net_device *dev, int count,
+				   const unsigned char *buf, int start_page)
 {
 	long shmem = (start_page - WD_START_PG)<<8;
 
@@ -837,10 +852,10 @@ static void word_memcpy_tocard(void *tp, const void *fp, int count)
 	const unsigned short *from = fp;
 
 	count++;
-	count/=2;
+	count /= 2;
 
-	while(count--)
-		*to++=*from++;
+	while (count--)
+		*to++ = *from++;
 }
 
 static void word_memcpy_fromcard(void *tp, const void *fp, int count)
@@ -849,10 +864,10 @@ static void word_memcpy_fromcard(void *tp, const void *fp, int count)
 	const volatile unsigned short *from = fp;
 
 	count++;
-	count/=2;
+	count /= 2;
 
-	while(count--)
-		*to++=*from++;
+	while (count--)
+		*to++ = *from++;
 }
 
 
-- 
1.6.6.rc0.57.gad7a

