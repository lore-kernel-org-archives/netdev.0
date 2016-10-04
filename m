From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v2 net-next 2/8] net/ncsi: Introduce NCSI_RESERVED_CHANNEL
Date: Tue,  4 Oct 2016 11:25:48 +1100
Message-ID: <1475540754-31169-3-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1475540754-31169-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, joel@jms.id.au, yuvali@mellanox.com,
        benh@kernel.crashing.org, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:59691 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752046AbcJDAZ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 20:25:28 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u940MuiE005602
        for <netdev@vger.kernel.org>; Mon, 3 Oct 2016 20:25:28 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
        by mx0a-001b2d01.pphosted.com with ESMTP id 25uy9kn2da-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 03 Oct 2016 20:25:28 -0400
Received: from localhost
        by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Tue, 4 Oct 2016 10:25:25 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
        by d23dlp03.au.ibm.com (Postfix) with ESMTP id F3954357805E
        for <netdev@vger.kernel.org>; Tue,  4 Oct 2016 11:25:21 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
        by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u940PLbp60555400
        for <netdev@vger.kernel.org>; Tue, 4 Oct 2016 11:25:21 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
        by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u940PKbV031424
        for <netdev@vger.kernel.org>; Tue, 4 Oct 2016 11:25:21 +1100
In-Reply-To: <1475540754-31169-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This defines NCSI_RESERVED_CHANNEL as the reserved NCSI channel
ID (0x1f). No logical changes introduced.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
Reviewed-by: Joel Stanley <joel@jms.id.au>
---
 net/ncsi/internal.h    |  1 +
 net/ncsi/ncsi-manage.c | 14 +++++++-------
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/ncsi/internal.h b/net/ncsi/internal.h
index 33738c0..66dc851 100644
--- a/net/ncsi/internal.h
+++ b/net/ncsi/internal.h
@@ -170,6 +170,7 @@ struct ncsi_package;
 
 #define NCSI_PACKAGE_SHIFT	5
 #define NCSI_PACKAGE_INDEX(c)	(((c) >> NCSI_PACKAGE_SHIFT) & 0x7)
+#define NCSI_RESERVED_CHANNEL	0x1f
 #define NCSI_CHANNEL_INDEX(c)	((c) & ((1 << NCSI_PACKAGE_SHIFT) - 1))
 #define NCSI_TO_CHANNEL(p, c)	(((p) << NCSI_PACKAGE_SHIFT) | (c))
 
diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index a26ce51..97c99be 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -542,7 +542,7 @@ static void ncsi_suspend_channel(struct ncsi_dev_priv *ndp)
 		nca.package = np->id;
 		if (nd->state == ncsi_dev_state_suspend_select) {
 			nca.type = NCSI_PKT_CMD_SP;
-			nca.channel = 0x1f;
+			nca.channel = NCSI_RESERVED_CHANNEL;
 			if (ndp->flags & NCSI_DEV_HWA)
 				nca.bytes[0] = 0;
 			else
@@ -559,7 +559,7 @@ static void ncsi_suspend_channel(struct ncsi_dev_priv *ndp)
 			nd->state = ncsi_dev_state_suspend_deselect;
 		} else if (nd->state == ncsi_dev_state_suspend_deselect) {
 			nca.type = NCSI_PKT_CMD_DP;
-			nca.channel = 0x1f;
+			nca.channel = NCSI_RESERVED_CHANNEL;
 			nd->state = ncsi_dev_state_suspend_done;
 		}
 
@@ -608,7 +608,7 @@ static void ncsi_configure_channel(struct ncsi_dev_priv *ndp)
 		else
 			nca.bytes[0] = 1;
 		nca.package = np->id;
-		nca.channel = 0x1f;
+		nca.channel = NCSI_RESERVED_CHANNEL;
 		ret = ncsi_xmit_cmd(&nca);
 		if (ret)
 			goto error;
@@ -834,7 +834,7 @@ static void ncsi_probe_channel(struct ncsi_dev_priv *ndp)
 
 		/* Deselect all possible packages */
 		nca.type = NCSI_PKT_CMD_DP;
-		nca.channel = 0x1f;
+		nca.channel = NCSI_RESERVED_CHANNEL;
 		for (index = 0; index < 8; index++) {
 			nca.package = index;
 			ret = ncsi_xmit_cmd(&nca);
@@ -850,7 +850,7 @@ static void ncsi_probe_channel(struct ncsi_dev_priv *ndp)
 		/* Select all possible packages */
 		nca.type = NCSI_PKT_CMD_SP;
 		nca.bytes[0] = 1;
-		nca.channel = 0x1f;
+		nca.channel = NCSI_RESERVED_CHANNEL;
 		for (index = 0; index < 8; index++) {
 			nca.package = index;
 			ret = ncsi_xmit_cmd(&nca);
@@ -903,7 +903,7 @@ static void ncsi_probe_channel(struct ncsi_dev_priv *ndp)
 		nca.type = NCSI_PKT_CMD_SP;
 		nca.bytes[0] = 1;
 		nca.package = ndp->active_package->id;
-		nca.channel = 0x1f;
+		nca.channel = NCSI_RESERVED_CHANNEL;
 		ret = ncsi_xmit_cmd(&nca);
 		if (ret)
 			goto error;
@@ -960,7 +960,7 @@ static void ncsi_probe_channel(struct ncsi_dev_priv *ndp)
 		/* Deselect the active package */
 		nca.type = NCSI_PKT_CMD_DP;
 		nca.package = ndp->active_package->id;
-		nca.channel = 0x1f;
+		nca.channel = NCSI_RESERVED_CHANNEL;
 		ret = ncsi_xmit_cmd(&nca);
 		if (ret)
 			goto error;
-- 
2.1.0
