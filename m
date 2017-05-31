From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net] mpls: fix clearing of dead nh_flags on link up
Date: Tue, 30 May 2017 23:50:36 -0700
Message-ID: <1496213436-33961-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, dsahern@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:32806 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751002AbdEaGul (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 02:50:41 -0400
Received: by mail-pf0-f175.google.com with SMTP id e193so6034897pfh.0
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 23:50:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

recent fixes to use WRITE_ONCE for nh_flags on link up,
accidently ended up leaving the deadflags on a nh. This patch
fixes the WRITE_ONCE to use freshly evaluated nh_flags.

Fixes: 39eb8cd17588 ("net: mpls: rt_nhn_alive and nh_flags should be accessed using READ_ONCE")
Reported-by: Satish Ashok <sashok@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/mpls/af_mpls.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 94b3317..b51582d 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -1483,7 +1483,7 @@ static void mpls_ifup(struct net_device *dev, unsigned int flags)
 				continue;
 			alive++;
 			nh_flags &= ~flags;
-			WRITE_ONCE(nh->nh_flags, flags);
+			WRITE_ONCE(nh->nh_flags, nh_flags);
 		} endfor_nexthops(rt);
 
 		WRITE_ONCE(rt->rt_nhn_alive, alive);
-- 
1.9.1
