From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 02/13] qla3xxx: Remove unnecessary memset() in qla3xxx_send()
Date: Mon, 26 Feb 2007 11:06:32 -0800
Message-ID: <1172516803968-git-send-email-ron.mercer@qlogic.com>
References: <20070226190450.GA7325@linux-7mw0.qlogic.org>
Cc: ron.mercer@qlogic.com, romieu@fr.zoreil.com,
	benjamin.li@qlogic.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:15768 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933802AbXBZTHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 14:07:43 -0500
In-Reply-To: <20070226190450.GA7325@linux-7mw0.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Li <benjamin.li@qlogic.com>

We do not need to zero out the 64 byte MAC request I/O control block.
  By zeroing out the control block and setting it to proper fields is
redundant work.  This is because in the qla3xxx_send() function we will
already set the proper fields in this structure.  The unused fields are
not looked at by the hardware and do not need to be zeroed out.

Signed-off-by: Benjamin Li <benjamin.li@qlogic.com>
Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index d1c90ca..18a2bb5 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2188,7 +2188,6 @@ static int ql3xxx_send(struct sk_buff *skb, struct net_device *ndev)
 
 	}
 	mac_iocb_ptr = tx_cb->queue_entry;
-	memset((void *)mac_iocb_ptr, 0, sizeof(struct ob_mac_iocb_req));
 	mac_iocb_ptr->opcode = qdev->mac_ob_opcode;
 	mac_iocb_ptr->flags |= qdev->mb_bit_mask;
 	mac_iocb_ptr->transaction_id = qdev->req_producer_index;
-- 
1.5.0.rc4.16.g9e258

