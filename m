From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 09/14] net: dsa: use list_for_each_entry
Date: Fri, 18 Dec 2015 23:33:33 +0800
Message-ID: <e7b129a2c202cec7f38f9b30bafee2afb0c96f2b.1450451516.git.geliangtang@163.com>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Armstrong <narmstrong@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
In-Reply-To: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use list_for_each_entry() instead of list_for_each() to simplify
the code.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 net/dsa/dsa.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 208d1b2..2ab4a19 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -53,19 +53,14 @@ EXPORT_SYMBOL_GPL(unregister_switch_driver);
 static struct dsa_switch_driver *
 dsa_switch_probe(struct device *host_dev, int sw_addr, char **_name)
 {
-	struct dsa_switch_driver *ret;
-	struct list_head *list;
+	struct dsa_switch_driver *ret, *drv;
 	char *name;
 
 	ret = NULL;
 	name = NULL;
 
 	mutex_lock(&dsa_switch_drivers_mutex);
-	list_for_each(list, &dsa_switch_drivers) {
-		struct dsa_switch_driver *drv;
-
-		drv = list_entry(list, struct dsa_switch_driver, list);
-
+	list_for_each_entry(drv, &dsa_switch_drivers, list) {
 		name = drv->probe(host_dev, sw_addr);
 		if (name != NULL) {
 			ret = drv;
-- 
2.5.0
