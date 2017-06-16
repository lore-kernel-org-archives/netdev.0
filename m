From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH net-next 21/21] net: add debug atomic_inc_not_zero() in dst_hold()
Date: Fri, 16 Jun 2017 10:47:44 -0700
Message-ID: <20170616174744.139688-22-tracywwnj@gmail.com>
References: <20170616174744.139688-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34653 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752595AbdFPRsy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 13:48:54 -0400
Received: by mail-pf0-f195.google.com with SMTP id d5so7560484pfe.1
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 10:48:44 -0700 (PDT)
In-Reply-To: <20170616174744.139688-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

This patch is meant to add a debug warning on the situation where dst is
being held during its destroy phase. This could potentially cause double
free issue on the dst.

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 include/net/dst.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index d912b44d2dcb..f73611ec4017 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -251,7 +251,7 @@ static inline void dst_hold(struct dst_entry *dst)
 	 * __pad_to_align_refcnt declaration in struct dst_entry
 	 */
 	BUILD_BUG_ON(offsetof(struct dst_entry, __refcnt) & 63);
-	atomic_inc(&dst->__refcnt);
+	WARN_ON(atomic_inc_not_zero(&dst->__refcnt) == 0);
 }
 
 static inline void dst_use(struct dst_entry *dst, unsigned long time)
-- 
2.13.1.518.g3df882009-goog
