From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [RESEND] [PATCH] tcp: fix a size_t < 0 comparison in tcp_read_sock
Date: Wed, 2 Jul 2008 21:57:53 +0300
Message-ID: <200807022157.53647.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_x+8aI0QFs/gfF1Q"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:3140 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751185AbYGBS7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 14:59:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_x+8aI0QFs/gfF1Q
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


Discovered it while testing this patch:

http://www.spinics.net/lists/netdev/msg64668.html

(in this case, tcp_read_sock breaks; but regardless of that patch I think we 
should have this one)

Thanks,
tavi


--Boundary-00=_x+8aI0QFs/gfF1Q
Content-Type: text/plain;
  charset="us-ascii";
  name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="x"

commit 6cf0a9254f0b7fc41781a2cacd5a8b312a4b1e70
Author: Octavian Purdila <opurdila@ixiacom.com>
Date:   Wed Jul 2 21:25:51 2008 +0300

    tcp: fix a size_t < 0 comparison in tcp_read_sock
    
    <used> should be of type int (not size_t) since recv_actor can return
    negative values and it is also used in a < 0 comparison.
    
    Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 850825d..4f91d17 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1208,7 +1208,8 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 		return -ENOTCONN;
 	while ((skb = tcp_recv_skb(sk, seq, &offset)) != NULL) {
 		if (offset < skb->len) {
-			size_t used, len;
+			int used;
+			size_t len;
 
 			len = skb->len - offset;
 			/* Stop reading if we hit a patch of urgent data */

--Boundary-00=_x+8aI0QFs/gfF1Q--
