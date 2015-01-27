From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1] stmmac: prevent probe drivers to crash kernel
Date: Tue, 27 Jan 2015 18:38:03 +0200
Message-ID: <1422376683-30555-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:23605 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750982AbbA0QiE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2015 11:38:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the case when alloc_netdev fails we return NULL to a caller. But there is no
check for NULL in the probe drivers. This patch changes NULL to an error
pointer. The function description is amended to reflect what we may get
returned.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 8c6b7c1..cf62ff4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2778,6 +2778,9 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
  * @addr: iobase memory address
  * Description: this is the main probe function used to
  * call the alloc_etherdev, allocate the priv structure.
+ * Return:
+ * on success the new private structure is returned, otherwise the error
+ * pointer.
  */
 struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 				     struct plat_stmmacenet_data *plat_dat,
@@ -2789,7 +2792,7 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 
 	ndev = alloc_etherdev(sizeof(struct stmmac_priv));
 	if (!ndev)
-		return NULL;
+		return ERR_PTR(-ENOMEM);
 
 	SET_NETDEV_DEV(ndev, device);
 
-- 
2.1.4
