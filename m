From: akpm@linux-foundation.org
Subject: [patch 1/1] net/sctp/socket.c: squish warning
Date: Mon, 21 Dec 2009 16:25:06 -0800
Message-ID: <200912220025.nBM0P6iQ005122@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	andrei@iptel.org, vladislav.yasevich@hp.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60096 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751041AbZLVAZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2009 19:25:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

net/sctp/socket.c: In function 'sctp_setsockopt_autoclose':
net/sctp/socket.c:2090: warning: comparison is always false due to limited range of data type

Cc: Andrei Pelinescu-Onciul <andrei@iptel.org>
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/sctp/socket.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff -puN net/sctp/socket.c~net-sctp-socketc-squish-warning net/sctp/socket.c
--- a/net/sctp/socket.c~net-sctp-socketc-squish-warning
+++ a/net/sctp/socket.c
@@ -2087,8 +2087,7 @@ static int sctp_setsockopt_autoclose(str
 	if (copy_from_user(&sp->autoclose, optval, optlen))
 		return -EFAULT;
 	/* make sure it won't exceed MAX_SCHEDULE_TIMEOUT */
-	if (sp->autoclose > (MAX_SCHEDULE_TIMEOUT / HZ) )
-		sp->autoclose = (__u32)(MAX_SCHEDULE_TIMEOUT / HZ) ;
+	sp->autoclose = min_t(long, sp->autoclose, MAX_SCHEDULE_TIMEOUT / HZ);
 
 	return 0;
 }
_
