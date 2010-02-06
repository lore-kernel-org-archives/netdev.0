From: andrew hendry <andrew.hendry@gmail.com>
Subject: [PATCH 1/2] X25: Fix x25_create errors for bad protocol and ENOBUFS
Date: Sun, 7 Feb 2010 10:16:59 +1100
Message-ID: <d45a3acc1002061516s3b3eab26tc2a9339613684e6f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

alloc_socket failures should return -ENOBUFS
a bad protocol should return -EINVAL

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index e3219e4..6c7104e 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -512,15 +512,20 @@ static int x25_create(struct net *net, struct
socket *sock, int protocol,
 {
 	struct sock *sk;
 	struct x25_sock *x25;
-	int rc = -ESOCKTNOSUPPORT;
+	int rc = -EAFNOSUPPORT;

 	if (!net_eq(net, &init_net))
-		return -EAFNOSUPPORT;
+		goto out;
+
+	rc = -ESOCKTNOSUPPORT;
+	if (sock->type != SOCK_SEQPACKET)
+		goto out;

-	if (sock->type != SOCK_SEQPACKET || protocol)
+	rc = -EINVAL;
+	if (protocol)
 		goto out;

-	rc = -ENOMEM;
+	rc = -ENOBUFS;
 	if ((sk = x25_alloc_socket(net)) == NULL)
 		goto out;

-- 
1.6.3.3
