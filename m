From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v2 net-next 3/8] net/ncsi: Don't probe on the reserved channel ID (0x1f)
Date: Tue,  4 Oct 2016 11:25:49 +1100
Message-ID: <1475540754-31169-4-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1475540754-31169-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, joel@jms.id.au, yuvali@mellanox.com,
        benh@kernel.crashing.org, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:40204 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751919AbcJDAZ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 20:25:28 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u940Mvak073482
        for <netdev@vger.kernel.org>; Mon, 3 Oct 2016 20:25:27 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
        by mx0a-001b2d01.pphosted.com with ESMTP id 25uy9kd1gg-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 03 Oct 2016 20:25:27 -0400
Received: from localhost
        by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Tue, 4 Oct 2016 10:25:25 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
        by d23dlp01.au.ibm.com (Postfix) with ESMTP id 2A6612CE805D
        for <netdev@vger.kernel.org>; Tue,  4 Oct 2016 11:25:22 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
        by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u940PLUC64028790
        for <netdev@vger.kernel.org>; Tue, 4 Oct 2016 11:25:21 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
        by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u940PLhj031427
        for <netdev@vger.kernel.org>; Tue, 4 Oct 2016 11:25:21 +1100
In-Reply-To: <1475540754-31169-1-git-send-email-gwshan@linux.vnet.ibm.com>
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
index 97c99be..8c5e016 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -911,12 +911,12 @@ static void ncsi_probe_channel(struct ncsi_dev_priv *ndp)
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
