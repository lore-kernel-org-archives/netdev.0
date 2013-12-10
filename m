From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] neighbour: always have struct net pointer in struct neigh_parms
Date: Tue, 10 Dec 2013 08:44:57 +0100
Message-ID: <1386661497-1688-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:40975 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566Ab3LJHpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 02:45:02 -0500
Received: by mail-ee0-f44.google.com with SMTP id b57so1998326eek.31
        for <netdev@vger.kernel.org>; Mon, 09 Dec 2013 23:45:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes compile error when CONFIG_NET_NS is not set.

Introduced by:
commit 1d4c8c29841b9991cdf3c7cc4ba7f96a94f104ca
    "neigh: restore old behaviour of default parms values"

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/neighbour.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 41b1ce6..157c038 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -65,9 +65,7 @@ enum {
 };
 
 struct neigh_parms {
-#ifdef CONFIG_NET_NS
 	struct net *net;
-#endif
 	struct net_device *dev;
 	struct neigh_parms *next;
 	int	(*neigh_setup)(struct neighbour *);
-- 
1.8.3.1
