From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH v5 1/2] pktgen: adjust flag NO_TIMESTAMP to be more pktgen
	compliant
Date: Thu, 07 May 2015 16:34:51 +0200
Message-ID: <20150507143438.8534.89881.stgit@ivy>
References: <20150507143329.8534.49710.stgit@ivy>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55737 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751818AbbEGOlb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2015 10:41:31 -0400
In-Reply-To: <20150507143329.8534.49710.stgit@ivy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow flag NO_TIMESTAMP to turn timestamping on again, like other flags,
with a negation of the flag like !NO_TIMESTAMP.

Also document the option flag NO_TIMESTAMP.

Fixes: afb84b626184 ("pktgen: add flag NO_TIMESTAMP to disable timestamping")
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 Documentation/networking/pktgen.txt |    2 ++
 net/core/pktgen.c                   |    3 +++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/pktgen.txt b/Documentation/networking/pktgen.txt
index 0344f1d..6199ee6 100644
--- a/Documentation/networking/pktgen.txt
+++ b/Documentation/networking/pktgen.txt
@@ -145,6 +145,7 @@ Examples:
                               UDPCSUM,
                               IPSEC # IPsec encapsulation (needs CONFIG_XFRM)
                               NODE_ALLOC # node specific memory allocation
+                              NO_TIMESTAMP # disable timestamping
 
  pgset spi SPI_VALUE     Set specific SA used to transform packet.
 
@@ -287,6 +288,7 @@ flag
   UDPCSUM
   IPSEC
   NODE_ALLOC
+  NO_TIMESTAMP
 
 dst_min
 dst_max
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 508155b..43bb215 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1267,6 +1267,9 @@ static ssize_t pktgen_if_write(struct file *file,
 		else if (strcmp(f, "NO_TIMESTAMP") == 0)
 			pkt_dev->flags |= F_NO_TIMESTAMP;
 
+		else if (strcmp(f, "!NO_TIMESTAMP") == 0)
+			pkt_dev->flags &= ~F_NO_TIMESTAMP;
+
 		else {
 			sprintf(pg_result,
 				"Flag -:%s:- unknown\nAvailable flags, (prepend ! to un-set flag):\n%s",
