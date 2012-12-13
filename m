From: Dave Jones <davej@redhat.com>
Subject: remove noisy message from llcp_sock_sendmsg
Date: Wed, 12 Dec 2012 23:11:34 -0500
Message-ID: <20121213041134.GA1611@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51068 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752872Ab2LMEV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 23:21:56 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id qBD4Ltpo002329
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2012 23:21:56 -0500
Received: from gelk.kernelslacker.org (ovpn-113-20.phx2.redhat.com [10.3.113.20])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id qBD4LseW019511
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2012 23:21:55 -0500
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.5/8.14.5) with ESMTP id qBD4BjdQ004754
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2012 23:11:55 -0500
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.5/8.14.5/Submit) id qBD4BYFp004753
	for netdev@vger.kernel.org; Wed, 12 Dec 2012 23:11:34 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is easily triggerable when fuzz-testing as an unprivileged user.
We could rate-limit it, but given we don't print similar messages
for other protocols, I just removed it.

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/net/nfc/llcp/sock.c b/net/nfc/llcp/sock.c
index 0fa1e92..fea22eb 100644
--- a/net/nfc/llcp/sock.c
+++ b/net/nfc/llcp/sock.c
@@ -614,10 +614,6 @@ static int llcp_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 		if (msg->msg_namelen < sizeof(*addr)) {
 			release_sock(sk);
-
-			pr_err("Invalid socket address length %d\n",
-			       msg->msg_namelen);
-
 			return -EINVAL;
 		}
 
