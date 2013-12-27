From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next RESEND v3] tipc: make the code look more readable
Date: Fri, 27 Dec 2013 10:09:39 +0800
Message-ID: <52BCE163.2060706@huawei.com>
References: <1387263827-20876-1-git-send-email-wangweidong1@huawei.com> <1387263827-20876-3-git-send-email-wangweidong1@huawei.com> <52BCDBA4.9050607@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <David.Laight@ACULAB.COM>, <netdev@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Ying Xue <ying.xue@windriver.com>
To: <jon.maloy@ericsson.com>, <allan.stephens@windriver.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:53611 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754011Ab3L0CLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 21:11:23 -0500
In-Reply-To: <52BCDBA4.9050607@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 3b8401fe9d ("tipc: kill unnecessary goto's") didn't make
the code look most readable, so fix it. This patch is cosmetic
and does not change the operation of TIPC in any way.

Suggested-by: David Laight <David.Laight@ACULAB.COM>
Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
Change note: 

v3: fix the spelling error which pointed out by Sergei.

v2: fix the problem "Referring commit purely by
    SHA1 ID is ambiguous" which pointed out by David.

---
 net/tipc/socket.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 83f466e..5efdeef 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -751,13 +751,10 @@ static int send_stream(struct kiocb *iocb, struct socket *sock,
 
 	/* Handle special cases where there is no connection */
 	if (unlikely(sock->state != SS_CONNECTED)) {
-		res = -ENOTCONN;
-
 		if (sock->state == SS_UNCONNECTED)
 			res = send_packet(NULL, sock, m, total_len);
-		else if (sock->state == SS_DISCONNECTING)
-			res = -EPIPE;
-
+		else
+			res = sock->state == SS_DISCONNECTING ? -EPIPE : -ENOTCONN;
 		goto exit;
 	}
 
-- 
1.7.12
