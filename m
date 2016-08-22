From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH V2] liquidio: declare liquidio_set_rxcsum_command static
Date: Mon, 22 Aug 2016 17:52:00 +0200
Message-ID: <1471881120-10232-1-git-send-email-hofrat@osadl.org>
Cc: Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Nicholas Mc Guire <hofrat@osadl.org>
To: Derek Chickles <derek.chickles@caviumnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

liquidio_set_rxcsum_command is a local function only, no need to expose
it outside of lio_main.c so declare it static and make sparse happy.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

V2: forgot to fix up the checkpatch.pl warnings...

Detected by sparse:
  CHECK   drivers/net/ethernet/cavium/liquidio/lio_main.c
drivers/net/ethernet/cavium/liquidio/lio_main.c:3193:5: warning: symbol
'liquidio_set_rxcsum_command' was not declared. Should it be static?

Patch was compile tested with: x86_64_defconfig + CONFIG_LIQUIDIO=m

Patch is against 4.8.0-rc2 (localversion-next is -next-20160822)

 drivers/net/ethernet/cavium/liquidio/lio_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 20d6942..f659a95 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -3190,8 +3190,8 @@ static int liquidio_vlan_rx_kill_vid(struct net_device *netdev,
  *                              OCTNET_CMD_RXCSUM_DISABLE
  * @returns                     SUCCESS or FAILURE
  */
-int liquidio_set_rxcsum_command(struct net_device *netdev, int command,
-				u8 rx_cmd)
+static int liquidio_set_rxcsum_command(struct net_device *netdev, int command,
+				       u8 rx_cmd)
 {
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct = lio->oct_dev;
-- 
2.1.4
