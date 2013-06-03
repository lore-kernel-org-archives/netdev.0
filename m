From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net] bnx2x: Fix bridged GSO for 57710/57711 chips
Date: Mon, 3 Jun 2013 15:59:57 +0300
Message-ID: <1370264397-27324-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Ariel Elior" <ariele@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3896 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753720Ab3FCNAN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 09:00:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It was recently found out that GSO on 57710/57711 was broken, due to packets
being sent without a valid IP checksum. 

Commit 057cf65 "bnx2x: Fix GSO for 57710/57711 chips" partially fixed this
issue, but failed to set the correct IP checksum when receiving GSO packets
via bridges, as such packets enter bnx2x_tx_split() and the FW flags needed
to calculate IP checksum were erroneously set in the incorrect
buffer descriptor.

This patch re-enables GSO in said scenario for 57710/57711 chips.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
Hi Dave,

Please consider applying this to `net'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index be59ec4..c937260 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3818,8 +3818,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			bnx2x_set_pbd_gso_e2(skb, &pbd_e2_parsing_data,
 					     xmit_type);
 		else
-			bnx2x_set_pbd_gso(skb, pbd_e1x, tx_start_bd,
-					  xmit_type);
+			bnx2x_set_pbd_gso(skb, pbd_e1x, first_bd, xmit_type);
 	}
 
 	/* Set the PBD's parsing_data field if not zero
-- 
1.8.1.227.g44fe835
