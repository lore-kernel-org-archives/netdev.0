From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH] tcp: Add TCP_USER_TIMEOUT negative value check
Date: Fri, 27 Jul 2012 16:52:21 +0800
Message-ID: <1343379141-5516-1-git-send-email-liuhangbin@gmail.com>
Cc: hkchu@google.com, Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:50785 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113Ab2G0Iy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 04:54:26 -0400
Received: by wgbdr13 with SMTP id dr13so2607491wgb.1
        for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 01:54:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP_USER_TIMEOUT is a TCP level socket option that takes an unsigned int. But
patch "tcp: Add TCP_USER_TIMEOUT socket option"(dca43c75) didn't check the negative
values. If a user assign -1 to it, the socket will set successfully and wait
for 4294967295 miliseconds. This patch add a negative value check to avoid
this issue.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 net/ipv4/tcp.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 581ecf0..e7e6eea 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2681,7 +2681,10 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		/* Cap the max timeout in ms TCP will retry/retrans
 		 * before giving up and aborting (ETIMEDOUT) a connection.
 		 */
-		icsk->icsk_user_timeout = msecs_to_jiffies(val);
+		if (val < 0)
+			err = -EINVAL;
+		else
+			icsk->icsk_user_timeout = msecs_to_jiffies(val);
 		break;
 	default:
 		err = -ENOPROTOOPT;
-- 
1.7.7.6
