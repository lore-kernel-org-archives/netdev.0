From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH v2] can: sja1000: fix compilation on x86
Date: Fri, 14 Dec 2012 23:25:12 +0100
Message-ID: <1355523912-1977-1-git-send-email-mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org, rdunlap@infradead.org,
	davem@davemloft.net, Marc Kleine-Budde <mkl@pengutronix.de>,
	Andreas Larsson <andreas@gaisler.com>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since commit:
04df251 can: sja1000: Make sja1000_of_platform selectable and compilable on SPARC
the driver can be activated on non powerpc platform like x86 or sparc. Without
this patch the driver fails to compile on platform that don't define NO_IRQ,
like x86.

Reported-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Andreas Larsson <andreas@gaisler.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---

Hello David,

here's v2 of the patch.

Changes since v1:
* check if irq equals 0 (don't test for <= 0)

regards,
Marc

---

The following changes since commit 17bc14b767cf0692420c43dbe5310ae98a5a7836:

  Revert "sched: Update_cfs_shares at period edge" (2012-12-14 07:20:43 -0800)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can.git fixes-for-3.8

for you to fetch changes up to b9b325a81c77adc5d735b70a6fce6fb6d1317476:

  can: sja1000: fix compilation on x86 (2012-12-14 23:17:24 +0100)

----------------------------------------------------------------
Marc Kleine-Budde (1):
      can: sja1000: fix compilation on x86

 drivers/net/can/sja1000/sja1000_of_platform.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/sja1000/sja1000_of_platform.c b/drivers/net/can/sja1000/sja1000_of_platform.c
index 0f59170..6433b81 100644
--- a/drivers/net/can/sja1000/sja1000_of_platform.c
+++ b/drivers/net/can/sja1000/sja1000_of_platform.c
@@ -121,7 +121,7 @@ static int sja1000_ofp_probe(struct platform_device *ofdev)
 	}
 
 	irq = irq_of_parse_and_map(np, 0);
-	if (irq == NO_IRQ) {
+	if (irq == 0) {
 		dev_err(&ofdev->dev, "no irq found\n");
 		err = -ENODEV;
 		goto exit_unmap_mem;
-- 
1.7.10.4

