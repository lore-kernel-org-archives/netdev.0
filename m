From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net] net: bridge: fix returning of vlan range op errors
Date: Thu, 19 Oct 2017 20:17:32 +0300
Message-ID: <1508433452-23812-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: bridge@lists.linux-foundation.org, roopa@cumulusnetworks.com,
        stephen@networkplumber.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:56537 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752834AbdJSRRg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 13:17:36 -0400
Received: by mail-wm0-f65.google.com with SMTP id l68so17760665wmd.5
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 10:17:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When vlan tunnels were introduced, vlan range errors got silently
dropped and instead 0 was returned always. Restore the previous
behaviour and return errors to user-space.

Fixes: efa5356b0d97 ("bridge: per vlan dst_metadata netlink support")
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
err should be always set because we have a check for the vid range above
the loop and it must ensure we will go through the loop at least once

 net/bridge/br_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 3bc890716c89..de2152730809 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -573,7 +573,7 @@ static int br_process_vlan_info(struct net_bridge *br,
 		}
 		*vinfo_last = NULL;
 
-		return 0;
+		return err;
 	}
 
 	return br_vlan_info(br, p, cmd, vinfo_curr);
-- 
2.1.4
