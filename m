From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] bridge: vlan_tunnel: explicitly reset metadata attrs to NULL on failure
Date: Thu, 16 Feb 2017 11:29:21 -0800
Message-ID: <1487273361-51517-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:36278 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932344AbdBPT3b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 14:29:31 -0500
Received: by mail-pf0-f175.google.com with SMTP id 189so7591831pfu.3
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 11:29:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Fixes: efa5356b0d97 ("bridge: per vlan dst_metadata netlink support")
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/bridge/br_vlan_tunnel.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/bridge/br_vlan_tunnel.c b/net/bridge/br_vlan_tunnel.c
index b2b79a0..6d2c4ee 100644
--- a/net/bridge/br_vlan_tunnel.c
+++ b/net/bridge/br_vlan_tunnel.c
@@ -85,6 +85,8 @@ static int __vlan_tunnel_info_add(struct net_bridge_vlan_group *vg,
 	return 0;
 out:
 	dst_release(&vlan->tinfo.tunnel_dst->dst);
+	vlan->tinfo.tunnel_dst = NULL;
+	vlan->tinfo.tunnel_id = 0;
 
 	return err;
 }
-- 
1.7.10.4
