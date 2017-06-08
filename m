From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] openvswitch: warn about missing first netlink attribute
Date: Thu,  8 Jun 2017 10:37:45 +0200
Message-ID: <1496911065-6912-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, pshelar@nicira.com, dev@openvswitch.org,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:41253 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751427AbdFHIhx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 04:37:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first netlink attribute (value 0) must always be defined
as none/unspec.

Because we cannot change an existing UAPI, I add a comment to point the
mistake and avoid to propagate it in a new ovs API in the future.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/openvswitch.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 61b7d36dfe34..156ee4cab82e 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -343,6 +343,7 @@ enum ovs_key_attr {
 #define OVS_KEY_ATTR_MAX (__OVS_KEY_ATTR_MAX - 1)
 
 enum ovs_tunnel_key_attr {
+	/* OVS_TUNNEL_KEY_ATTR_NONE, standard nl API requires this attribute! */
 	OVS_TUNNEL_KEY_ATTR_ID,                 /* be64 Tunnel ID */
 	OVS_TUNNEL_KEY_ATTR_IPV4_SRC,           /* be32 src IP address. */
 	OVS_TUNNEL_KEY_ATTR_IPV4_DST,           /* be32 dst IP address. */
-- 
2.8.1
