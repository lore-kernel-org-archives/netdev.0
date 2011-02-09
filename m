From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Kill NETEVENT_PMTU_UPDATE.
Date: Tue, 08 Feb 2011 16:18:42 -0800 (PST)
Message-ID: <20110208.161842.70196169.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53968
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756047Ab1BIASI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 19:18:08 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id EA43824C088
	for <netdev@vger.kernel.org>; Tue,  8 Feb 2011 16:18:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Nobody actually does anything in response to the event,
so just kill it off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Committed to net-next-2.6

 drivers/net/cxgb3/cxgb3_offload.c |    2 --
 drivers/net/cxgb4/cxgb4_main.c    |    1 -
 include/net/netevent.h            |    1 -
 net/ipv4/route.c                  |    1 -
 net/ipv6/route.c                  |    1 -
 5 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index ef02aa6..7ea94b5 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -967,8 +967,6 @@ static int nb_callback(struct notifier_block *self, unsigned long event,
 		cxgb_neigh_update((struct neighbour *)ctx);
 		break;
 	}
-	case (NETEVENT_PMTU_UPDATE):
-		break;
 	case (NETEVENT_REDIRECT):{
 		struct netevent_redirect *nr = ctx;
 		cxgb_redirect(nr->old, nr->new);
diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index ec35d45..5352c8a 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -2471,7 +2471,6 @@ static int netevent_cb(struct notifier_block *nb, unsigned long event,
 	case NETEVENT_NEIGH_UPDATE:
 		check_neigh_update(data);
 		break;
-	case NETEVENT_PMTU_UPDATE:
 	case NETEVENT_REDIRECT:
 	default:
 		break;
diff --git a/include/net/netevent.h b/include/net/netevent.h
index e82b7ba..22b239c 100644
--- a/include/net/netevent.h
+++ b/include/net/netevent.h
@@ -21,7 +21,6 @@ struct netevent_redirect {
 
 enum netevent_notif_type {
 	NETEVENT_NEIGH_UPDATE = 1, /* arg is struct neighbour ptr */
-	NETEVENT_PMTU_UPDATE,	   /* arg is struct dst_entry ptr */
 	NETEVENT_REDIRECT,	   /* arg is struct netevent_redirect ptr */
 };
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 2e225da..0455af8 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1762,7 +1762,6 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 		}
 		dst_metric_set(dst, RTAX_MTU, mtu);
 		dst_set_expires(dst, ip_rt_mtu_expires);
-		call_netevent_notifiers(NETEVENT_PMTU_UPDATE, dst);
 	}
 }
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 0a63d44..12ec83d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -965,7 +965,6 @@ static void ip6_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 			dst_metric_set(dst, RTAX_FEATURES, features);
 		}
 		dst_metric_set(dst, RTAX_MTU, mtu);
-		call_netevent_notifiers(NETEVENT_PMTU_UPDATE, dst);
 	}
 }
 
-- 
1.7.4

