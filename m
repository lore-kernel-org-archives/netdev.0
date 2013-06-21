From: Christoph =?iso-8859-1?Q?M=FCllner?=
	<christoph.muellner@theobroma-systems.com>
Subject: [PATCH] net: fec: Fix multicast list setup in fec_restart().
Date: Fri, 21 Jun 2013 18:40:55 +0200 (CEST)
Message-ID: <61455.62.178.124.14.1371832855.squirrel@mail.theobroma-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Grant Likely" <grant.likely@linaro.org>,
	"Rob Herring" <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Fabio Estevam" <fabio.estevam@freescale.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Setup the multicast list of the net_device instead of
clearing it blindly. This restores the multicast groups
in case of a link down/up event.

Signed-off-by: Christoph Muellner <christoph.muellner@theobroma-systems.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c
b/drivers/net/ethernet/freescale/fec_main.c
index a667015..8e8e743 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -60,6 +60,8 @@

 #include "fec.h"

+static void set_multicast_list(struct net_device *ndev);
+
 #if defined(CONFIG_ARM)
 #define FEC_ALIGNMENT  0xf
 #else
@@ -472,8 +474,7 @@ fec_restart(struct net_device *ndev, int duplex)
        writel(0xffc00000, fep->hwp + FEC_IEVENT);

        /* Reset all multicast. */
-       writel(0, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
-       writel(0, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
+       set_multicast_list(ndev);
 #ifndef CONFIG_M5272
        writel(0, fep->hwp + FEC_HASH_TABLE_HIGH);
        writel(0, fep->hwp + FEC_HASH_TABLE_LOW);
-- 
1.7.4.1
