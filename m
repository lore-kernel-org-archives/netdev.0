From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 2/2] netdev: smsc911x: add missing __devexit_p() usage
Date: Fri,  5 Jun 2009 20:37:20 -0400
Message-ID: <1244248640-22699-2-git-send-email-vapier@gentoo.org>
References: <1244248640-22699-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:58584 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752735AbZFFAhZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jun 2009 20:37:25 -0400
In-Reply-To: <1244248640-22699-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The smsc911x_drv_remove() function is declared with __devexit, so the
assignment to the driver structure needs __devexit_p() wrappings to prevent
build failure when hotplug is disabled.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/smsc911x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index eb7db03..d3bf943 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -2098,7 +2098,7 @@ out_0:
 
 static struct platform_driver smsc911x_driver = {
 	.probe = smsc911x_drv_probe,
-	.remove = smsc911x_drv_remove,
+	.remove = __devexit_p(smsc911x_drv_remove),
 	.driver = {
 		.name = SMSC_CHIPNAME,
 	},
-- 
1.6.3.1

