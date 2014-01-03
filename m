From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv4 net-next 8/8] {pktgen, xfrm} Document IPsec usage in pktgen.txt
Date: Fri, 3 Jan 2014 11:18:34 +0800
Message-ID: <1388719114-26244-9-git-send-email-fan.du@windriver.com>
References: <1388719114-26244-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:47849 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753791AbaACDSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 22:18:51 -0500
In-Reply-To: <1388719114-26244-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update pktgen.txt for reference when using IPsec.

Signed-off-by: Fan Du <fan.du@windriver.com>
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
