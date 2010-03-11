From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 18/27] drivers/parport/of: don't use deprecated field in
	of_platform_driver
Date: Thu, 11 Mar 2010 11:23:27 -0700
Message-ID: <20100311182327.13103.91141.stgit__5019.04788329757$1268332136$gmane$org@angua>
References: <20100311181604.13103.30088.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f194.google.com ([209.85.222.194]:49500 "EHLO
	mail-pz0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934193Ab0CKSXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:23:30 -0500
In-Reply-To: <20100311181604.13103.30088.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.name, .match_table and .owner are duplicated in both of_platform_driver
and device_driver, so the of_platform_driver copies will be removed soon.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/parport/parport_sunbpp.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/parport/parport_sunbpp.c b/drivers/parport/parport_sunbpp.c
index 065f229..9a5b4b8 100644
--- a/drivers/parport/parport_sunbpp.c
+++ b/drivers/parport/parport_sunbpp.c
@@ -382,8 +382,11 @@ static const struct of_device_id bpp_match[] = {
 MODULE_DEVICE_TABLE(of, bpp_match);
 
 static struct of_platform_driver bpp_sbus_driver = {
-	.name		= "bpp",
-	.match_table	= bpp_match,
+	.driver = {
+		.name = "bpp",
+		.owner = THIS_MODULE,
+		.of_match_table = bpp_match,
+	},
 	.probe		= bpp_probe,
 	.remove		= __devexit_p(bpp_remove),
 };

