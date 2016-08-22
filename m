From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] liquidio: declare liquidio_set_rxcsum_command static
Date: Mon, 22 Aug 2016 17:45:39 +0200
Message-ID: <1471880739-8870-1-git-send-email-hofrat@osadl.org>
Cc: Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Nicholas Mc Guire <hofrat@osadl.org>
To: Derek Chickles <derek.chickles@caviumnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

liquidio_set_rxcsum_command is a local function only, no need to expose it outside of lio_main.c
so declare it static and make sparse happy.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Detected by sparse:
  CHECK   drivers/net/ethernet/cavium/liquidio/lio_main.c
drivers/net/ethernet/cavium/liquidio/lio_main.c:3193:5: warning: symbol 
'liquidio_set_rxcsum_command' was not declared. Should it be static?

Patch was compile tested with: x86_64_defconfig + CONFIG_LIQUIDIO=m

Patch is against 4.8.0-rc2 (localversion-next is -next-20160822)

 drivers/net/ethernet/cavium/liquidio/lio_main.c | 2 +-
 1 file changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index bdd6c82..184f1ac 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -3190,7 +3190,7 @@ static int liquidio_vlan_rx_kill_vid(struct net_device *netdev,
  *                              OCTNET_CMD_RXCSUM_DISABLE
  * @returns                     SUCCESS or FAILURE
  */
-int liquidio_set_rxcsum_command(struct net_device *netdev, int command,
+static int liquidio_set_rxcsum_command(struct net_device *netdev, int command,
 				u8 rx_cmd)
 {
 	struct lio *lio = GET_LIO(netdev);
-- 
2.1.4
