From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC 7/7] neighbour: reduce exports
Date: Mon, 14 Aug 2006 14:20:11 -0700
Message-ID: <20060814212144.278517075@localhost.localdomain>
References: <20060814212004.606140865@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:52457 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964961AbWHNVYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 17:24:19 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=neighbour-exports.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function neigh_update_hhs is only used in neighbour.c
and let compiler decide to inline or not.

There are several symbols only used by rtnetlink and since it can
not be a module, there is no reason to export them.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 net/core/neighbour.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

--- net-2.6.19.orig/net/core/neighbour.c
+++ net-2.6.19/net/core/neighbour.c
@@ -906,7 +906,7 @@ out:
 	return rc;
 }
 
-static __inline__ void neigh_update_hhs(struct neighbour *neigh)
+static void neigh_update_hhs(struct neighbour *neigh)
 {
 	struct hh_cache *hh;
 	void (*update)(struct hh_cache*, struct net_device*, unsigned char *) =
@@ -2782,7 +2782,6 @@ void neigh_sysctl_unregister(struct neig
 #endif	/* CONFIG_SYSCTL */
 
 EXPORT_SYMBOL(__neigh_event_send);
-EXPORT_SYMBOL(neigh_add);
 EXPORT_SYMBOL(neigh_changeaddr);
 EXPORT_SYMBOL(neigh_compat_output);
 EXPORT_SYMBOL(neigh_connected_output);
@@ -2803,11 +2802,8 @@ EXPORT_SYMBOL(neigh_table_clear);
 EXPORT_SYMBOL(neigh_table_init);
 EXPORT_SYMBOL(neigh_table_init_no_netlink);
 EXPORT_SYMBOL(neigh_update);
-EXPORT_SYMBOL(neigh_update_hhs);
 EXPORT_SYMBOL(pneigh_enqueue);
 EXPORT_SYMBOL(pneigh_lookup);
-EXPORT_SYMBOL(neightbl_dump_info);
-EXPORT_SYMBOL(neightbl_set);
 
 #ifdef CONFIG_ARPD
 EXPORT_SYMBOL(neigh_app_ns);

--

