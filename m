From: roy.qing.li@gmail.com
Subject: [PATCH] xfrm: fix a rcu_read_lock() imbalance in make_blackhole
Date: Tue, 18 Sep 2012 16:40:10 +0800
Message-ID: <1347957610-7422-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:48227 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754466Ab2IRIkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 04:40:22 -0400
Received: by pbbrr13 with SMTP id rr13so10611364pbb.19
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 01:40:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

if xfrm_policy_get_afinfo returns 0, it has already called rcu_read_unlock,
xfrm_policy_put_afinfo should not be called again.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/xfrm/xfrm_policy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 741a32a..878835b 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1780,7 +1780,7 @@ static struct dst_entry *make_blackhole(struct net *net, u16 family,
 
 	if (!afinfo) {
 		dst_release(dst_orig);
-		ret = ERR_PTR(-EINVAL);
+		return ERR_PTR(-EINVAL);
 	} else {
 		ret = afinfo->blackhole_route(net, dst_orig);
 	}
-- 
1.7.4.1
