From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 2/2] smsc911x: fix platform resource call during module unload
Date: Fri, 19 Dec 2008 18:05:30 +0000
Message-ID: <1229709930-19925-2-git-send-email-steve.glendinning@smsc.com>
References: <1229709930-19925-1-git-send-email-steve.glendinning@smsc.com>
Cc: dfoley@telus.net, Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.115] ([86.54.240.115]:40775 "EHLO
	drevil2.shawell.net" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751738AbYLSSFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 13:05:32 -0500
In-Reply-To: <1229709930-19925-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a typo, the platform_get_resource calls in
smsc911x_drv_remove are supposed to look the same as those in
smsc911x_drv_probe.

Reported and fixed by dfoley@telus.net.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc911x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index cd925de..a33c5fc 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1871,7 +1871,7 @@ static int __devexit smsc911x_drv_remove(struct platform_device *pdev)
 	res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
 					   "smsc911x-memory");
 	if (!res)
-		platform_get_resource(pdev, IORESOURCE_MEM, 0);
+		res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 
 	release_mem_region(res->start, res->end - res->start);
 
-- 
1.6.0.4

