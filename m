From: akpm@osdl.org
Subject: [patch 3/18] gcc-3.5: ax25
Date: Sun, 25 Jan 2004 03:06:59 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401251106.i0PB6xo25047@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



net/ax25/af_ax25.c: In function `ax25_create':
net/ax25/af_ax25.c:819: error: invalid lvalue in assignment
net/ax25/af_ax25.c: In function `ax25_make_new':
net/ax25/af_ax25.c:904: error: invalid lvalue in assignment

net/x25/af_x25.c: In function `x25_alloc_socket':
net/x25/af_x25.c:441: error: invalid lvalue in assignment                       

(Why is x25_alloc_socket() using GFP_ATOMIC?)


---

 net/ax25/af_ax25.c |    4 ++--
 net/x25/af_x25.c   |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff -puN net/ax25/af_ax25.c~gcc-35-ax25 net/ax25/af_ax25.c
--- 25/net/ax25/af_ax25.c~gcc-35-ax25	2004-01-23 21:38:22.000000000 -0800
+++ 25-akpm/net/ax25/af_ax25.c	2004-01-23 21:38:22.000000000 -0800
@@ -816,7 +816,7 @@ int ax25_create(struct socket *sock, int
 	if ((sk = sk_alloc(PF_AX25, GFP_ATOMIC, 1, NULL)) == NULL)
 		return -ENOMEM;
 
-	ax25 = ax25_sk(sk) = ax25_create_cb();
+	ax25 = sk->sk_protinfo = ax25_create_cb();
 	if (!ax25) {
 		sk_free(sk);
 		return -ENOMEM;
@@ -901,7 +901,7 @@ struct sock *ax25_make_new(struct sock *
 		memcpy(ax25->digipeat, oax25->digipeat, sizeof(ax25_digi));
 	}
 
-	ax25_sk(sk) = ax25;
+	sk->sk_protinfo = ax25;
 	ax25->sk    = sk;
 
 	return sk;
diff -puN net/x25/af_x25.c~gcc-35-ax25 net/x25/af_x25.c
--- 25/net/x25/af_x25.c~gcc-35-ax25	2004-01-23 22:48:41.000000000 -0800
+++ 25-akpm/net/x25/af_x25.c	2004-01-23 22:49:05.000000000 -0800
@@ -438,7 +438,7 @@ static struct sock *x25_alloc_socket(voi
 	if (!sk)
 		goto out;
 
-	x25 = x25_sk(sk) = kmalloc(sizeof(*x25), GFP_ATOMIC);
+	x25 = sk->sk_protinfo = kmalloc(sizeof(*x25), GFP_ATOMIC);
 	if (!x25)
 		goto frees;
 

_
