From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] neigh: use neigh_parms_net() to get struct neigh_parms->net pointer
Date: Tue, 10 Dec 2013 23:55:07 +0100
Message-ID: <1386716107-18843-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:47161 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960Ab3LJWzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 17:55:12 -0500
Received: by mail-ea0-f179.google.com with SMTP id r15so2562584ead.38
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 14:55:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes compile error when CONFIG_NET_NS is not set.

Introduced by:
commit 1d4c8c29841b9991cdf3c7cc4ba7f96a94f104ca
    "neigh: restore old behaviour of default parms values"

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/neighbour.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index ce2b775..8be82a7 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2850,7 +2850,7 @@ static void neigh_proc_update(struct ctl_table *ctl, int write)
 {
 	struct net_device *dev = ctl->extra1;
 	struct neigh_parms *p = ctl->extra2;
-	struct net *net = p->net;
+	struct net *net = neigh_parms_net(p);
 	int index = (int *) ctl->data - p->data;
 
 	if (!write)
-- 
1.8.3.1
