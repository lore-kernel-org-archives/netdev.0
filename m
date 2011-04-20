From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH v2] can: add missing socket check in can/raw release
Date: Wed, 20 Apr 2011 13:57:15 +0200
Message-ID: <4DAECA1B.5050300@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dave Jones <davej@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:64609 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400Ab1DTL5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 07:57:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2: added space after 'if' according code style.

We can get here with a NULL socket argument passed from userspace,
so we need to handle it accordingly.

Thanks to Dave Jones pointing at this issue in net/can/bcm.c

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

---

diff --git a/net/can/raw.c b/net/can/raw.c
index 649acfa..8f215e6 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -305,7 +305,12 @@ static int raw_init(struct sock *sk)
 static int raw_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
-	struct raw_sock *ro = raw_sk(sk);
+	struct raw_sock *ro;
+
+	if (!sk)
+		return 0;
+
+	ro = raw_sk(sk);

 	unregister_netdevice_notifier(&ro->notifier);

