From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [TCP]: Update references in two old comments
Date: Fri, 27 Apr 2007 10:38:08 +0100
Message-ID: <200704271038.08260@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:53655 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755545AbXD0Jxy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2007 05:53:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TCP]: Update references in two old comments

This updates references to drafts in comments which must be about 10
years old.  Internet draft draft-ietf-tcpimpl-prob-03.txt expired in 1998
and was replaced by RFC 2525 in March 1999.

Section 3.10 of the draft maps almost identically into section 2.17 of RFC
2525: both are entitled "Failure to RST on close with data pending", the
differences in text body amount to a typo and minor sentence change.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/ipv4/tcp.c        |   14 ++++++--------
 net/ipv4/tcp_output.c |    2 +-
 2 files changed, 7 insertions(+), 9 deletions(-)

--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1573,14 +1573,12 @@ void tcp_close(struct sock *sk, long tim
 
 	sk_stream_mem_reclaim(sk);
 
-	/* As outlined in draft-ietf-tcpimpl-prob-03.txt, section
-	 * 3.10, we send a RST here because data was lost.  To
-	 * witness the awful effects of the old behavior of always
-	 * doing a FIN, run an older 2.1.x kernel or 2.0.x, start
-	 * a bulk GET in an FTP client, suspend the process, wait
-	 * for the client to advertise a zero window, then kill -9
-	 * the FTP client, wheee...  Note: timeout is always zero
-	 * in such a case.
+	/* As outlined in RFC 2525, section 2.17, we send a RST here because
+	 * data was lost. To witness the awful effects of the old behavior of
+	 * always doing a FIN, run an older 2.1.x kernel or 2.0.x, start a bulk
+	 * GET in an FTP client, suspend the process, wait for the client to
+	 * advertise a zero window, then kill -9 the FTP client, wheee...
+	 * Note: timeout is always zero in such a case.
 	 */
 	if (data_was_unread) {
 		/* Unread data was tossed, zap the connection. */
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2035,7 +2035,7 @@ void tcp_send_fin(struct sock *sk)
 /* We get here when a process closes a file descriptor (either due to
  * an explicit close() or as a byproduct of exit()'ing) and there
  * was unread data in the receive queue.  This behavior is recommended
- * by draft-ietf-tcpimpl-prob-03.txt section 3.10.  -DaveM
+ * by RFC 2525, section 2.17.  -DaveM
  */
 void tcp_send_active_reset(struct sock *sk, gfp_t priority)
 {
