From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH RESEND net] openvswitch: disable LRO
Date: Tue,  2 Jun 2015 14:36:34 +0200
Message-ID: <5d7463bdfc32deb4c0b32ba7d9abf540fc6afed8.1433248445.git.jbenc@redhat.com>
Cc: Pravin Shelar <pshelar@nicira.com>,
	Flavio Leitner <fbl@sysclose.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46220 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758901AbbFBMhO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2015 08:37:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, openvswitch tries to disable LRO from the user space. This does
not work correctly when the device added is a vlan interface, though.
Instead of dealing with possibly complex stacked cross name space relations
in the user space, do the same as bridging does and call dev_disable_lro in
the kernel.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
Acked-by: Flavio Leitner <fbl@redhat.com>
Acked-by: Pravin B Shelar <pshelar@nicira.com>
---
Resending, the patch seems to be completely missing in patchwork.
---
 net/openvswitch/vport-netdev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 4776282c6417..33e6d6e2908f 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -125,6 +125,7 @@ static struct vport *netdev_create(const struct vport_parms *parms)
 	if (err)
 		goto error_master_upper_dev_unlink;
 
+	dev_disable_lro(netdev_vport->dev);
 	dev_set_promiscuity(netdev_vport->dev, 1);
 	netdev_vport->dev->priv_flags |= IFF_OVS_DATAPATH;
 	rtnl_unlock();
-- 
1.8.3.1
