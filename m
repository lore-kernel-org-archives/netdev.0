From: Matthew Daley <mattjd@gmail.com>
Subject: [PATCH 3/3] x25: Prevent skb overreads when checking call user data
Date: Sat, 15 Oct 2011 00:45:05 -0400
Message-ID: <1318653905-13716-4-git-send-email-mattjd@gmail.com>
References: <1318653905-13716-1-git-send-email-mattjd@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Hendry <andrew.hendry@gmail.com>,
	Matthew Daley <mattjd@gmail.com>, stable <stable@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:64092 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340Ab1JOEpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2011 00:45:25 -0400
Received: by mail-iy0-f174.google.com with SMTP id k3so3418201iae.19
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 21:45:25 -0700 (PDT)
In-Reply-To: <1318653905-13716-1-git-send-email-mattjd@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

x25_find_listener does not check that the amount of call user data given
in the skb is big enough in per-socket comparisons, hence buffer
overreads may occur.  Fix this by adding a check.

Signed-off-by: Matthew Daley <mattjd@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Andrew Hendry <andrew.hendry@gmail.com>
Cc: stable <stable@kernel.org>
---
 net/x25/af_x25.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index aa567b0..5f03e4e 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -295,7 +295,8 @@ static struct sock *x25_find_listener(struct x25_address *addr,
 			 * Found a listening socket, now check the incoming
 			 * call user data vs this sockets call user data
 			 */
-			if(skb->len > 0 && x25_sk(s)->cudmatchlength > 0) {
+			if (x25_sk(s)->cudmatchlength > 0 &&
+				skb->len >= x25_sk(s)->cudmatchlength) {
 				if((memcmp(x25_sk(s)->calluserdata.cuddata,
 					skb->data,
 					x25_sk(s)->cudmatchlength)) == 0) {
-- 
1.7.2.5
