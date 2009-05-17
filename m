From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 1/3] drivers/net: use dev_get_drvdata
Date: Sun, 17 May 2009 11:28:42 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0905171128140.20440@pc-004.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: yi.zhu@intel.com, reinette.chatre@intel.com,
	linux-wireless@vger.kernel.org,
	ipw3945-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:59778 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753317AbZEQJ2y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 May 2009 05:28:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

Eliminate direct accesses to the driver_data field.
cf 82ab13b26f15f49be45f15ccc96bfa0b81dfd015

The semantic patch that makes this change is as follows:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@@
struct device *dev;
expression E;
type T;
@@

- dev->driver_data = (T)E
+ dev_set_drvdata(dev, E)

@@
struct device *dev;
type T;
@@

- (T)dev->driver_data
+ dev_get_drvdata(dev)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/wireless/iwlwifi/iwl-agn.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -u -p a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -2478,7 +2478,7 @@ static DEVICE_ATTR(power_level, S_IWUSR 
 static ssize_t show_qos(struct device *d,
 				struct device_attribute *attr, char *buf)
 {
-	struct iwl_priv *priv = (struct iwl_priv *)d->driver_data;
+	struct iwl_priv *priv = dev_get_drvdata(d);
 	char *p = buf;
 	int   q;
 
