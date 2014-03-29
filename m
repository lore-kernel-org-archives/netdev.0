From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 14/17] qlge: remove open-coded skb_cow_head.
Date: Sat, 29 Mar 2014 12:26:27 +0100
Message-ID: <925e6f02583e265bad78e85cad80766981001ff1.1396090802.git.romieu@fr.zoreil.com>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
Cc: netdev@vger.kernel.org,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60876 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643AbaC2L0w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 07:26:52 -0400
In-Reply-To: <cover.1396090802.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1396090802.git.romieu@fr.zoreil.com>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Cc: Shahed Shaikh <shahed.shaikh@qlogic.com>
Cc: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index adf87d2..5b63405 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -2556,11 +2556,10 @@ static int ql_tso(struct sk_buff *skb, struct ob_mac_tso_iocb_req *mac_iocb_ptr)
 
 	if (skb_is_gso(skb)) {
 		int err;
-		if (skb_header_cloned(skb)) {
-			err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-			if (err)
-				return err;
-		}
+
+		err = skb_cow_head(skb, 0);
+		if (err < 0)
+			return err;
 
 		mac_iocb_ptr->opcode = OPCODE_OB_MAC_TSO_IOCB;
 		mac_iocb_ptr->flags3 |= OB_MAC_TSO_IOCB_IC;
-- 
1.9.0
