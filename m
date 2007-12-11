From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] NET : dst_ifdown() cleanup
Date: Tue, 11 Dec 2007 04:59:22 +0100
Message-ID: <475E0B1A.9030406@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060604060604060702010703"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:39135 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744AbXLKD7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 22:59:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060604060604060702010703
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This cleanup shrinks size of net/core/dst.o on i386 from 1299 to 1289 bytes.
(This is because dev_hold()/dev_put() are doing atomic_inc()/atomic_dec() and 
force compiler to re-evaluate memory contents.)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------060604060604060702010703
Content-Type: text/plain;
 name="dst_ifdown.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="dst_ifdown.patch"

diff --git a/net/core/dst.c b/net/core/dst.c
index 5c6cfc4..7eceeba 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -284,8 +284,8 @@ static inline void dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 		dev_put(dev);
 		if (dst->neighbour && dst->neighbour->dev == dev) {
 			dst->neighbour->dev = dst->dev;
+			dev_hold(dst->dev);
 			dev_put(dev);
-			dev_hold(dst->neighbour->dev);
 		}
 	}
 }

--------------060604060604060702010703--
