From: baker.kernel@gmail.com
Subject: [PATCH v3 net-next] xfrm: Add check to prevent un-complete key manager
Date: Mon, 11 Nov 2013 14:39:11 +0800
Message-ID: <1384151951-13549-1-git-send-email-baker.kernel@gmail.com>
References: <1384093556-8987-1-git-send-email-baker.kernel@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Baker Zhang <Baker.kernel@gmail.com>
To: davem@davemloft.net, herbert@gondor.apana.org.au,
	steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:37380 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878Ab3KKGj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 01:39:27 -0500
In-Reply-To: <1384093556-8987-1-git-send-email-baker.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baker Zhang <Baker.kernel@gmail.com>

"acquire" and "compile_policy" callbacks are necessary for a key manager.

Signed-off-by: Baker Zhang <Baker.kernel@gmail.com>
---
Thanks for all reply.

V1:
For current kernel source, there is no problem.

In our vpn product, we need a xfrm_km in kernel module
to monitor the xfrm state change.
thus, the 'acquire' and 'compile_policy' may be NULL.

So I think we should do the check before use it. 

V2:
Align the continuation line according the networking coding style.

V3:
Add check to prevent un-complete key manager at register time.

 net/xfrm/xfrm_state.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index b9c3f9e..178283e 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1806,6 +1806,9 @@ static DEFINE_SPINLOCK(xfrm_km_lock);
 
 int xfrm_register_km(struct xfrm_mgr *km)
 {
+	if (km->acquire == NULL || km->compile_policy == NULL)
+		return -EINVAL;
+
 	spin_lock_bh(&xfrm_km_lock);
 	list_add_tail_rcu(&km->list, &xfrm_km_list);
 	spin_unlock_bh(&xfrm_km_lock);
-- 
1.8.3.2
