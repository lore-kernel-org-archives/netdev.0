From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH net-next] net: sxgbe: fix sparse warnings about static
 declaration
Date: Fri, 28 Mar 2014 10:57:36 -0700
Message-ID: <031b01cf4aaf$35e1b3b0$a1a51b10$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'David Miller' <davem@davemloft.net>,
	'kbuild test robot' <fengguang.wu@intel.com>,
	'Girish K S' <ks.giri@samsung.com>,
	'Siva Reddy' <siva.kallam@samsung.com>,
	'Vipul Pandya' <vipul.pandya@samsung.com>
To: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Content-language: en-us
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Byungho An <bh74.an@samsung.com>

This fixes followings:

sparse warnings: (new ones prefixed by >>)

>> drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c:197:5: 
sparse: symbol 'sxgbe_platform_freeze' was not declared. Should it be static?
>> drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c:204:5: 
sparse: symbol 'sxgbe_platform_restore' was not declared. Should it be static?
>> drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c:228:24: 
sparse: symbol 'sxgbe_platform_driver' was not declared. Should it be static?

>> drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c:1795:6: 
sparse: symbol 'sxgbe_get_ops' was not declared. Should it be static?

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c     |    2 +-
 drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index 1869d4c6..ee1fd3c 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -2013,7 +2013,7 @@ static const struct net_device_ops sxgbe_netdev_ops = {
 };
 
 /* Get the hardware ops */
-void sxgbe_get_ops(struct sxgbe_ops * const ops_ptr)
+static void sxgbe_get_ops(struct sxgbe_ops * const ops_ptr)
 {
 	ops_ptr->mac		= sxgbe_get_core_ops();
 	ops_ptr->desc		= sxgbe_get_desc_ops();
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c
index 94c2cd7..b147d46 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c
@@ -200,14 +200,14 @@ static int sxgbe_platform_resume(struct device *dev)
 	return sxgbe_resume(ndev);
 }
 
-int sxgbe_platform_freeze(struct device *dev)
+static int sxgbe_platform_freeze(struct device *dev)
 {
 	struct net_device *ndev = dev_get_drvdata(dev);
 
 	return sxgbe_freeze(ndev);
 }
 
-int sxgbe_platform_restore(struct device *dev)
+static int sxgbe_platform_restore(struct device *dev)
 {
 	struct net_device *ndev = dev_get_drvdata(dev);
 
@@ -231,7 +231,7 @@ static const struct of_device_id sxgbe_dt_ids[] = {
 };
 MODULE_DEVICE_TABLE(of, sxgbe_dt_ids);
 
-struct platform_driver sxgbe_platform_driver = {
+static struct platform_driver sxgbe_platform_driver = {
 	.probe	= sxgbe_platform_probe,
 	.remove	= sxgbe_platform_remove,
 	.driver	= {
-- 
1.7.10.4
