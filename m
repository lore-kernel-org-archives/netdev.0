From: akpm@linux-foundation.org
Subject: [patch 1/4] drivers/net/ethernet/ibm/ehea/ehea_main.c: add alias entry for portN properties
Date: Fri, 13 Sep 2013 14:52:01 -0700
Message-ID: <20130913215201.6501131C1BF@corp2gmr1-1.hot.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ASCII
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	ohering@suse.com, cascardo@linux.vnet.ibm.com, jeffm@suse.com,
	jslaby@suse.cz
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f73.google.com ([209.85.213.73]:58947 "EHLO
	mail-yh0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754860Ab3IMWSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 18:18:36 -0400
Received: by mail-yh0-f73.google.com with SMTP id z20so230185yhz.4
        for <netdev@vger.kernel.org>; Fri, 13 Sep 2013 15:18:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Olaf Hering <ohering@suse.com>
Subject: drivers/net/ethernet/ibm/ehea/ehea_main.c: add alias entry for portN properties

Use separate table for alias entries in the ehea module, otherwise the
probe() function will operate on the separate ports instead of the
lhea-"root" entry of the device-tree

Addresses https://bugzilla.novell.com/show_bug.cgi?id=435215

Signed-off-by: Jeff Mahoney <jeffm@suse.com>
Signed-off-by: Olaf Hering <ohering@suse.com>
Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/ethernet/ibm/ehea/ehea_main.c |   14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff -puN drivers/net/ethernet/ibm/ehea/ehea_main.c~drivers-net-ethernet-ibm-ehea-ehea_mainc-add-alias-entry-for-portn-properties drivers/net/ethernet/ibm/ehea/ehea_main.c
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c~drivers-net-ethernet-ibm-ehea-ehea_mainc-add-alias-entry-for-portn-properties
+++ a/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -102,6 +102,19 @@ static int ehea_probe_adapter(struct pla
 
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
@@ -109,7 +122,6 @@ static struct of_device_id ehea_device_t
 	},
 	{},
 };
-MODULE_DEVICE_TABLE(of, ehea_device_table);
 
 static struct platform_driver ehea_driver = {
 	.driver = {
_
