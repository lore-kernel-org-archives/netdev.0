From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/5] drivers/net/mac8390.c: Remove useless memcpy casting
Date: Mon,  4 Jan 2010 13:53:00 -0800
Message-ID: <35a3fcfee9930e813c04387d922dd0cbdb5de14c.1262630406.git.joe@perches.com>
References: <cover.1262630406.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: Paul Gortmaker <p_gortmaker@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1490 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753380Ab0ADVxI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2010 16:53:08 -0500
In-Reply-To: <cover.1262630406.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/mac8390.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/mac8390.c b/drivers/net/mac8390.c
index 6b6f375..517cee4 100644
--- a/drivers/net/mac8390.c
+++ b/drivers/net/mac8390.c
@@ -237,14 +237,14 @@ static enum mac8390_access __init mac8390_testio(volatile unsigned long membase)
 	unsigned long outdata = 0xA5A0B5B0;
 	unsigned long indata =  0x00000000;
 	/* Try writing 32 bits */
-	memcpy((char *)membase, (char *)&outdata, 4);
+	memcpy(membase, &outdata, 4);
 	/* Now compare them */
 	if (memcmp((char *)&outdata, (char *)membase, 4) == 0)
 		return ACCESS_32;
 	/* Write 16 bit output */
-	word_memcpy_tocard((char *)membase, (char *)&outdata, 4);
+	word_memcpy_tocard(membase, &outdata, 4);
 	/* Now read it back */
-	word_memcpy_fromcard((char *)&indata, (char *)membase, 4);
+	word_memcpy_fromcard(&indata, membase, 4);
 	if (outdata == indata)
 		return ACCESS_16;
 	return ACCESS_UNKNOWN;
@@ -759,7 +759,7 @@ static void dayna_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr
 {
 	unsigned long hdr_start = (ring_page - WD_START_PG)<<8;
 
-	dayna_memcpy_fromcard(dev, (void *)hdr, hdr_start, 4);
+	dayna_memcpy_fromcard(dev, hdr, hdr_start, 4);
 	/* Fix endianness */
 	hdr->count=(hdr->count&0xFF)<<8|(hdr->count>>8);
 }
@@ -801,7 +801,7 @@ static void slow_sane_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr
 	int ring_page)
 {
 	unsigned long hdr_start = (ring_page - WD_START_PG)<<8;
-	word_memcpy_fromcard((void *)hdr, (char *)dev->mem_start+hdr_start, 4);
+	word_memcpy_fromcard(hdr, (char *)dev->mem_start + hdr_start, 4);
 	/* Register endianism - fix here rather than 8390.c */
 	hdr->count = (hdr->count&0xFF)<<8|(hdr->count>>8);
 }
@@ -816,16 +816,17 @@ static void slow_sane_block_input(struct net_device *dev, int count, struct sk_b
 	{
 		/* We must wrap the input move. */
 		int semi_count = ei_status.rmem_end - xfer_start;
-		word_memcpy_fromcard(skb->data, (char *)dev->mem_start +
-			xfer_base, semi_count);
+		word_memcpy_fromcard(skb->data,
+				     (char *)dev->mem_start + xfer_base,
+				     semi_count);
 		count -= semi_count;
 		word_memcpy_fromcard(skb->data + semi_count,
 				     (char *)ei_status.rmem_start, count);
 	}
 	else
 	{
-		word_memcpy_fromcard(skb->data, (char *)dev->mem_start +
-			xfer_base, count);
+		word_memcpy_fromcard(skb->data,
+				     (char *)dev->mem_start + xfer_base, count);
 	}
 }
 
-- 
1.6.6.rc0.57.gad7a

