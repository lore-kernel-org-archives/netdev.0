From: David Daney <david.daney@cavium.com>
Subject: [PATCH] staging: octeon-ethernet: Fix compile error caused by changed to struct skb_frag_struct.
Date: Mon,  7 Nov 2011 12:49:30 -0800
Message-ID: <1320698970-1854-1-git-send-email-david.daney@cavium.com>
Cc: ddaney.cavm@gmail.com, David Daney <david.daney@cavium.com>
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de, devel@driverdev.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:4079 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752301Ab1KGUtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 15:49:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evidently the definition of struct skb_frag_struct has changed, so we
need to change to match it.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/staging/octeon/ethernet-tx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/octeon/ethernet-tx.c b/drivers/staging/octeon/ethernet-tx.c
index b445cd6..2542c37 100644
--- a/drivers/staging/octeon/ethernet-tx.c
+++ b/drivers/staging/octeon/ethernet-tx.c
@@ -275,7 +275,7 @@ int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev)
 		CVM_OCT_SKB_CB(skb)[0] = hw_buffer.u64;
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 			struct skb_frag_struct *fs = skb_shinfo(skb)->frags + i;
-			hw_buffer.s.addr = XKPHYS_TO_PHYS((u64)(page_address(fs->page) + fs->page_offset));
+			hw_buffer.s.addr = XKPHYS_TO_PHYS((u64)(page_address(fs->page.p) + fs->page_offset));
 			hw_buffer.s.size = fs->size;
 			CVM_OCT_SKB_CB(skb)[i + 1] = hw_buffer.u64;
 		}
-- 
1.7.2.3
