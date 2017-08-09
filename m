From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: [PATCH net] geneve: maximum value of VNI cannot be used
Date: Tue,  8 Aug 2017 17:26:24 -0700
Message-ID: <1502238384-14440-1-git-send-email-girish.moodalbail@oracle.com>
To: <pshelar@ovn.org>, <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:29669 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751229AbdHIAjA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 20:39:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Geneve's Virtual Network Identifier (VNI) is 24 bit long, so the range
of values for it would be from 0 to 16777215 (2^24 -1).  However, one
cannot create a geneve device with VNI set to 16777215. This patch fixes
this issue.

Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>
---
 drivers/net/geneve.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 745d57ae..8b8565d 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1099,7 +1099,7 @@ static int geneve_validate(struct nlattr *tb[], struct nlattr *data[],
 	if (data[IFLA_GENEVE_ID]) {
 		__u32 vni =  nla_get_u32(data[IFLA_GENEVE_ID]);
 
-		if (vni >= GENEVE_VID_MASK)
+		if (vni >= GENEVE_N_VID)
 			return -ERANGE;
 	}
 
-- 
1.8.3.1
