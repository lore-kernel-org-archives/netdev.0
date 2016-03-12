From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH net v2 4/4] net: mvneta: replace magic numbers by existing macros
Date: Sat, 12 Mar 2016 18:44:20 +0100
Message-ID: <1457804660-8463-5-git-send-email-gregory.clement@free-electrons.com>
References: <1457804660-8463-1-git-send-email-gregory.clement@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Patrick Uiterwijk <patrick@puiterwijk.org>,
	Dimitri Epshtein <dima@marvell.com>,
	Ofer Heifetz <oferh@marvell.com>
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:54439 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752270AbcCLRoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2016 12:44:37 -0500
In-Reply-To: <1457804660-8463-1-git-send-email-gregory.clement@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitri Epshtein <dima@marvell.com>

Some literal values are actually already defined by macros, so let's use
them.

[gregory.clement@free-electrons.com: split intial commit in two
individual changes]
Signed-off-by: Dmitri Epshtein <dima@marvell.com>
Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 58ad36876e8b..225d933259c0 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -880,7 +880,7 @@ static void mvneta_port_down(struct mvneta_port *pp)
 		mdelay(1);
 
 		val = mvreg_read(pp, MVNETA_RXQ_CMD);
-	} while (val & 0xff);
+	} while (val & MVNETA_RXQ_ENABLE_MASK);
 
 	/* Stop Tx port activity. Check port Tx activity. Issue stop
 	 * command for active channels only
@@ -905,7 +905,7 @@ static void mvneta_port_down(struct mvneta_port *pp)
 		/* Check TX Command reg that all Txqs are stopped */
 		val = mvreg_read(pp, MVNETA_TXQ_CMD);
 
-	} while (val & 0xff);
+	} while (val & MVNETA_TXQ_ENABLE_MASK);
 
 	/* Double check to verify that TX FIFO is empty */
 	count = 0;
-- 
2.5.0
