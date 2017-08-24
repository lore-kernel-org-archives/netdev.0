From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 1/4] net: mvpp2: fix the mac address used when using PPv2.2
Date: Thu, 24 Aug 2017 11:46:55 +0200
Message-ID: <20170824094658.1296-2-antoine.tenart@free-electrons.com>
References: <20170824094658.1296-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org
To: davem@davemloft.net, thomas.petazzoni@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170824094658.1296-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The mac address is only retrieved from h/w when using PPv2.1. Otherwise
the variable holding it is still checked and used if it contains a valid
value. As the variable isn't initialized to an invalid mac address
value, we end up with random mac addresses which can be the same for all
the ports handled by this PPv2 driver.

Fixes this by initializing the h/w mac address variable to {0}, which is
an invalid mac address value. This way the random assignation fallback
is called and all ports end up with their own addresses.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
Fixes: 2697582144dd ("net: mvpp2: handle misc PPv2.1/PPv2.2 differences")
---
 drivers/net/ethernet/marvell/mvpp2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 3f8cbc070dc4..50a0920d3282 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -7466,7 +7466,7 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 	struct resource *res;
 	const char *dt_mac_addr;
 	const char *mac_from;
-	char hw_mac_addr[ETH_ALEN];
+	char hw_mac_addr[ETH_ALEN] = {0};
 	unsigned int ntxqs, nrxqs;
 	bool has_tx_irqs;
 	u32 id;
-- 
2.13.5
