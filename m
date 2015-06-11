From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next v2 15/19] bna: remove useless pointer assignment
Date: Thu, 11 Jun 2015 15:52:27 +0200
Message-ID: <1434030751-28835-16-git-send-email-ivecera@redhat.com>
References: <1434030751-28835-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com, joe@perches.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47389 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933397AbbFKNw0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 09:52:26 -0400
In-Reply-To: <1434030751-28835-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pointer cmpl used to iterate through completion entries is updated at
the beginning of while loop as well as at the end. The update at the end
of the loop is useless.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 0f833e4..fc97428 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -725,7 +725,6 @@ next:
 			cmpl->valid = 0;
 			BNA_QE_INDX_INC(ccb->producer_index, ccb->q_depth);
 		}
-		cmpl = &cq[ccb->producer_index];
 	}
 
 	napi_gro_flush(&rx_ctrl->napi, false);
-- 
2.3.6
