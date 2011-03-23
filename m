From: Pat Kane <pekane52@gmail.com>
Subject: [PATCH v2] net/unix: Add secdata to unix_stream msgs
Date: Tue, 22 Mar 2011 19:38:37 -0500
Message-ID: <1300840717-4413-1-git-send-email-pekane52@gmail.com>
Cc: netdev@vger.kernel.org, Pat Kane <pekane52@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:44563 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138Ab1CWAjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 20:39:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The unix_dgram routines add secdata to socket messages,
but the unix_stream routines do not. I have added the
two missing lines of code.

Signed-off-by: Pat Kane <pekane52@gmail.com>
---
 net/unix/af_unix.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 1663e1a..8753cdd 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1642,6 +1642,8 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		max_level = err + 1;
 		fds_sent = true;
 
+		unix_get_secdata(siocb->scm, skb);
+
 		err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
 		if (err) {
 			kfree_skb(skb);
@@ -1930,6 +1932,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 		} else {
 			/* Copy credentials */
 			scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).cred);
+			unix_set_secdata(siocb->scm, skb);
 			check_creds = 1;
 		}
 
-- 
1.7.1

