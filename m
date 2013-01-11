From: Kim Phillips <kim.phillips@freescale.com>
Subject: [net-next] gianfar: use more portable i/o accessors
Date: Fri, 11 Jan 2013 16:18:21 -0600
Message-ID: <20130111161821.d62a0a60ee8d1005fb14b4d5@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:59313
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755655Ab3AKWU5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 17:20:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in/out_be32 accessors are Power arch centric whereas
ioread/writebe32 are available in other arches.  Also, unlike
in/out_be32, ioread/writebe32 expect non-volatile address arguments.

Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 1b6a67c..91bb2de 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -1136,16 +1136,16 @@ static inline int gfar_has_errata(struct gfar_private *priv,
 	return priv->errata & err;
 }
 
-static inline u32 gfar_read(volatile unsigned __iomem *addr)
+static inline u32 gfar_read(unsigned __iomem *addr)
 {
 	u32 val;
-	val = in_be32(addr);
+	val = ioread32be(addr);
 	return val;
 }
 
-static inline void gfar_write(volatile unsigned __iomem *addr, u32 val)
+static inline void gfar_write(unsigned __iomem *addr, u32 val)
 {
-	out_be32(addr, val);
+	iowrite32be(val, addr);
 }
 
 static inline void gfar_write_filer(struct gfar_private *priv,
-- 
1.8.1
