From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] dm9000: Remove unnecessary memset of netdev private data
Date: Wed,  9 Sep 2009 13:07:44 +0200
Message-ID: <1252494464-4633-2-git-send-email-tklauser@distanz.ch>
References: <1252494464-4633-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org, Tobias Klauser <tklauser@distanz.ch>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.zhaw.ch ([160.85.104.51]:49152 "EHLO mx2.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751919AbZIILHl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Sep 2009 07:07:41 -0400
In-Reply-To: <1252494464-4633-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The memory for the private data is allocated using kzalloc in
alloc_etherdev (or alloc_netdev_mq respectively) so there is no need to
set it to 0 again.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/dm9000.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 00a9db8..11995ad 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -1213,7 +1213,6 @@ dm9000_probe(struct platform_device *pdev)
 
 	/* setup board info structure */
 	db = netdev_priv(ndev);
-	memset(db, 0, sizeof(*db));
 
 	db->dev = &pdev->dev;
 	db->ndev = ndev;
-- 
1.6.0.4

