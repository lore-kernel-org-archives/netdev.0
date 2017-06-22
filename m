From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] sit: use __GFP_NOWARN for user controlled allocation
Date: Thu, 22 Jun 2017 15:29:33 -0700
Message-ID: <1498170573-24082-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:32893 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753919AbdFVWaC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 18:30:02 -0400
Received: by mail-pf0-f193.google.com with SMTP id w12so4865532pfk.0
        for <netdev@vger.kernel.org>; Thu, 22 Jun 2017 15:30:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The memory allocation size is controlled by user-space,
if it is too large just fail silently and return NULL,
not to mention there is a fallback allocation later.

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv6/sit.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 2378503..f8ad158 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -305,7 +305,7 @@ static int ipip6_tunnel_get_prl(struct ip_tunnel *t,
 	 * we try harder to allocate.
 	 */
 	kp = (cmax <= 1 || capable(CAP_NET_ADMIN)) ?
-		kcalloc(cmax, sizeof(*kp), GFP_KERNEL) :
+		kcalloc(cmax, sizeof(*kp), GFP_KERNEL | __GFP_NOWARN) :
 		NULL;
 
 	rcu_read_lock();
-- 
2.5.5
