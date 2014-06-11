From: Dmitry Popov <ixaphire@qrator.net>
Subject: [PATCH] ip_vti: fix sparse warnings for VTI_ISVTI
Date: Wed, 11 Jun 2014 15:09:14 +0400
Message-ID: <20140611150914.c3cb48bb8a1a760564f5db6e@qrator.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	trivial@kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the following sparse warnings:

net/ipv4/ip_tunnel.c:245:53: warning: restricted __be16 degrades to integer
net/ipv4/ip_vti.c:321:19: warning: incorrect type in assignment (different base types)
net/ipv4/ip_vti.c:321:19:    expected restricted __be16 [addressable] [assigned] [usertype] i_flags
net/ipv4/ip_vti.c:321:19:    got int
net/ipv4/ip_vti.c:447:24: warning: incorrect type in assignment (different base types)
net/ipv4/ip_vti.c:447:24:    expected restricted __be16 [usertype] i_flags
net/ipv4/ip_vti.c:447:24:    got int

Since VTI_ISVTI is always used with ip_tunnel_parm->i_flags (which is __be16),
we can __force cast VTI_ISVTI to __be16 in header file.

Signed-off-by: Dmitry Popov <ixaphire@qrator.net>
---
 include/uapi/linux/if_tunnel.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index aee73d0..3bce9e9 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -100,7 +100,7 @@ enum {
 #define IFLA_GRE_MAX	(__IFLA_GRE_MAX - 1)
 
 /* VTI-mode i_flags */
-#define VTI_ISVTI 0x0001
+#define VTI_ISVTI ((__force __be16)0x0001)
 
 enum {
 	IFLA_VTI_UNSPEC,
