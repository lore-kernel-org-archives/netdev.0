From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH net-next] ipv6: don't free static mem in the case of init_net
Date: Tue, 26 Mar 2013 00:25:25 +0800
Message-ID: <1364228725-16218-1-git-send-email-honkiko@gmail.com>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	Hong Zhiguo <honkiko@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:61299 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758200Ab3CYQZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 12:25:41 -0400
Received: by mail-pb0-f41.google.com with SMTP id mc8so905147pbc.14
        for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 09:25:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
---
 net/ipv6/addrconf.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index fa36a67..1f5f51f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4891,10 +4891,14 @@ static int __net_init addrconf_init_net(struct net *net)
 err_reg_dflt:
 	__addrconf_sysctl_unregister(all);
 err_reg_all:
-	kfree(dflt);
+	if (dflt != &ipv6_devconf_dflt) {
+		kfree(dflt);
+	}
 #endif
 err_alloc_dflt:
-	kfree(all);
+	if (all != &ipv6_devconf) {
+		kfree(all);
+	}
 err_alloc_all:
 	return err;
 }
-- 
1.7.10.4
