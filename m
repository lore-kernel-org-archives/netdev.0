From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] audit: remove useless synchronize_net()
Date: Tue, 29 Nov 2016 09:14:56 -0800
Message-ID: <1480439696-21818-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Richard Guy Briggs <rgb@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36178 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752603AbcK2RPH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 12:15:07 -0500
Received: by mail-pg0-f68.google.com with SMTP id x23so16953399pgx.3
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 09:15:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netlink kernel socket is protected by refcount, not RCU.
Its rcv path is neither protected by RCU. So the synchronize_net()
is just pointless.

Cc: Richard Guy Briggs <rgb@redhat.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 kernel/audit.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index 92c463d..67b9fbd8 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -1172,9 +1172,8 @@ static void __net_exit audit_net_exit(struct net *net)
 		audit_sock = NULL;
 	}
 
-	RCU_INIT_POINTER(aunet->nlsk, NULL);
-	synchronize_net();
 	netlink_kernel_release(sock);
+	aunet->nlsk = NULL;
 }
 
 static struct pernet_operations audit_net_ops __net_initdata = {
-- 
2.1.0
