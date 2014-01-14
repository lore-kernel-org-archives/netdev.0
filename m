From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 13/15] {pktgen, xfrm} Document IPsec usage in pktgen.txt
Date: Tue, 14 Jan 2014 07:49:17 +0100
Message-ID: <1389682159-3260-14-git-send-email-steffen.klassert@secunet.com>
References: <1389682159-3260-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60087 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751531AbaANGtm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 01:49:42 -0500
In-Reply-To: <1389682159-3260-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>

Update pktgen.txt for reference when using IPsec.

Signed-off-by: Fan Du <fan.du@windriver.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 Documentation/networking/pktgen.txt |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/Documentation/networking/pktgen.txt b/Documentation/networking/pktgen.txt
index 75e4fd7..5a61a240 100644
--- a/Documentation/networking/pktgen.txt
+++ b/Documentation/networking/pktgen.txt
@@ -108,7 +108,9 @@ Examples:
                               MPLS_RND, VID_RND, SVID_RND
                               QUEUE_MAP_RND # queue map random
                               QUEUE_MAP_CPU # queue map mirrors smp_processor_id()
+                              IPSEC # Make IPsec encapsulation for packet
 
+ pgset spi SPI_VALUE     Set specific SA used to transform packet.
 
  pgset "udp_src_min 9"   set UDP source port min, If < udp_src_max, then
                          cycle through the port range.
@@ -177,6 +179,18 @@ Note when adding devices to a specific CPU there good idea to also assign
 /proc/irq/XX/smp_affinity so the TX-interrupts gets bound to the same CPU.
 as this reduces cache bouncing when freeing skb's.
 
+Enable IPsec
+============
+Default IPsec transformation with ESP encapsulation plus Transport mode
+could be enabled by simply setting:
+
+pgset "flag IPSEC"
+pgset "flows 1"
+
+To avoid breaking existing testbed scripts for using AH type and tunnel mode,
+user could use "pgset spi SPI_VALUE" to specify which formal of transformation
+to employ.
+
 
 Current commands and configuration options
 ==========================================
@@ -225,6 +239,7 @@ flag
   UDPDST_RND
   MACSRC_RND
   MACDST_RND
+  IPSEC
 
 dst_min
 dst_max
-- 
1.7.9.5
