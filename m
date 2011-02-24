From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH] enic: Flush driver cache of registered addr
	lists during port profile disassociate
Date: Wed, 23 Feb 2011 17:16:01 -0800
Message-ID: <20110224011601.16406.36125.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:1200 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751659Ab1BXBQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 20:16:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

During a port profile disassociate all address registrations for the interface
are blown away from the adapter. This patch resets the driver cache of
registered address lists to zero after a port profile disassociate.

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
---
 drivers/net/enic/enic.h      |    2 +-
 drivers/net/enic/enic_main.c |    2 ++
 2 files changed, 3 insertions(+), 1 deletions(-)


diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index aee5256..e816bbb 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.9"
+#define DRV_VERSION		"2.1.1.10"
 #define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 4f1710e..8b9cad5 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1126,6 +1126,8 @@ static int enic_set_port_profile(struct enic *enic, u8 *mac)
 	if (err)
 		return err;
 
+	enic_reset_addr_lists(enic);
+
 	switch (enic->pp.request) {
 
 	case PORT_REQUEST_ASSOCIATE:

