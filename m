From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 5/5][SCTP]: Use the flags value that is passed as an arg to
 sctp_accept.
Date: Fri, 18 Aug 2006 15:02:57 -0700 (PDT)
Message-ID: <Pine.LNX.4.58.0608181501560.7947@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:15527 "EHLO e2.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751506AbWHRWC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2006 18:02:59 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k7IM2xca001633
	for <netdev@vger.kernel.org>; Fri, 18 Aug 2006 18:02:59 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7IM2x6q279066
	for <netdev@vger.kernel.org>; Fri, 18 Aug 2006 18:02:59 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7IM2wjf022423
	for <netdev@vger.kernel.org>; Fri, 18 Aug 2006 18:02:58 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Use the flags value that is passed as an arg to sctp_accept.

No need to do multiple dereferences - sk->sk_socket->file->f_flags

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---

 net/sctp/socket.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index b289f8a..b035fb3 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2958,7 +2958,7 @@ SCTP_STATIC struct sock *sctp_accept(str
 		goto out;
 	}

-	timeo = sock_rcvtimeo(sk, sk->sk_socket->file->f_flags & O_NONBLOCK);
+	timeo = sock_rcvtimeo(sk, flags & O_NONBLOCK);

 	error = sctp_wait_for_accept(sk, timeo);
 	if (error)

