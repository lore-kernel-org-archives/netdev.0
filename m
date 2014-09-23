From: Mark Einon <mark.einon@gmail.com>
Subject: [PATCH 4/4] staging: et131x: Remove unnecessary defines to enable
 driver PM
Date: Tue, 23 Sep 2014 20:41:14 +0100
Message-ID: <1411501274-2970-4-git-send-email-mark.einon@gmail.com>
References: <20140923100106.GE4657@distanz.ch>
 <1411501274-2970-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Mark Einon <mark.einon@gmail.com>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1411501274-2970-1-git-send-email-mark.einon@gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

The Power Management functions can be conditional by assigning pm ops
directly to .driver.pm, instead of using #ifdef's, saving some lines of
code.

Reported-by: Tobias Klauser <tklauser@distanz.ch>
Signed-off-by: Mark Einon <mark.einon@gmail.com>
---
 drivers/staging/et131x/et131x.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/et131x/et131x.c b/drivers/staging/et131x/et131x.c
index 10f20b3..41fcaa0 100644
--- a/drivers/staging/et131x/et131x.c
+++ b/drivers/staging/et131x/et131x.c
@@ -3607,12 +3607,9 @@ static int et131x_resume(struct device *dev)
 
 	return 0;
 }
+#endif
 
 static SIMPLE_DEV_PM_OPS(et131x_pm_ops, et131x_suspend, et131x_resume);
-#define ET131X_PM_OPS (&et131x_pm_ops)
-#else
-#define ET131X_PM_OPS NULL
-#endif
 
 /* et131x_isr - The Interrupt Service Routine for the driver.
  * @irq: the IRQ on which the interrupt was received.
@@ -4406,7 +4403,7 @@ static struct pci_driver et131x_driver = {
 	.id_table	= et131x_pci_table,
 	.probe		= et131x_pci_setup,
 	.remove		= et131x_pci_remove,
-	.driver.pm	= ET131X_PM_OPS,
+	.driver.pm	= &et131x_pm_ops,
 };
 
 module_pci_driver(et131x_driver);
-- 
2.1.0
