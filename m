From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] bnx2x: unlock before returning an error
Date: Wed, 25 Jan 2012 10:59:31 +0300
Message-ID: <20120125075931.GA20199@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Eilon Greenstein <eilong@broadcom.com>,
	Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:17586 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910Ab2AYH7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 02:59:35 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We introduced a new return here but forgot to drop the lock.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index cb6339c..69465c3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -1836,6 +1836,7 @@ static int bnx2x_vlan_mac_del_all(struct bnx2x *bp,
 			rc = exeq->remove(bp, exeq->owner, exeq_pos);
 			if (rc) {
 				BNX2X_ERR("Failed to remove command\n");
+				spin_unlock_bh(&exeq->lock);
 				return rc;
 			}
 			list_del(&exeq_pos->link);
