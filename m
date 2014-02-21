From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] neigh: fix setting of default gc_* values
Date: Fri, 21 Feb 2014 14:52:57 +0100
Message-ID: <1392990777-9446-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, gaofeng@cn.fujitsu.com,
	hannes@stressinduktion.org, joe@perches.com, vfalico@redhat.com,
	ffusco@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:48325 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755996AbaBUNxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 08:53:03 -0500
Received: by mail-ee0-f48.google.com with SMTP id t10so1631193eei.7
        for <netdev@vger.kernel.org>; Fri, 21 Feb 2014 05:53:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes bug introduced by:
commit 1d4c8c29841b9991cdf3c7cc4ba7f96a94f104ca
"neigh: restore old behaviour of default parms values"

The thing is that in neigh_sysctl_register, extra1 and extra2 which were
previously set for NEIGH_VAR_GC_* are overwritten. That leads to
nonsense int limits for gc_* variables. So fix this by not touching
extra* fields for gc_* variables.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/neighbour.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index b9e9e0d..e1aa0f3 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -3046,7 +3046,7 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 	if (!t)
 		goto err;
 
-	for (i = 0; i < ARRAY_SIZE(t->neigh_vars); i++) {
+	for (i = 0; i < NEIGH_VAR_GC_INTERVAL; i++) {
 		t->neigh_vars[i].data += (long) p;
 		t->neigh_vars[i].extra1 = dev;
 		t->neigh_vars[i].extra2 = p;
-- 
1.8.5.3
