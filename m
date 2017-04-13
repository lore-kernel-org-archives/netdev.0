From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net] net: vrf: Fix setting NLM_F_EXCL flag when adding l3mdev rule
Date: Thu, 13 Apr 2017 10:57:15 -0600
Message-ID: <20170413165715.10365-1-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:33304 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753074AbdDMQ5T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 12:57:19 -0400
Received: by mail-pg0-f50.google.com with SMTP id x125so33171836pgb.0
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 09:57:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only need 1 l3mdev FIB rule. Fix setting NLM_F_EXCL in the nlmsghdr.

Fixes: 1aa6c4f6b8cd8 ("net: vrf: Add l3mdev rules on first device create")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 22379da63400..6a6e7f2fee29 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -1125,7 +1125,7 @@ static int vrf_fib_rule(const struct net_device *dev, __u8 family, bool add_it)
 		goto nla_put_failure;
 
 	/* rule only needs to appear once */
-	nlh->nlmsg_flags &= NLM_F_EXCL;
+	nlh->nlmsg_flags |= NLM_F_EXCL;
 
 	frh = nlmsg_data(nlh);
 	memset(frh, 0, sizeof(*frh));
-- 
2.11.0 (Apple Git-81)
