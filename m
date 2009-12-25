From: Vitaliy Gusev <vgusev@openvz.org>
Subject: [PATCH] tun: use tun_sk instead container_of
Date: Fri, 25 Dec 2009 20:17:43 +0300
Message-ID: <200912252017.43998.vgusev@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:2805 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756540AbZLYRO0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Dec 2009 12:14:26 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using macro tun_sk is more clear and shorter. However tun.c has tun_sk,
but doesn't use it. 

Signed-off-by: Vitaliy Gusev <vgusev@openvz.org>

---
 drivers/net/tun.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 01e99f2..2834a01 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -849,13 +849,13 @@ static void tun_sock_write_space(struct sock *sk)
 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
 		wake_up_interruptible_sync(sk->sk_sleep);
 
-	tun = container_of(sk, struct tun_sock, sk)->tun;
+	tun = tun_sk(sk)->tun;
 	kill_fasync(&tun->fasync, SIGIO, POLL_OUT);
 }
 
 static void tun_sock_destruct(struct sock *sk)
 {
-	free_netdev(container_of(sk, struct tun_sock, sk)->tun->dev);
+	free_netdev(tun_sk(sk)->tun->dev);
 }
 
 static struct proto tun_proto = {
@@ -990,7 +990,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		sk->sk_write_space = tun_sock_write_space;
 		sk->sk_sndbuf = INT_MAX;
 
-		container_of(sk, struct tun_sock, sk)->tun = tun;
+		tun_sk(sk)->tun = tun;
 
 		security_tun_dev_post_create(sk);
 
