From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 6/7] qlge: Restore rx mode after internal reset.
Date: Thu,  8 Oct 2009 12:54:42 -0700
Message-ID: <1255031683-3912-7-git-send-email-ron.mercer@qlogic.com>
References: <1255031683-3912-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:40572 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933296AbZJHUCd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 16:02:33 -0400
In-Reply-To: <1255031683-3912-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call set_multi API after reset recovery.  This was exposed by tripping
tx_timeout.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index fe13006..48b45df 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3751,6 +3751,12 @@ static void ql_asic_reset_work(struct work_struct *work)
 	status = ql_adapter_up(qdev);
 	if (status)
 		goto error;
+
+	/* Restore rx mode. */
+	clear_bit(QL_ALLMULTI, &qdev->flags);
+	clear_bit(QL_PROMISCUOUS, &qdev->flags);
+	qlge_set_multicast_list(qdev->ndev);
+
 	rtnl_unlock();
 	return;
 error:
-- 
1.6.0.2

