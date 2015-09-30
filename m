From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 5/5] bridge: vlan: don't pass flags when creating context only
Date: Wed, 30 Sep 2015 20:16:55 +0200
Message-ID: <1443637015-4153-6-git-send-email-razor@blackwall.org>
References: <1443637015-4153-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, vyasevich@gmail.com,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:38728 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933177AbbI3SRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 14:17:04 -0400
Received: by wiclk2 with SMTP id lk2so74353001wic.1
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 11:17:03 -0700 (PDT)
In-Reply-To: <1443637015-4153-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

We should not pass the original flags when creating a context vlan only
because they may contain some flags that change behaviour in the bridge.
The new global context should be with minimal set of flags, so pass 0
and let br_vlan_add() set the master flag only.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_vlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 7e9d60a402e2..75214a51cf0e 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -197,7 +197,7 @@ static int __vlan_add(struct net_bridge_vlan *v, u16 flags)
 		masterv = br_vlan_find(br->vlgrp, v->vid);
 		if (!masterv) {
 			/* missing global ctx, create it now */
-			err = br_vlan_add(br, v->vid, master_flags);
+			err = br_vlan_add(br, v->vid, 0);
 			if (err)
 				goto out_filt;
 			masterv = br_vlan_find(br->vlgrp, v->vid);
-- 
2.4.3
