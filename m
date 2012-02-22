From: roy.qing.li@gmail.com
Subject: [PATCH 2/3] ethernet/broadcom: ip6_route_output() never returns NULL.
Date: Wed, 22 Feb 2012 16:10:50 +0800
Message-ID: <1329898251-5357-2-git-send-email-roy.qing.li@gmail.com>
References: <1329898251-5357-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:41798 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752697Ab2BVILs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 03:11:48 -0500
Received: by eekc14 with SMTP id c14so3061517eek.19
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2012 00:11:47 -0800 (PST)
In-Reply-To: <1329898251-5357-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: RongQing.Li <roy.qing.li@gmail.com>

ip6_route_output() never returns NULL, so it is wrong to
check if the return value is NULL.

Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
---
 drivers/net/ethernet/broadcom/cnic.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index df42995..7b65716 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -3616,7 +3616,11 @@ static int cnic_get_v6_route(struct sockaddr_in6 *dst_addr,
 		fl6.flowi6_oif = dst_addr->sin6_scope_id;
 
 	*dst = ip6_route_output(&init_net, NULL, &fl6);
-	if (*dst)
+	if ((*dst)->error) {
+		dst_release(*dst);
+		*dst = NULL;
+		return -ENETUNREACH;
+	} else
 		return 0;
 #endif
 
-- 
1.7.1
