From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net-next 3/8] net/ncsi: Don't probe on the reserved channel ID (0x1f)
Date: Thu, 29 Sep 2016 15:03:10 +1000
Message-ID: <1475125395-8459-4-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1475125395-8459-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, joel@jms.id.au, yuvali@mellanox.com,
        benh@kernel.crashing.org, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:53669 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751038AbcI2FDM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 01:03:12 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8T4vwvD142076
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 01:03:11 -0400
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
        by mx0a-001b2d01.pphosted.com with ESMTP id 25rrt9sexy-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 01:03:11 -0400
Received: from localhost
        by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 29 Sep 2016 15:03:08 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
        by d23dlp01.au.ibm.com (Postfix) with ESMTP id 3DAD92CE805E
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 15:03:07 +1000 (EST)
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
        by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8T537NV131534
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 15:03:07 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
        by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8T536UL008156
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 15:03:06 +1000
In-Reply-To: <1475125395-8459-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We needn't send CIS (Clear Initial State) command to the NCSI
reserved channel (0x1f) in the enumeration. We shouldn't receive
a valid response from CIS on NCSI channel 0x1f.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
Reviewed-by: Joel Stanley <joel@jms.id.au>
---
 net/ncsi/ncsi-manage.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index 73883ed..3eeb915 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -887,12 +887,12 @@ static void ncsi_probe_channel(struct ncsi_dev_priv *ndp)
 		nd->state = ncsi_dev_state_probe_cis;
 		break;
 	case ncsi_dev_state_probe_cis:
-		ndp->pending_req_num = 32;
+		ndp->pending_req_num = NCSI_RESERVED_CHANNEL;
 
 		/* Clear initial state */
 		nca.type = NCSI_PKT_CMD_CIS;
 		nca.package = ndp->active_package->id;
-		for (index = 0; index < 0x20; index++) {
+		for (index = 0; index < NCSI_RESERVED_CHANNEL; index++) {
 			nca.channel = index;
 			ret = ncsi_xmit_cmd(&nca);
 			if (ret)
-- 
2.1.0
