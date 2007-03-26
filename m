From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 1/7] qla3xxx: bugfix: Add tx control block memset.
Date: Mon, 26 Mar 2007 12:43:47 -0700
Message-ID: <11749382333976-git-send-email-ron.mercer@qlogic.com>
References: <20070326164650.GA3822@linux-7mw0.qlogic.org>
Cc: ron.mercer@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:59437 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753738AbXCZTn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2007 15:43:57 -0400
In-Reply-To: <20070326164650.GA3822@linux-7mw0.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This was removed in a previous patch to increase performance, but
caused a transmit error for the 4032 chip.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 356b1c4..f645a0d 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2380,6 +2380,7 @@ static int ql3xxx_send(struct sk_buff *skb, struct net_device *ndev)
 	}
 	
 	mac_iocb_ptr = tx_cb->queue_entry;
+	memset((void *)mac_iocb_ptr, 0, sizeof(struct ob_mac_iocb_req));
 	mac_iocb_ptr->opcode = qdev->mac_ob_opcode;
 	mac_iocb_ptr->flags = OB_MAC_IOCB_REQ_X;
 	mac_iocb_ptr->flags |= qdev->mb_bit_mask;
-- 
1.5.0.rc4.16.g9e258

