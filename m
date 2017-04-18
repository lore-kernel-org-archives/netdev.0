From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v3 net-next 8/8] net/ncsi: Fix length of GVI response packet
Date: Tue, 18 Apr 2017 16:51:35 +1000
Message-ID: <1492498295-14385-9-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1492498295-14385-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: joe@perches.com, kubakici@wp.pl, davem@davemloft.net,
        Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:55666 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754087AbdDRGxO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 02:53:14 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3I6ma4p097459
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 02:53:04 -0400
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29w4j9t1a7-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 02:53:03 -0400
Received: from localhost
        by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Tue, 18 Apr 2017 16:53:01 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
        by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3I6qpqs17826010
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 16:52:59 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
        by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3I6qL0I002963
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 16:52:22 +1000
In-Reply-To: <1492498295-14385-1-git-send-email-gwshan@linux.vnet.ibm.com>
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
index 092f2d8..804ccca 100644
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
