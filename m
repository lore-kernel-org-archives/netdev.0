From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 23/27] drivers/infiniband/of: don't use deprecated fields in
	of_platform_driver
Date: Thu, 11 Mar 2010 11:23:55 -0700
Message-ID: <20100311182354.13103.40771.stgit__21306.3171752312$1268331967$gmane$org@angua>
References: <20100311181604.13103.30088.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:52515 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934248Ab0CKSX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:23:58 -0500
In-Reply-To: <20100311181604.13103.30088.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.name, .match_table and .owner are duplicated in both of_platform_driver
and device_driver, so the of_platform_driver copies will be removed soon.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/infiniband/hw/ehca/ehca_main.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/hw/ehca/ehca_main.c b/drivers/infiniband/hw/ehca/ehca_main.c
index 2639185..252489e 100644
--- a/drivers/infiniband/hw/ehca/ehca_main.c
+++ b/drivers/infiniband/hw/ehca/ehca_main.c
@@ -937,12 +937,13 @@ static struct of_device_id ehca_device_table[] =
 MODULE_DEVICE_TABLE(of, ehca_device_table);
 
 static struct of_platform_driver ehca_driver = {
-	.name        = "ehca",
-	.match_table = ehca_device_table,
 	.probe       = ehca_probe,
 	.remove      = ehca_remove,
-	.driver	     = {
+	.driver = {
+		.name = "ehca",
+		.owner = THIS_MODULE,
 		.groups = ehca_drv_attr_groups,
+		.of_match_table = ehca_device_table,
 	},
 };
 

