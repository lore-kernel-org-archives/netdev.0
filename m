From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 2/8] vxlan: Fix sparse warnings.
Date: Thu, 20 Jun 2013 00:26:31 -0700
Message-ID: <1371713191-8115-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog108.obsmtp.com ([74.125.149.199]:38303 "HELO
	na3sys009aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753944Ab3FTH0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 03:26:34 -0400
Received: by mail-pb0-f54.google.com with SMTP id ro2so5933810pbb.13
        for <netdev@vger.kernel.org>; Thu, 20 Jun 2013 00:26:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix following sparse warnings.
drivers/net/vxlan.c:238:44: warning: incorrect type in argument 3 (different base types)
drivers/net/vxlan.c:238:44:    expected restricted __be32 [usertype] value
drivers/net/vxlan.c:238:44:    got unsigned int const [unsigned] [usertype] remote_vni
drivers/net/vxlan.c:1735:18: warning: incorrect type in initializer (different signedness)
drivers/net/vxlan.c:1735:18:    expected int *id
drivers/net/vxlan.c:1735:18:    got unsigned int static [toplevel] *<noident>

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 173705f..91d04f9 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -78,7 +78,7 @@ static bool log_ecn_error = true;
 module_param(log_ecn_error, bool, 0644);
 MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 
-static unsigned int vxlan_net_id;
+static int vxlan_net_id;
 
 /* per UDP socket information */
 struct vxlan_sock {
@@ -235,7 +235,7 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 	    nla_put_be16(skb, NDA_PORT, rdst->remote_port))
 		goto nla_put_failure;
 	if (rdst->remote_vni != vxlan->default_dst.remote_vni &&
-	    nla_put_be32(skb, NDA_VNI, rdst->remote_vni))
+	    nla_put_u32(skb, NDA_VNI, rdst->remote_vni))
 		goto nla_put_failure;
 	if (rdst->remote_ifindex &&
 	    nla_put_u32(skb, NDA_IFINDEX, rdst->remote_ifindex))
-- 
1.7.1
