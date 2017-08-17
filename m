From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf: no need to nullify ri->map in xdp_do_redirect
Date: Thu, 17 Aug 2017 15:07:22 +0200
Message-ID: <782d0b6850cb1a63230c0fd634f1e61d67a01e60.1502975082.git.daniel@iogearbox.net>
Cc: john.fastabend@gmail.com, ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41500 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751574AbdHQNH2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 09:07:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are guaranteed to have a NULL ri->map in this branch since
we test for it earlier, so we don't need to reset it here.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/core/filter.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index e9f8dce..ea3ca34 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2568,7 +2568,6 @@ int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp,
 
 	fwd = dev_get_by_index_rcu(dev_net(dev), index);
 	ri->ifindex = 0;
-	ri->map = NULL;
 	if (unlikely(!fwd)) {
 		bpf_warn_invalid_xdp_redirect(index);
 		return -EINVAL;
-- 
1.9.3
