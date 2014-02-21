From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH net-next 3/3] pktgen: document all supported flags
Date: Fri, 21 Feb 2014 21:38:36 +0100
Message-ID: <1393015116-7488-4-git-send-email-minipli@googlemail.com>
References: <1393015116-7488-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>,
	Fan Du <fan.du@windriver.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f49.google.com ([209.85.214.49]:49932 "EHLO
	mail-bk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754047AbaBUUiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 15:38:52 -0500
Received: by mail-bk0-f49.google.com with SMTP id na10so364252bkb.22
        for <netdev@vger.kernel.org>; Fri, 21 Feb 2014 12:38:51 -0800 (PST)
In-Reply-To: <1393015116-7488-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The documentation misses a few of the supported flags. Fix this. Also
respect the dependency to CONFIG_XFRM for the IPSEC flag.

Cc: Fan Du <fan.du@windriver.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 Documentation/networking/pktgen.txt |   24 +++++++++++++++++++-----
 net/core/pktgen.c                   |    8 +++++++-
 2 files changed, 26 insertions(+), 6 deletions(-)

diff --git a/Documentation/networking/pktgen.txt b/Documentation/networking/pktgen.txt
index 5a61a240a6..0e30c7845b 100644
--- a/Documentation/networking/pktgen.txt
+++ b/Documentation/networking/pktgen.txt
@@ -102,13 +102,18 @@ Examples:
                          The 'minimum' MAC is what you set with dstmac.
 
  pgset "flag [name]"     Set a flag to determine behaviour.  Current flags
-                         are: IPSRC_RND #IP Source is random (between min/max),
-                              IPDST_RND, UDPSRC_RND,
-                              UDPDST_RND, MACSRC_RND, MACDST_RND 
+                         are: IPSRC_RND # IP source is random (between min/max)
+                              IPDST_RND # IP destination is random
+                              UDPSRC_RND, UDPDST_RND,
+                              MACSRC_RND, MACDST_RND
+                              TXSIZE_RND, IPV6,
                               MPLS_RND, VID_RND, SVID_RND
+                              FLOW_SEQ,
                               QUEUE_MAP_RND # queue map random
                               QUEUE_MAP_CPU # queue map mirrors smp_processor_id()
-                              IPSEC # Make IPsec encapsulation for packet
+                              UDPCSUM,
+                              IPSEC # IPsec encapsulation (needs CONFIG_XFRM)
+                              NODE_ALLOC # node specific memory allocation
 
  pgset spi SPI_VALUE     Set specific SA used to transform packet.
 
@@ -233,13 +238,22 @@ udp_dst_max
 
 flag
   IPSRC_RND
-  TXSIZE_RND
   IPDST_RND
   UDPSRC_RND
   UDPDST_RND
   MACSRC_RND
   MACDST_RND
+  TXSIZE_RND
+  IPV6
+  MPLS_RND
+  VID_RND
+  SVID_RND
+  FLOW_SEQ
+  QUEUE_MAP_RND
+  QUEUE_MAP_CPU
+  UDPCSUM
   IPSEC
+  NODE_ALLOC
 
 dst_min
 dst_max
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 53c3097117..d0dac57291 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1247,7 +1247,13 @@ static ssize_t pktgen_if_write(struct file *file,
 				"Flag -:%s:- unknown\nAvailable flags, (prepend ! to un-set flag):\n%s",
 				f,
 				"IPSRC_RND, IPDST_RND, UDPSRC_RND, UDPDST_RND, "
-				"MACSRC_RND, MACDST_RND, TXSIZE_RND, IPV6, MPLS_RND, VID_RND, SVID_RND, FLOW_SEQ, IPSEC, NODE_ALLOC\n");
+				"MACSRC_RND, MACDST_RND, TXSIZE_RND, IPV6, "
+				"MPLS_RND, VID_RND, SVID_RND, FLOW_SEQ, "
+				"QUEUE_MAP_RND, QUEUE_MAP_CPU, UDPCSUM, "
+#ifdef CONFIG_XFRM
+				"IPSEC, "
+#endif
+				"NODE_ALLOC\n");
 			return count;
 		}
 		sprintf(pg_result, "OK: flags=0x%x", pkt_dev->flags);
-- 
1.7.10.4
