From: Michael Neuling <mikey@neuling.org>
Subject: [PATCH] net: Fix ehea warning when built in
Date: Thu, 21 Nov 2013 15:36:49 +1100
Message-ID: <11586.1385008609@ale.ozlabs.ibm.com>
Mime-Version: 1.0
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: Jeff Mahoney <jeffm@suse.com>, Olaf Hering <ohering@suse.com>,
	Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:34103 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750906Ab3KUEgx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Nov 2013 23:36:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In:
  commit 7a3a62128388a6af771e99df8628ddee2e8be7ca
  Author: Olaf Hering <ohering@suse.com>
  drivers/net/ethernet/ibm/ehea/ehea_main.c: add alias entry for portN properties
We added ehea_module_device_table.  Unfortunately we only use this when
building as a module so we get the following warning when built in, like
in pseries_defconfig:

  drivers/net/ethernet/ibm/ehea/ehea_main.c:105:1: warning: 'ehea_module_device_table' defined but not used [-Wunused-variable]

This wraps ehea_module_device_table with #if MODULE.

Signed-off-by: Michael Neuling <mikey@neuling.org>

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 2d1c6bd..a17a1d1 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -102,6 +102,7 @@ static int ehea_probe_adapter(struct platform_device *dev);
 
 static int ehea_remove(struct platform_device *dev);
 
+#ifdef MODULE
 static struct of_device_id ehea_module_device_table[] = {
 	{
 		.name = "lhea",
@@ -114,6 +115,7 @@ static struct of_device_id ehea_module_device_table[] = {
 	{},
 };
 MODULE_DEVICE_TABLE(of, ehea_module_device_table);
+#endif
 
 static struct of_device_id ehea_device_table[] = {
 	{
