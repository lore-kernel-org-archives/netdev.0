From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v2 net-next 8/8] net/ncsi: Fix length of GVI response packet
Date: Thu, 13 Apr 2017 17:48:21 +1000
Message-ID: <1492069701-20772-9-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1492069701-20772-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: joe@perches.com, davem@davemloft.net,
        Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:36606 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756454AbdDMHuC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 03:50:02 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3D7nVqf041889
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 03:50:02 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29ssdm1j7e-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 03:50:01 -0400
Received: from localhost
        by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 13 Apr 2017 17:49:54 +1000
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
        by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3D7ne2E26869852
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 17:49:48 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
        by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3D7nGpI007308
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 17:49:16 +1000
In-Reply-To: <1492069701-20772-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The length of GVI (GetVersionInfo) response packet should be 40 instead
of 36. This issue was found from /sys/kernel/debug/ncsi/eth0/stats.

 # cat /sys/kernel/debug/ncsi/eth0/stats
 :
 RSP          OK       TIMEOUT  ERROR
 =======================================
 GVI          0        0        2

With this applied, no error reported on GVI response packets:

 # cat /sys/kernel/debug/ncsi/eth0/stats
 :
 RSP          OK       TIMEOUT  ERROR
 =======================================
 GVI          2        0        0

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 net/ncsi/ncsi-rsp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ncsi/ncsi-rsp.c b/net/ncsi/ncsi-rsp.c
index 095726f..67260f3 100644
--- a/net/ncsi/ncsi-rsp.c
+++ b/net/ncsi/ncsi-rsp.c
@@ -951,7 +951,7 @@ static struct ncsi_rsp_handler {
 	{ NCSI_PKT_RSP_EGMF,    4, ncsi_rsp_handler_egmf    },
 	{ NCSI_PKT_RSP_DGMF,    4, ncsi_rsp_handler_dgmf    },
 	{ NCSI_PKT_RSP_SNFC,    4, ncsi_rsp_handler_snfc    },
-	{ NCSI_PKT_RSP_GVI,    36, ncsi_rsp_handler_gvi     },
+	{ NCSI_PKT_RSP_GVI,    40, ncsi_rsp_handler_gvi     },
 	{ NCSI_PKT_RSP_GC,     32, ncsi_rsp_handler_gc      },
 	{ NCSI_PKT_RSP_GP,     -1, ncsi_rsp_handler_gp      },
 	{ NCSI_PKT_RSP_GCPS,  172, ncsi_rsp_handler_gcps    },
-- 
2.7.4
