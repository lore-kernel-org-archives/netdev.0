From: Dan Carpenter <error27@gmail.com>
Subject: [patch -next] bna: off by one in bfa_msgq_rspq_pi_update()
Date: Wed, 24 Aug 2011 14:30:28 +0300
Message-ID: <20110824113028.GD5975@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Debashis Dutt <ddutt@brocade.com>,
	"open list:BROCADE BNA 10 GI..." <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48578 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057Ab1HXLcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 07:32:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rspq->rsphdlr[] array has BFI_MC_MAX elements, so this test was
off by one.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/ethernet/brocade/bna/bfa_msgq.c b/drivers/net/ethernet/brocade/bna/bfa_msgq.c
index ed52187..dd36427 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_msgq.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_msgq.c
@@ -483,7 +483,7 @@ bfa_msgq_rspq_pi_update(struct bfa_msgq_rspq *rspq, struct bfi_mbmsg *mb)
 		mc = msghdr->msg_class;
 		num_entries = ntohs(msghdr->num_entries);
 
-		if ((mc > BFI_MC_MAX) || (rspq->rsphdlr[mc].cbfn == NULL))
+		if ((mc >= BFI_MC_MAX) || (rspq->rsphdlr[mc].cbfn == NULL))
 			break;
 
 		(rspq->rsphdlr[mc].cbfn)(rspq->rsphdlr[mc].cbarg, msghdr);
