From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH RESEND] sctp: fix incorrect overflow check on autoclose
Date: Thu,  8 Dec 2011 20:24:43 -0500
Message-ID: <1323393883-3759-1-git-send-email-xi.wang@gmail.com>
Cc: linux-sctp@vger.kernel.org, Xi Wang <xi.wang@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andrei Pelinescu-Onciul <andrei@iptel.org>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:41647 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753568Ab1LIB0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2011 20:26:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 8ffd3208 voids the previous patches f6778aab and 810c0719
for limiting the maximum autoclose value.  If userspace passes in -1
on 32-bit platform, the overflow check didn't work and autoclose
would be set to 0xffffffff.

Signed-off-by: Xi Wang <xi.wang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrei Pelinescu-Onciul <andrei@iptel.org>
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>
Cc: David S. Miller <davem@davemloft.net>
---
 net/sctp/socket.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 13bf5fc..bb91281 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2201,7 +2201,8 @@ static int sctp_setsockopt_autoclose(struct sock *sk, char __user *optval,
 	if (copy_from_user(&sp->autoclose, optval, optlen))
 		return -EFAULT;
 	/* make sure it won't exceed MAX_SCHEDULE_TIMEOUT */
-	sp->autoclose = min_t(long, sp->autoclose, MAX_SCHEDULE_TIMEOUT / HZ);
+	sp->autoclose = min_t(unsigned long, sp->autoclose,
+			      MAX_SCHEDULE_TIMEOUT / HZ);
 
 	return 0;
 }
-- 
1.7.5.4
