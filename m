From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next 15/19] bna: remove useless pointer assignment
Date: Wed, 10 Jun 2015 18:43:21 +0200
Message-ID: <1433954605-22813-16-git-send-email-ivecera@redhat.com>
References: <1433954605-22813-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50676 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965752AbbFJQnP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2015 12:43:15 -0400
In-Reply-To: <1433954605-22813-1-git-send-email-ivecera@redhat.com>
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
index e871e27..aea585b 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -724,7 +724,6 @@ next:
 			cmpl->valid = 0;
 			BNA_QE_INDX_INC(ccb->producer_index, ccb->q_depth);
 		}
-		cmpl = &cq[ccb->producer_index];
 	}
 
 	napi_gro_flush(&rx_ctrl->napi, false);
-- 
2.3.6
