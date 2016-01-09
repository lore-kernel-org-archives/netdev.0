From: =?UTF-8?q?J=CE=B5an=20Sacren?= <sakiwit@gmail.com>
Subject: [PATCH net-next 2/3] openvswitch: fix struct geneve_port member name
Date: Sat,  9 Jan 2016 16:07:10 -0700
Message-ID: <1452380831-11258-3-git-send-email-sakiwit@gmail.com>
Cc: Pravin Shelar <pshelar@nicira.com>, dev@openvswitch.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33155 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756247AbcAIXHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2016 18:07:53 -0500
Received: by mail-pf0-f195.google.com with SMTP id e65so2165463pfe.0
        for <netdev@vger.kernel.org>; Sat, 09 Jan 2016 15:07:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>

commit 6b001e682e90 ("openvswitch: Use Geneve device.")

The commit above introduced 'port_no' as the name for the member of
struct geneve_port. The correct name should be 'dst_port' as described
in the kernel doc. Let's fix that member name and all the pertinent
instances so that both doc and code would be consistent.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
---
 net/openvswitch/vport-geneve.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index e41cd12d9b2d..30ab8e127288 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -34,7 +34,7 @@ static struct vport_ops ovs_geneve_vport_ops;
  * @dst_port: destination port.
  */
 struct geneve_port {
-	u16 port_no;
+	u16 dst_port;
 };
 
 static inline struct geneve_port *geneve_vport(const struct vport *vport)
@@ -47,7 +47,7 @@ static int geneve_get_options(const struct vport *vport,
 {
 	struct geneve_port *geneve_port = geneve_vport(vport);
 
-	if (nla_put_u16(skb, OVS_TUNNEL_ATTR_DST_PORT, geneve_port->port_no))
+	if (nla_put_u16(skb, OVS_TUNNEL_ATTR_DST_PORT, geneve_port->dst_port))
 		return -EMSGSIZE;
 	return 0;
 }
@@ -83,7 +83,7 @@ static struct vport *geneve_tnl_create(const struct vport_parms *parms)
 		return vport;
 
 	geneve_port = geneve_vport(vport);
-	geneve_port->port_no = dst_port;
+	geneve_port->dst_port = dst_port;
 
 	rtnl_lock();
 	dev = geneve_dev_create_fb(net, parms->name, NET_NAME_USER, dst_port);
