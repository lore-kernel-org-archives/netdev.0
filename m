From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 2/2] bonding: use the correct ether type for alb
Date: Thu, 13 Mar 2014 12:41:58 +0100
Message-ID: <1394710918-29540-3-git-send-email-vfalico@redhat.com>
References: <1394710918-29540-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51131 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753952AbaCMLqR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Mar 2014 07:46:17 -0400
In-Reply-To: <1394710918-29540-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently it's using the wrong ETH_P_LOOP type, which is sometimes treated
as packet length instead of ether type (because it's 0x0060).

Use the new ETH_P_LOOPBACK type.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_alb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 9cf836b6..060b611 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1005,7 +1005,7 @@ static void alb_send_lp_vid(struct slave *slave, u8 mac_addr[],
 	memset(&pkt, 0, size);
 	ether_addr_copy(pkt.mac_dst, mac_addr);
 	ether_addr_copy(pkt.mac_src, mac_addr);
-	pkt.type = cpu_to_be16(ETH_P_LOOP);
+	pkt.type = cpu_to_be16(ETH_P_LOOPBACK);
 
 	skb = dev_alloc_skb(size);
 	if (!skb)
-- 
1.8.4
