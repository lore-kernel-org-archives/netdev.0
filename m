From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] netns: fix net_generic array leak
Date: Wed, 15 Oct 2008 08:15:22 +0400
Message-ID: <20081015041522.GD24058@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xemul@openvz.org, den@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:50138 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835AbYJOEM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2008 00:12:26 -0400
Received: by ey-out-2122.google.com with SMTP id 6so914175eyi.37
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 21:12:24 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/core/net_namespace.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -96,7 +96,7 @@ static void net_free(struct net *net)
 		return;
 	}
 #endif
-
+	kfree(net->gen);
 	kmem_cache_free(net_cachep, net);
 }
 
