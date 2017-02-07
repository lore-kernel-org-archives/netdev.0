From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next] bridge: tunnel: fix attribute checks in br_parse_vlan_tunnel_info
Date: Tue,  7 Feb 2017 12:46:46 +0100
Message-ID: <1486468006-8080-1-git-send-email-nikolay@cumulusnetworks.com>
References: <c341a60f-f3d1-29f6-b825-5ebd1432e5b9@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, bridge@lists.linux-foundation.org,
        Colin Ian King <colin.king@canonical.com>,
        "David S. Miller" <davem@davemloft.net>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:38415 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753285AbdBGLrO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 06:47:14 -0500
Received: by mail-wm0-f50.google.com with SMTP id r141so148888848wmg.1
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 03:47:14 -0800 (PST)
In-Reply-To: <c341a60f-f3d1-29f6-b825-5ebd1432e5b9@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These checks should go after the attributes have been parsed otherwise
we're using tb uninitialized.

Fixes: efa5356b0d97 ("bridge: per vlan dst_metadata netlink support")
Reported-by: Colin Ian King <colin.king@canonical.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_netlink_tunnel.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_netlink_tunnel.c b/net/bridge/br_netlink_tunnel.c
index 99c68012c9d4..62eaf750bd9e 100644
--- a/net/bridge/br_netlink_tunnel.c
+++ b/net/bridge/br_netlink_tunnel.c
@@ -229,15 +229,15 @@ int br_parse_vlan_tunnel_info(struct nlattr *attr,
 
 	memset(tinfo, 0, sizeof(*tinfo));
 
-	if (!tb[IFLA_BRIDGE_VLAN_TUNNEL_ID] ||
-	    !tb[IFLA_BRIDGE_VLAN_TUNNEL_VID])
-		return -EINVAL;
-
 	err = nla_parse_nested(tb, IFLA_BRIDGE_VLAN_TUNNEL_MAX,
 			       attr, vlan_tunnel_policy);
 	if (err < 0)
 		return err;
 
+	if (!tb[IFLA_BRIDGE_VLAN_TUNNEL_ID] ||
+	    !tb[IFLA_BRIDGE_VLAN_TUNNEL_VID])
+		return -EINVAL;
+
 	tun_id = nla_get_u32(tb[IFLA_BRIDGE_VLAN_TUNNEL_ID]);
 	vid = nla_get_u16(tb[IFLA_BRIDGE_VLAN_TUNNEL_VID]);
 	if (vid >= VLAN_VID_MASK)
-- 
2.1.4
