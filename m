From: <igal.liberman@freescale.com>
Subject: [PATCH] fsl/fman: Initialize fman->dev earlier
Date: Sun, 28 Feb 2016 23:59:53 +0200
Message-ID: <1456696793-32417-1-git-send-email-igal.liberman@freescale.com>
Reply-To: <igal.liberman@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <scottwood@freescale.com>, <madalin.bucur@freescale.com>,
	Igal Liberman <igal.liberman@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0130.outbound.protection.outlook.com ([157.56.111.130]:17591
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751457AbcB2PRZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 10:17:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igal Liberman <igal.liberman@freescale.com>

Currently, in a case of error, dev_err is using fman->dev
before its initialization and "(NULL device *)" is printed.
This patch fixes this issue.

Signed-off-by: Igal Liberman <igal.liberman@freescale.com>
---
 drivers/net/ethernet/freescale/fman/fman.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fman/fman.c b/drivers/net/ethernet/freescale/fman/fman.c
index 623aa1c..79a210a 100644
--- a/drivers/net/ethernet/freescale/fman/fman.c
+++ b/drivers/net/ethernet/freescale/fman/fman.c
@@ -2791,6 +2791,8 @@ static struct fman *read_dts_node(struct platform_device *of_dev)
 		goto fman_free;
 	}
 
+	fman->dev = &of_dev->dev;
+
 	return fman;
 
 fman_node_put:
@@ -2845,8 +2847,6 @@ static int fman_probe(struct platform_device *of_dev)
 
 	dev_set_drvdata(dev, fman);
 
-	fman->dev = dev;
-
 	dev_dbg(dev, "FMan%d probed\n", fman->dts_params.id);
 
 	return 0;
-- 
1.7.9.5
