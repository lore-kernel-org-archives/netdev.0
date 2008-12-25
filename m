From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 1/3] net: Init NAPI dev_list on napi_del
Date: Thu, 25 Dec 2008 01:02:04 -0800
Message-ID: <20081225090204.13754.25244.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:33406 "EHLO
	QMTA03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751524AbYLYJCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 04:02:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

The recent GRO patches introduced the NAPI removal of devices in
free_netdev.  For drivers that can change the number of queues during
driver operation, the NAPI infrastructure doesn't allow the freeing and
re-addition of NAPI entities without reloading the driver.

This change reinitializes the dev_list in each NAPI struct on delete,
instead of just deleting it (and assigning the list pointers to POISON).
Drivers that wish to remove/re-add NAPI will need to re-initialize the
netdev napi_list after removing all NAPI instances, before re-adding NAPI
devices again.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/core/dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index daca72e..536a8ac 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2548,7 +2548,7 @@ void netif_napi_del(struct napi_struct *napi)
 {
 	struct sk_buff *skb, *next;
 
-	list_del(&napi->dev_list);
+	list_del_init(&napi->dev_list);
 
 	for (skb = napi->gro_list; skb; skb = next) {
 		next = skb->next;

