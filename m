From: David Miller <davem@davemloft.net>
Subject: [PATCH] greth: Fix build after OF device conversions.
Date: Tue, 01 Jun 2010 00:10:59 -0700 (PDT)
Message-ID: <20100601.001059.241461551.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: grant.likely@secretlab.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42952
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752864Ab0FAHKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 03:10:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---

I've pushed this to net-2.6

 drivers/net/greth.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index f37a4c1..3a029d0 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -1607,14 +1607,13 @@ static struct of_device_id greth_of_match[] = {
 MODULE_DEVICE_TABLE(of, greth_of_match);
 
 static struct of_platform_driver greth_of_driver = {
-	.name = "grlib-greth",
-	.match_table = greth_of_match,
+	.driver = {
+		.name = "grlib-greth",
+		.owner = THIS_MODULE,
+		.of_match_table = greth_of_match,
+	},
 	.probe = greth_of_probe,
 	.remove = __devexit_p(greth_of_remove),
-	.driver = {
-		   .owner = THIS_MODULE,
-		   .name = "grlib-greth",
-		   },
 };
 
 static int __init greth_init(void)
-- 
1.7.0.4

