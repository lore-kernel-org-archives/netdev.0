From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATCH] tcp_read_sock: fix a size_t < 0 comparison
Date: Sun, 1 Jun 2008 22:39:07 +0300
Message-ID: <200806012239.07308.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_brvQInhAovkXh2o"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:2547 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751233AbYFATkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2008 15:40:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_brvQInhAovkXh2o
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline



--Boundary-00=_brvQInhAovkXh2o
Content-Type: text/x-diff;
  charset="us-ascii";
  name="0001-tcp_read_sock-fix-a-size_t-0-comparison.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="0001-tcp_read_sock-fix-a-size_t-0-comparison.diff"

>From 8a8e438947d1dd0848cedcaacaf956387184300f Mon Sep 17 00:00:00 2001
From: Octavian Purdila <opurdila@ixiacom.com>
Date: Sun, 1 Jun 2008 21:39:48 +0300
Subject: [PATCH] tcp_read_sock: fix a size_t < 0 comparison

<used> should be of type int (not size_t) since recv_actor can
return negative values and it is also used in a < 0 comparison.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 net/ipv4/tcp.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 680546a..78c66b6 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1206,7 +1206,8 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 		return -ENOTCONN;
 	while ((skb = tcp_recv_skb(sk, seq, &offset)) != NULL) {
 		if (offset < skb->len) {
-			size_t used, len;
+			int used;
+			size_t len;
 
 			len = skb->len - offset;
 			/* Stop reading if we hit a patch of urgent data */
-- 
1.5.4.3


--Boundary-00=_brvQInhAovkXh2o--
