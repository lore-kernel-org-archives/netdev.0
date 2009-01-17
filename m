From: Jiri Slaby <jirislaby@gmail.com>
Subject: [PATCH 1/1] NET: net_namespace, fix lock imbalance
Date: Sat, 17 Jan 2009 17:47:12 +0100
Message-ID: <1232210832-30041-1-git-send-email-jirislaby@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Slaby <jirislaby@gmail.com>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.wellnetcz.com ([212.24.148.102]:55728 "EHLO
	smtp.wellnetcz.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758060AbZAQQrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2009 11:47:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

register_pernet_gen_subsys omits mutex_unlock in one fail path.
Fix it.

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
---
 net/core/net_namespace.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 55cffad..55151fa 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -341,8 +341,8 @@ again:
 	rv = register_pernet_operations(first_device, ops);
 	if (rv < 0)
 		ida_remove(&net_generic_ids, *id);
-	mutex_unlock(&net_mutex);
 out:
+	mutex_unlock(&net_mutex);
 	return rv;
 }
 EXPORT_SYMBOL_GPL(register_pernet_gen_subsys);
-- 
1.6.1

