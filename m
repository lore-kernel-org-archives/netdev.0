From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 02/25] net: mvneta: Improve two size determinations in
 mvneta_init()
Date: Mon, 17 Apr 2017 17:10:22 +0200
Message-ID: <34ff173b-9727-ff30-677b-f27c54c7c0bd@users.sourceforge.net>
References: <d6f26bba-c678-5b66-4f5d-85f56d895190@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Jarod Wilson <jarod@redhat.com>,
        Jisheng Zhang <jszhang@marvell.com>,
        Mirko Lindner <mlindner@marvell.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Russell King <rmk+kernel@armlinux.org.uk>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([217.72.192.78]:53298 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753427AbdDQPKo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Apr 2017 11:10:44 -0400
In-Reply-To: <d6f26bba-c678-5b66-4f5d-85f56d895190@users.sourceforge.net>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 16 Apr 2017 21:45:38 +0200

Replace the specification of two data structures by pointer dereferences
as the parameter for the operator "sizeof" to make the corresponding size
determination a bit safer according to the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/mvneta.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 46fa74e93814..9c9eed5a8e28 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -3992,8 +3992,7 @@ static int mvneta_init(struct device *dev, struct mvneta_port *pp)
 	/* Set port default values */
 	mvneta_defaults_set(pp);
 
-	pp->txqs = devm_kcalloc(dev, txq_number, sizeof(struct mvneta_tx_queue),
-				GFP_KERNEL);
+	pp->txqs = devm_kcalloc(dev, txq_number, sizeof(*pp->txqs), GFP_KERNEL);
 	if (!pp->txqs)
 		return -ENOMEM;
 
@@ -4005,8 +4004,7 @@ static int mvneta_init(struct device *dev, struct mvneta_port *pp)
 		txq->done_pkts_coal = MVNETA_TXDONE_COAL_PKTS;
 	}
 
-	pp->rxqs = devm_kcalloc(dev, rxq_number, sizeof(struct mvneta_rx_queue),
-				GFP_KERNEL);
+	pp->rxqs = devm_kcalloc(dev, rxq_number, sizeof(*pp->rxqs), GFP_KERNEL);
 	if (!pp->rxqs)
 		return -ENOMEM;
 
-- 
2.12.2
