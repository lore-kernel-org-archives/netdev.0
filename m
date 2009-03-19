From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH -next] fsl_pq_mdio: Revive Gianfar TBI PHY support
Date: Thu, 19 Mar 2009 18:52:32 +0300
Message-ID: <20090319155232.GA5419@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>,
	linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

commit 1577ecef766650a57fceb171acee2b13cbfaf1d3 ("netdev: Merge UCC
and gianfar MDIO bus drivers") broke the TSEC TBI PHY support: the
driver now refuses to probe TBI MDIO buses as it doesn't know about
"fsl,gianfar-tbi" compatible entry, and thus _probe() fails with
-ENODEV status.

Fix this by adding "fsl,gianfar-tbi" to the list of known Gianfar
MDIO buses.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/fsl_pq_mdio.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/fsl_pq_mdio.c b/drivers/net/fsl_pq_mdio.c
index b0ce144..6be36b9 100644
--- a/drivers/net/fsl_pq_mdio.c
+++ b/drivers/net/fsl_pq_mdio.c
@@ -321,6 +321,7 @@ static int fsl_pq_mdio_probe(struct of_device *ofdev,
 	dev_set_drvdata(&ofdev->dev, new_bus);
 
 	if (of_device_is_compatible(np, "fsl,gianfar-mdio") ||
+			of_device_is_compatible(np, "fsl,gianfar-tbi") ||
 			of_device_is_compatible(np, "gianfar")) {
 #ifdef CONFIG_GIANFAR
 		tbipa = get_gfar_tbipa(regs);
-- 
1.5.6.5
