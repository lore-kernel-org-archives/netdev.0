From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 03/15] ehea: add alias entry for portN properties
Date: Tue,  7 May 2013 16:18:11 +0200
Message-ID: <1367936303-13386-3-git-send-email-jslaby@suse.cz>
References: <1367936303-13386-1-git-send-email-jslaby@suse.cz>
Cc: linux-kernel@vger.kernel.org, Olaf Hering <ohering@suse.com>,
	Jeff Mahoney <jeffm@suse.com>, Jiri Slaby <jslaby@suse.cz>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: jirislaby@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1367936303-13386-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olaf Hering <ohering@suse.com>

Use separate table for alias entries in the ehea module,
otherwise the probe() function will operate on the separate ports
instead of the lhea-"root" entry of the device-tree

References: https://bugzilla.novell.com/show_bug.cgi?id=435215
Signed-off-by: Jeff Mahoney <jeffm@suse.com>
Signed-off-by: Olaf Hering <ohering@suse.com>
Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 90ea0b1..1114418 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -103,6 +103,19 @@ static int ehea_probe_adapter(struct platform_device *dev,
 
 static int ehea_remove(struct platform_device *dev);
 
+static struct of_device_id ehea_module_device_table[] = {
+	{
+		.name = "lhea",
+		.compatible = "IBM,lhea",
+	},
+	{
+		.type = "network",
+		.compatible = "IBM,lhea-ethernet",
+	},
+	{},
+};
+MODULE_DEVICE_TABLE(of, ehea_module_device_table);
+
 static struct of_device_id ehea_device_table[] = {
 	{
 		.name = "lhea",
@@ -110,7 +123,6 @@ static struct of_device_id ehea_device_table[] = {
 	},
 	{},
 };
-MODULE_DEVICE_TABLE(of, ehea_device_table);
 
 static struct of_platform_driver ehea_driver = {
 	.driver = {
-- 
1.8.2.1
