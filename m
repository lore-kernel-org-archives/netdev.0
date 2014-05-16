From: Fabian Godehardt <fg@emlix.com>
Subject: [PATCH] net/dsa/dsa.c: increment chip_index during of_node handling on dsa_of_probe()
Date: Fri, 16 May 2014 06:21:44 +0200
Message-ID: <1400214104-27699-1-git-send-email-fg@emlix.com>
Cc: Fabian Godehardt <fg@emlix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.emlix.com ([88.198.240.195]:47889 "EHLO mx1.emlix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752719AbaEPE1r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 00:27:47 -0400
Received: from mx1.emlix.com (localhost [127.0.0.1])
	by mx1.emlix.com (Postfix) with ESMTP id 51C1520659
	for <netdev@vger.kernel.org>; Fri, 16 May 2014 06:21:13 +0200 (CEST)
Received: from mailer.emlix.com (gate.emlix.com [80.150.94.234])
	(using TLSv1.2 with cipher DHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	by mx1.emlix.com (Postfix) with ESMTPS id 2938C20215
	for <netdev@vger.kernel.org>; Fri, 16 May 2014 06:21:13 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding more than one chip on device-tree currently causes the probing 
routine to always use the first chips data pointer.

Signed-off-by: Fabian Godehardt <fg@emlix.com>
---
 net/dsa/dsa.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 0eb5d5e..5db37ce 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -406,8 +406,9 @@ static int dsa_of_probe(struct platform_device *pdev)
 		goto out_free;
 	}
 
-	chip_index = 0;
+	chip_index = -1;
 	for_each_available_child_of_node(np, child) {
+		chip_index++;
 		cd = &pd->chip[chip_index];
 
 		cd->mii_bus = &mdio_bus->dev;
-- 
1.8.2.61.g7b9a419
