From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] openvswitch: properly refcount vport-vxlan module
Date: Wed, 25 Nov 2015 18:05:27 +0100
Message-ID: <1448471127-26271-1-git-send-email-pabeni@redhat.com>
Cc: Pravin Shelar <pshelar@nicira.com>, Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61577 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752271AbbKYRI3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Nov 2015 12:08:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After 614732eaa12d, no refcount is mainteined for the vport-vxlan module.
This allows the userspace to remove such module while vport-vxlan
devices still exist, which lead to later oops, i.e. when
the openvswitch module is removed.

Fixes: 614732eaa12d ("openvswitch: Use regular VXLAN net_device device")

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/openvswitch/vport-vxlan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index 1605691..a2a83f3 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -152,6 +152,7 @@ static struct vport_ops ovs_vxlan_netdev_vport_ops = {
 	.destroy		= ovs_netdev_tunnel_destroy,
 	.get_options		= vxlan_get_options,
 	.send			= dev_queue_xmit,
+	.owner			= THIS_MODULE,
 };
 
 static int __init ovs_vxlan_tnl_init(void)
-- 
1.8.3.1
