From: Monam Agarwal <monamagarwal123@gmail.com>
Subject: [PATCH] net/wireless: Use RCU_INIT_POINTER(x, NULL) in reg.c
Date: Mon, 24 Mar 2014 00:53:40 +0530
Message-ID: <1395602620-15480-1-git-send-email-monamagarwal123@gmail.com>
To: johannes@sipsolutions.net, linville@tuxdriver.com,
	davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:61760 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753030AbaCWTYl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2014 15:24:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replaces rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL)

The rcu_assign_pointer() ensures that the initialization of a structure       
is carried out before storing a pointer to that structure. 
And in the case of the NULL pointer, there is no structure to initialize. 
So, rcu_assign_pointer(p, NULL) can be safely converted to RCU_INIT_POINTER(p, NULL)

Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>
---
 net/wireless/reg.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 90b82e0..4dc08cc 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -2594,7 +2594,7 @@ void wiphy_regulatory_deregister(struct wiphy *wiphy)
 		reg_num_devs_support_basehint--;
 
 	rcu_free_regdom(get_wiphy_regdom(wiphy));
-	rcu_assign_pointer(wiphy->regd, NULL);
+	RCU_INIT_POINTER(wiphy->regd, NULL);
 
 	if (lr)
 		request_wiphy = wiphy_idx_to_wiphy(lr->wiphy_idx);
-- 
1.7.9.5
