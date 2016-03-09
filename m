From: Weongyo Jeong <weongyo.linux@gmail.com>
Subject: [PATCH] inet: set `error' value not under lock_sock().
Date: Wed, 9 Mar 2016 10:22:21 -0800
Message-ID: <20160309182217.GA9708@jwg>
Reply-To: Weongyo Jeong <wjeong@barracuda.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:32877 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933595AbcCISWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 13:22:23 -0500
Received: by mail-pa0-f66.google.com with SMTP id q6so3938880pav.0
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 10:22:23 -0800 (PST)
Received: from jwg ([64.235.157.5])
        by smtp.gmail.com with ESMTPSA id xn8sm14018893pab.15.2016.03.09.10.22.21
        for <netdev@vger.kernel.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Mar 2016 10:22:21 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A trivial patch to set `error' variable while not holding
lock_sock().

Signed-off-by: Weongyo Jeong <weongyo.linux@gmail.com>
---
 net/ipv4/inet_connection_sock.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 6414891..58bc39f 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -306,14 +306,13 @@ struct sock *inet_csk_accept(struct sock *sk, int flags, int *err)
 	struct request_sock_queue *queue = &icsk->icsk_accept_queue;
 	struct request_sock *req;
 	struct sock *newsk;
-	int error;
+	int error = -EINVAL;
 
 	lock_sock(sk);
 
 	/* We need to make sure that this socket is listening,
 	 * and that it has something pending.
 	 */
-	error = -EINVAL;
 	if (sk->sk_state != TCP_LISTEN)
 		goto out_err;
 
-- 
2.1.3
