From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH net-next] ethernet: mvneta: Use PHY status standard message
Date: Fri, 31 Oct 2014 12:57:20 -0300
Message-ID: <1414771040-7789-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Nadav Haklai <nadavh@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>, <netdev@vger.kernel.org>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:43439 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756585AbaJaP7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 11:59:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use phy_print_status() to report a change in the PHY status.
The current message is not verbose enough, so this commit improves
it by using the generic status message.

After this change, the kernel reports PHY status down and up events as:

mvneta f1070000.ethernet eth0: Link is Down
mvneta f1070000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index ade067d..ccc3ce2 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2558,11 +2558,10 @@ static void mvneta_adjust_link(struct net_device *ndev)
 				MVNETA_GMAC_FORCE_LINK_DOWN);
 			mvreg_write(pp, MVNETA_GMAC_AUTONEG_CONFIG, val);
 			mvneta_port_up(pp);
-			netdev_info(pp->dev, "link up\n");
 		} else {
 			mvneta_port_down(pp);
-			netdev_info(pp->dev, "link down\n");
 		}
+		phy_print_status(phydev);
 	}
 }
 
-- 
2.1.0
