From: Joe Stringer <joe@ovn.org>
Subject: [PATCH net-next] openvswitch: Free tmpl with tmpl_free.
Date: Thu,  1 Sep 2016 18:01:47 -0700
Message-ID: <20160902010147.16439-1-joe@ovn.org>
Cc: jesse@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:42865 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750795AbcIBBB7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 21:01:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an error occurs during conntrack template creation as part of
actions validation, we need to free the template. Previously we've been
using nf_ct_put() to do this, but nf_ct_tmpl_free() is more appropriate.

Signed-off-by: Joe Stringer <joe@ovn.org>
---
 net/openvswitch/conntrack.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index e054a748ff25..31045ef44a82 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -1367,7 +1367,7 @@ static void __ovs_ct_free_action(struct ovs_conntrack_info *ct_info)
 	if (ct_info->helper)
 		module_put(ct_info->helper->me);
 	if (ct_info->ct)
-		nf_ct_put(ct_info->ct);
+		nf_ct_tmpl_free(ct_info->ct);
 }
 
 void ovs_ct_init(struct net *net)
-- 
2.9.3
