From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH v2 net-next 01/13] ip_tunnels: remove custom alignment and packing
Date: Wed, 19 Aug 2015 12:09:51 +0200
Message-ID: <47163461d8b7ef0fa60ea3fd31d0cc0e60303913.1439978875.git.jbenc@redhat.com>
References: <cover.1439978875.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49787 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753622AbbHSKLd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 06:11:33 -0400
In-Reply-To: <cover.1439978875.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The custom alignment of struct ip_tunnel_key is unnecessary. In struct
sw_flow_key, it starts at offset 256, in struct ip_tunnel_info it's the
first field.

The structure is also packed even without the __packed keyword.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 include/net/ip_tunnels.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 984dbfa15e13..81cf11c931e4 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -36,7 +36,7 @@ struct ip_tunnel_key {
 	__u8			ipv4_ttl;
 	__be16			tp_src;
 	__be16			tp_dst;
-} __packed __aligned(4); /* Minimize padding. */
+};
 
 /* Indicates whether the tunnel info structure represents receive
  * or transmit tunnel parameters.
-- 
1.8.3.1
