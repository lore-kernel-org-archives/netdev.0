From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 1/2] net: netcp: replace IS_ERR_OR_NULL by IS_ERR
Date: Wed, 16 Nov 2016 11:43:33 +0100
Message-ID: <1479293014-18811-2-git-send-email-Julia.Lawall@lip6.fr>
References: <1479293014-18811-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
        Murali Karicheri <m-karicheri2@ti.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: Wingman Kwok <w-kwok2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:9693 "EHLO
        mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752906AbcKPLDL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 06:03:11 -0500
In-Reply-To: <1479293014-18811-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

knav_queue_open always returns an ERR_PTR value, never NULL.  This can be
confirmed by unfolding the function calls and conforms to the function's
documentation.  Thus, replace IS_ERR_OR_NULL by IS_ERR in error checks.

The change is made using the following semantic patch:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression x;
statement S;
@@

x = knav_queue_open(...);
if (
-   IS_ERR_OR_NULL
+   IS_ERR
    (x)) S
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---

The patches in this series are completely independent of each other, except
for having been made from the same specification.

 drivers/net/ethernet/ti/netcp_core.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 78b4c83..7981b99 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1568,7 +1568,7 @@ static int netcp_setup_navigator_resources(struct net_device *ndev)
 	/* open Tx completion queue */
 	snprintf(name, sizeof(name), "tx-compl-%s", ndev->name);
 	netcp->tx_compl_q = knav_queue_open(name, netcp->tx_compl_qid, 0);
-	if (IS_ERR_OR_NULL(netcp->tx_compl_q)) {
+	if (IS_ERR(netcp->tx_compl_q)) {
 		ret = PTR_ERR(netcp->tx_compl_q);
 		goto fail;
 	}
@@ -1588,7 +1588,7 @@ static int netcp_setup_navigator_resources(struct net_device *ndev)
 	/* open Rx completion queue */
 	snprintf(name, sizeof(name), "rx-compl-%s", ndev->name);
 	netcp->rx_queue = knav_queue_open(name, netcp->rx_queue_id, 0);
-	if (IS_ERR_OR_NULL(netcp->rx_queue)) {
+	if (IS_ERR(netcp->rx_queue)) {
 		ret = PTR_ERR(netcp->rx_queue);
 		goto fail;
 	}
@@ -1610,7 +1610,7 @@ static int netcp_setup_navigator_resources(struct net_device *ndev)
 	     ++i) {
 		snprintf(name, sizeof(name), "rx-fdq-%s-%d", ndev->name, i);
 		netcp->rx_fdq[i] = knav_queue_open(name, KNAV_QUEUE_GP, 0);
-		if (IS_ERR_OR_NULL(netcp->rx_fdq[i])) {
+		if (IS_ERR(netcp->rx_fdq[i])) {
 			ret = PTR_ERR(netcp->rx_fdq[i]);
 			goto fail;
 		}
