From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 1/4] openvswitch: Remove vport get_name()
Date: Sat, 29 Aug 2015 17:44:05 -0700
Message-ID: <1440895448-16363-2-git-send-email-pshelar@nicira.com>
References: <1440895448-16363-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34215 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752909AbbH3AoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 20:44:16 -0400
Received: by pabzx8 with SMTP id zx8so99968177pab.1
        for <netdev@vger.kernel.org>; Sat, 29 Aug 2015 17:44:15 -0700 (PDT)
In-Reply-To: <1440895448-16363-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unused get_name() function pointer from vport ops.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/vport.h |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index b88b3ee..2f35244 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -157,7 +157,6 @@ struct vport_parms {
  * @get_options: Appends vport-specific attributes for the configuration of an
  * existing vport to a &struct sk_buff.  May be %NULL for a vport that does not
  * have any configuration.
- * @get_name: Get the device's name.
  * @send: Send a packet on the device.  Returns the length of the packet sent,
  * zero for dropped packets or negative for error.
  * @get_egress_tun_info: Get the egress tunnel 5-tuple and other info for
@@ -173,9 +172,6 @@ struct vport_ops {
 	int (*set_options)(struct vport *, struct nlattr *);
 	int (*get_options)(const struct vport *, struct sk_buff *);
 
-	/* Called with rcu_read_lock or ovs_mutex. */
-	const char *(*get_name)(const struct vport *);
-
 	int (*send)(struct vport *, struct sk_buff *);
 	int (*get_egress_tun_info)(struct vport *, struct sk_buff *,
 				   struct ip_tunnel_info *);
@@ -239,7 +235,7 @@ static inline void ovs_skb_postpush_rcsum(struct sk_buff *skb,
 
 static inline const char *ovs_vport_name(struct vport *vport)
 {
-	return vport->dev ? vport->dev->name : vport->ops->get_name(vport);
+	return vport->dev->name;
 }
 
 int ovs_vport_ops_register(struct vport_ops *ops);
-- 
1.7.1
