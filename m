From: akpm@linux-foundation.org
Subject: [patch 03/10] strlcpy is smart enough
Date: Mon, 26 Mar 2007 21:47:22 -0800
Message-ID: <200703270547.l2R5lM49008257@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	khali@linux-fr.org, osstklei@de.ibm.com, themann@de.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40139 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934009AbXC0FsF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 01:48:05 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jean Delvare <khali@linux-fr.org>

strlcpy already accounts for the trailing zero in its length
computation, so there is no need to substract one to the buffer size.

Signed-off-by: Jean Delvare <khali@linux-fr.org>
Cc: Jan-Bernd Themann <themann@de.ibm.com>
Cc: Thomas Klein <osstklei@de.ibm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/ehea/ehea_ethtool.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/ehea/ehea_ethtool.c~ehea-strlcpy-is-smart-enough drivers/net/ehea/ehea_ethtool.c
--- a/drivers/net/ehea/ehea_ethtool.c~ehea-strlcpy-is-smart-enough
+++ a/drivers/net/ehea/ehea_ethtool.c
@@ -144,8 +144,8 @@ static int ehea_nway_reset(struct net_de
 static void ehea_get_drvinfo(struct net_device *dev,
 			       struct ethtool_drvinfo *info)
 {
-	strlcpy(info->driver, DRV_NAME, sizeof(info->driver) - 1);
-	strlcpy(info->version, DRV_VERSION, sizeof(info->version) - 1);
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
 }
 
 static u32 ehea_get_msglevel(struct net_device *dev)
_
