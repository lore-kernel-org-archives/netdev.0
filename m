From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH 07/11] net: caif: change chunk from int to size_t
Date: Fri, 23 Oct 2015 14:10:32 +0200
Message-ID: <1445602236-24130-8-git-send-email-clabbe.montjoie@gmail.com>
References: <1445602236-24130-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: LABBE Corentin <clabbe.montjoie@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net, dmitry.tarnyagin@lockless.no
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445602236-24130-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

chunk cannot be negative and is use in operation/function that
wait for unsigned value. This patch set it as size_t.
The patch do the same for the size variable.

Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
---
 net/caif/caif_socket.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index cc85891..362f6d8 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -370,7 +370,7 @@ static int caif_stream_recvmsg(struct socket *sock, struct msghdr *msg,
 	timeo = sock_rcvtimeo(sk, flags&MSG_DONTWAIT);
 
 	do {
-		int chunk;
+		size_t chunk;
 		struct sk_buff *skb;
 
 		lock_sock(sk);
@@ -595,7 +595,8 @@ static int caif_stream_sendmsg(struct socket *sock, struct msghdr *msg,
 {
 	struct sock *sk = sock->sk;
 	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
-	int err, size;
+	int err;
+	size_t size;
 	struct sk_buff *skb;
 	int sent = 0;
 	long timeo;
-- 
2.4.10
