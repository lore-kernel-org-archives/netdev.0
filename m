From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 1/2] qla3xxx: bugfix: Add memory barrier before accessing rx completion.
Date: Tue, 21 Aug 2007 06:48:03 -0700
Message-ID: <11877040843411-git-send-email-ron.mercer@qlogic.com>
References: <20070820203209.GB4181@linux-7mw0.qlogic.org>
Cc: Ron Mercer <ron.mercer@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:35148 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755051AbXHUNsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 09:48:18 -0400
In-Reply-To: <20070820203209.GB4181@linux-7mw0.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 69da95b..c3fe1c7 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2248,6 +2248,7 @@ static int ql_tx_rx_clean(struct ql3_adapter *qdev,
 		qdev->rsp_consumer_index) && (work_done < work_to_do)) {
 
 		net_rsp = qdev->rsp_current;
+		rmb();
 		switch (net_rsp->opcode) {
 
 		case OPCODE_OB_MAC_IOCB_FN0:
-- 
1.5.0.rc4.16.g9e258

