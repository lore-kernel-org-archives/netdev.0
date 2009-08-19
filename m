From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/7] sky2: use upper/lower 32 bits
Date: Tue, 18 Aug 2009 18:17:05 -0700
Message-ID: <20090819011738.604718520@vyatta.com>
References: <20090819011704.685802801@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:50667 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750960AbZHSBWp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2009 21:22:45 -0400
Content-Disposition: inline; filename=sky2-upper32.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the existing macros to show where DMA address is being broken
apart. This is cosmetic only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2009-08-18 09:30:17.292586888 -0700
+++ b/drivers/net/sky2.c	2009-08-18 09:32:29.143195273 -0700
@@ -984,12 +984,12 @@ static void sky2_qset(struct sky2_hw *hw
  * hardware and driver list elements
  */
 static void sky2_prefetch_init(struct sky2_hw *hw, u32 qaddr,
-				      u64 addr, u32 last)
+			       dma_addr_t addr, u32 last)
 {
 	sky2_write32(hw, Y2_QADDR(qaddr, PREF_UNIT_CTRL), PREF_UNIT_RST_SET);
 	sky2_write32(hw, Y2_QADDR(qaddr, PREF_UNIT_CTRL), PREF_UNIT_RST_CLR);
-	sky2_write32(hw, Y2_QADDR(qaddr, PREF_UNIT_ADDR_HI), addr >> 32);
-	sky2_write32(hw, Y2_QADDR(qaddr, PREF_UNIT_ADDR_LO), (u32) addr);
+	sky2_write32(hw, Y2_QADDR(qaddr, PREF_UNIT_ADDR_HI), upper_32_bits(addr));
+	sky2_write32(hw, Y2_QADDR(qaddr, PREF_UNIT_ADDR_LO), lower_32_bits(addr));
 	sky2_write16(hw, Y2_QADDR(qaddr, PREF_UNIT_LAST_IDX), last);
 	sky2_write32(hw, Y2_QADDR(qaddr, PREF_UNIT_CTRL), PREF_UNIT_OP_ON);
 
@@ -1057,7 +1057,7 @@ static void sky2_rx_add(struct sky2_port
 	}
 
 	le = sky2_next_rx(sky2);
-	le->addr = cpu_to_le32((u32) map);
+	le->addr = cpu_to_le32(lower_32_bits(map));
 	le->length = cpu_to_le16(len);
 	le->opcode = op | HW_OWNER;
 }
@@ -1662,7 +1662,7 @@ static int sky2_xmit_frame(struct sk_buf
 	}
 
 	le = get_tx_le(sky2, &slot);
-	le->addr = cpu_to_le32((u32) mapping);
+	le->addr = cpu_to_le32(lower_32_bits(mapping));
 	le->length = cpu_to_le16(len);
 	le->ctrl = ctrl;
 	le->opcode = mss ? (OP_LARGESEND | HW_OWNER) : (OP_PACKET | HW_OWNER);
@@ -1689,7 +1689,7 @@ static int sky2_xmit_frame(struct sk_buf
 		}
 
 		le = get_tx_le(sky2, &slot);
-		le->addr = cpu_to_le32((u32) mapping);
+		le->addr = cpu_to_le32(lower_32_bits(mapping));
 		le->length = cpu_to_le16(frag->size);
 		le->ctrl = ctrl;
 		le->opcode = OP_BUFFER | HW_OWNER;

-- 

