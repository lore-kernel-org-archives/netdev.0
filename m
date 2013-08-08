From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next] rtnetlink: Fix inverted check in
 ndo_dflt_fdb_del()
Date: Thu, 08 Aug 2013 15:19:48 -0700
Message-ID: <1376000389.22896.34.camel@sridhar.usor.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:59624 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758212Ab3HHWT6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Aug 2013 18:19:58 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sri@us.ibm.com>;
	Thu, 8 Aug 2013 18:19:57 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 0A76438C803B
	for <netdev@vger.kernel.org>; Thu,  8 Aug 2013 18:19:54 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r78MJti0133016
	for <netdev@vger.kernel.org>; Thu, 8 Aug 2013 18:19:55 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r78MJs4N032242
	for <netdev@vger.kernel.org>; Thu, 8 Aug 2013 18:19:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix inverted check when deleting an fdb entry.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
---
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 0b2972c..618dbe4 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2179,7 +2179,7 @@ int ndo_dflt_fdb_del(struct ndmsg *ndm,
 	/* If aging addresses are supported device will need to
 	 * implement its own handler for this.
 	 */
-	if (ndm->ndm_state & NUD_PERMANENT) {
+	if (!(ndm->ndm_state & NUD_PERMANENT)) {
 		pr_info("%s: FDB only supports static addresses\n", dev->name);
 		return -EINVAL;
 	}
