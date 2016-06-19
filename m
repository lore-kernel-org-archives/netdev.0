From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 2/5] qed: Prevent VF from Tx-switching 'promisc'
Date: Sun, 19 Jun 2016 15:18:12 +0300
Message-ID: <1466338695-15538-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1466338695-15538-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:26478 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751731AbcFSMSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 08:18:34 -0400
In-Reply-To: <1466338695-15538-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Internal loopback in driver is based on two things - first
is the willingness of transmitter to use it [in case of VFs,
this can be forced based on VEPA/VEB] and secondly on another
vport classification configuration which should match the
packet's destination.

Current code allows non-linux VFs to configure a 'promisc'
mode on Tx, meaning all traffic sent by VF would be loopbacked
internally by firmware; This isn't considered a valid mode and
as such should be prevented by PF.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_l2.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 1aaea83..0e8d43c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -248,10 +248,6 @@ qed_sp_update_accept_mode(struct qed_hwfn *p_hwfn,
 		SET_FIELD(state, ETH_VPORT_TX_MODE_UCAST_DROP_ALL,
 			  !!(accept_filter & QED_ACCEPT_NONE));
 
-		SET_FIELD(state, ETH_VPORT_TX_MODE_UCAST_ACCEPT_ALL,
-			  (!!(accept_filter & QED_ACCEPT_UCAST_MATCHED) &&
-			   !!(accept_filter & QED_ACCEPT_UCAST_UNMATCHED)));
-
 		SET_FIELD(state, ETH_VPORT_TX_MODE_MCAST_DROP_ALL,
 			  !!(accept_filter & QED_ACCEPT_NONE));
 
-- 
1.9.3
