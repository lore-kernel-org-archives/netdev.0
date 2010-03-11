From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 27/27] of: remove obsolete members from of_platform_driver
Date: Thu, 11 Mar 2010 11:24:17 -0700
Message-ID: <20100311182416.13103.38891.stgit__9929.91215684942$1268331915$gmane$org@angua>
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
	with ESMTP id S934271Ab0CKSYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:24:21 -0500
In-Reply-To: <20100311181604.13103.30088.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.name, .match_table and .owner already exist in struct device_driver.
Remove the duplication from struct of_platform_driver.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/of/platform.c       |    7 -------
 include/linux/of_platform.h |    4 ----
 2 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/drivers/of/platform.c b/drivers/of/platform.c
index 9fd7f7d..ba402c6 100644
--- a/drivers/of/platform.c
+++ b/drivers/of/platform.c
@@ -385,13 +385,6 @@ int of_bus_type_init(struct bus_type *bus, const char *name)
 
 int of_register_driver(struct of_platform_driver *drv, struct bus_type *bus)
 {
-	/* initialize common driver fields */
-	if (!drv->driver.name)
-		drv->driver.name = drv->name;
-	if (!drv->driver.owner)
-		drv->driver.owner = drv->owner;
-	if (!drv->driver.of_match_table)
-		drv->driver.of_match_table = drv->match_table;
 	drv->driver.bus = bus;
 
 	/* register with core */
diff --git a/include/linux/of_platform.h b/include/linux/of_platform.h
index ac3ae07..1643d37 100644
--- a/include/linux/of_platform.h
+++ b/include/linux/of_platform.h
@@ -31,10 +31,6 @@ extern struct bus_type of_platform_bus_type;
  */
 struct of_platform_driver
 {
-	const char		*name;
-	const struct of_device_id	*match_table;
-	struct module		*owner;
-
 	int	(*probe)(struct of_device* dev,
 			 const struct of_device_id *match);
 	int	(*remove)(struct of_device* dev);

