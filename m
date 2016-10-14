From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net 1/5] net/ncsi: Not fetch active package and channel again
Date: Fri, 14 Oct 2016 13:53:30 +1100
Message-ID: <1476413614-24586-2-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1476413614-24586-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, joel@jms.id.au,
        Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:52630 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751393AbcJNCyo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 22:54:44 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9E2nCNL012676
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 22:53:02 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
        by mx0a-001b2d01.pphosted.com with ESMTP id 262f43gnc8-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 22:53:01 -0400
Received: from localhost
        by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Fri, 14 Oct 2016 12:52:59 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
        by d23dlp01.au.ibm.com (Postfix) with ESMTP id 4B8652CE8056
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 13:52:57 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
        by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9E2qvUf18284730
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 13:52:57 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
        by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9E2quZC027298
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 13:52:56 +1100
In-Reply-To: <1476413614-24586-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ncsi_suspend_channel(), we fetch the active package and
channel to local variables for twice. It's unnecessary. This
drops one of them. No functional changes introduced.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 net/ncsi/ncsi-manage.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index 5e509e5..1bc96dc 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -545,8 +545,6 @@ static void ncsi_suspend_channel(struct ncsi_dev_priv *ndp)
 	case ncsi_dev_state_suspend_deselect:
 		ndp->pending_req_num = 1;
 
-		np = ndp->active_package;
-		nc = ndp->active_channel;
 		nca.package = np->id;
 		if (nd->state == ncsi_dev_state_suspend_select) {
 			nca.type = NCSI_PKT_CMD_SP;
-- 
2.1.0
