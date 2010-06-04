From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] greth: Remove unnecessary memset of napi member in netdev private data
Date: Fri,  4 Jun 2010 08:24:21 +0200
Message-ID: <1275632661-16406-1-git-send-email-tklauser@distanz.ch>
Cc: Tobias Klauser <tklauser@distanz.ch>
To: kristoffer@gaisler.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:56709 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752149Ab0FDGY1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jun 2010 02:24:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The memory for the private data is allocated using kzalloc in
alloc_etherdev (or alloc_netdev_mq respectively) so there is no need to
set the napi member to 0 explicitely.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/greth.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index 3a029d0..4d09eab 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -1555,7 +1555,6 @@ static int __devinit greth_of_probe(struct of_device *ofdev, const struct of_dev
 	}
 
 	/* setup NAPI */
-	memset(&greth->napi, 0, sizeof(greth->napi));
 	netif_napi_add(dev, &greth->napi, greth_poll, 64);
 
 	return 0;
-- 
1.6.3.3

