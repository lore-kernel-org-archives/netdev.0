From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 6/6] net: sctp: simplify sctp_get_port
Date: Tue, 25 Jun 2013 17:13:41 +0200
Message-ID: <1372173221-15244-7-git-send-email-dborkman@redhat.com>
References: <1372173221-15244-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28950 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751912Ab3FYPNy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 11:13:54 -0400
In-Reply-To: <1372173221-15244-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to have an extra ret variable when we directly can return
the value of sctp_get_port_local().

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/socket.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index ba9359c..66fcdcf 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6036,7 +6036,6 @@ fail:
  */
 static int sctp_get_port(struct sock *sk, unsigned short snum)
 {
-	long ret;
 	union sctp_addr addr;
 	struct sctp_af *af = sctp_sk(sk)->pf->af;
 
@@ -6045,9 +6044,7 @@ static int sctp_get_port(struct sock *sk, unsigned short snum)
 	addr.v4.sin_port = htons(snum);
 
 	/* Note: sk->sk_num gets filled in if ephemeral port request. */
-	ret = sctp_get_port_local(sk, &addr);
-
-	return ret ? 1 : 0;
+	return !!sctp_get_port_local(sk, &addr);
 }
 
 /*
-- 
1.7.11.7
