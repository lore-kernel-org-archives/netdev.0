From: Jeff Mahoney <jeffm@suse.com>
Subject: [PATCH] ehea: add alias entry for portN properties
Date: Wed, 02 May 2012 14:26:22 -0400
Message-ID: <4FA17C4E.1030905@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	Olaf Hering <ohering@suse.com>
To: Breno Leitao <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:41942 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755697Ab2EBS02 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2012 14:26:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use separate table for alias entries in the ehea module,
otherwise the probe() function will operate on the separate ports
instead of the lhea-"root" entry of the device-tree

Initially reported here:
https://bugzilla.novell.com/show_bug.cgi?id=435215

Signed-off-by: Jeff Mahoney <jeffm@suse.com>
Signed-off-by: Olaf Hering <ohering@suse.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c |   14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -103,6 +103,19 @@ static int __devinit ehea_probe_adapter(
 
 static int __devexit ehea_remove(struct platform_device *dev);
 
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
@@ -110,7 +123,6 @@ static struct of_device_id ehea_device_t
 	},
 	{},
 };
-MODULE_DEVICE_TABLE(of, ehea_device_table);
 
 static struct of_platform_driver ehea_driver = {
 	.driver = {
-- 
Jeff Mahoney
SUSE Labs
