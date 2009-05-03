From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 1/2] netns 1/2: don't get/put old netns on CLONE_NEWNET
Date: Mon, 4 May 2009 03:28:25 +0400
Message-ID: <20090503232825.GF16631@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	containers@lists.linux-foundation.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:32675 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756049AbZECX1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2009 19:27:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

copy_net_ns() doesn't copy anything, it creates fresh netns, so get/put of old
netns isn't needed.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Acked-by: Serge Hallyn <serue@us.ibm.com>
---
 net/core/net_namespace.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index e3bebd3..4488010 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -120,10 +120,8 @@ struct net *copy_net_ns(unsigned long flags, struct net *old_net)
 	struct net *new_net = NULL;
 	int err;
 
-	get_net(old_net);
-
 	if (!(flags & CLONE_NEWNET))
-		return old_net;
+		return get_net(old_net);
 
 	err = -ENOMEM;
 	new_net = net_alloc();
@@ -142,7 +140,6 @@ struct net *copy_net_ns(unsigned long flags, struct net *old_net)
 	if (err)
 		goto out_free;
 out:
-	put_net(old_net);
 	return new_net;
 
 out_free:
