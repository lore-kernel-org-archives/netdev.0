From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next] vxlan: fix multiple inclusion of vxlan.h
Date: Tue, 25 Aug 2015 18:36:50 +0200
Message-ID: <27e0c4c1aec49f461ba96fac8c40f69b46ef06dd.1440520548.git.jbenc@redhat.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58105 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754398AbbHYQhD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 12:37:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vxlan_get_sk_family inline function was added after the last #endif,
making multiple inclusion of net/vxlan.h fail. Move it to the proper place.

Reported-by: Mark Rustad <mark.d.rustad@intel.com>
Fixes: 705cc62f6728c ("vxlan: provide access function for vxlan socket address family")
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 include/net/vxlan.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 6b3234599a2c..480a319b4c92 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -241,9 +241,10 @@ static inline void vxlan_get_rx_port(struct net_device *netdev)
 {
 }
 #endif
-#endif
 
 static inline unsigned short vxlan_get_sk_family(struct vxlan_sock *vs)
 {
 	return vs->sock->sk->sk_family;
 }
+
+#endif
-- 
1.8.3.1
