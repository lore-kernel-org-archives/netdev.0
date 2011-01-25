From: Thomas Chou <thomas-SDxUXYEhEBiCuPEqFHbRBg@public.gmane.org>
Subject: [PATCH v2] smc91x: add devicetree support
Date: Tue, 25 Jan 2011 15:09:59 +0800
Message-ID: <1295939399-4197-1-git-send-email-thomas@wytron.com.tw>
References: <AANLkTikgsqJqdW2qh7h4yATCmGFb5MkHCosma_DOBq-Y@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	nios2-dev-1eJk0qcHJCcaeqlQEoCUNoJY59XmG8rH@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>, Nicolas Pitre <nico-vtqb6HGKxmzR7s880joybQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <AANLkTikgsqJqdW2qh7h4yATCmGFb5MkHCosma_DOBq-Y-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Chou <thomas-SDxUXYEhEBiCuPEqFHbRBg@public.gmane.org>
---
v2 specify part numbers in compat as Grant suggested.

 drivers/net/smc91x.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 726df61..de48ebd 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -81,6 +81,7 @@ static const char version[] =
 #include <linux/ethtool.h>
 #include <linux/mii.h>
 #include <linux/workqueue.h>
+#include <linux/of.h>
 
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -2394,6 +2395,13 @@ static int smc_drv_resume(struct device *dev)
 	return 0;
 }
 
+static const struct of_device_id smc91x_match[] = {
+	{ .compatible = "smsc,smc91c94", },
+	{ .compatible = "smsc,smc91c111", },
+	{},
+}
+MODULE_DEVICE_TABLE(of, smc91x_match);
+
 static struct dev_pm_ops smc_drv_pm_ops = {
 	.suspend	= smc_drv_suspend,
 	.resume		= smc_drv_resume,
@@ -2406,6 +2414,9 @@ static struct platform_driver smc_driver = {
 		.name	= CARDNAME,
 		.owner	= THIS_MODULE,
 		.pm	= &smc_drv_pm_ops,
+#ifdef CONFIG_OF
+		.of_match_table = smc91x_match,
+#endif
 	},
 };
 
-- 
1.7.3.5
