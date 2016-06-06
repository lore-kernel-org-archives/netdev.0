From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH] netlabel: add address family checks to netlbl_{sock,
 req}_delattr()
Date: Mon, 06 Jun 2016 15:35:58 -0400
Message-ID: <146524175890.8042.12012703565205416569.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: maninder1.s@samsung.com, selinux@tycho.nsa.gov
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul@paul-moore.com>

It seems risky to always rely on the caller to ensure the socket's
address family is correct before passing it to the NetLabel kAPI,
especially since we see at least one LSM which didn't. Add address
family checks to the *_delattr() functions to help prevent future
problems.

Cc: <stable@vger.kernel.org>
Reported-by: Maninder Singh <maninder1.s@samsung.com>
Signed-off-by: Paul Moore <paul@paul-moore.com>
---
 net/netlabel/netlabel_kapi.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index 1325776..bd007a9 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -824,7 +824,11 @@ socket_setattr_return:
  */
 void netlbl_sock_delattr(struct sock *sk)
 {
-	cipso_v4_sock_delattr(sk);
+	switch (sk->sk_family) {
+	case AF_INET:
+		cipso_v4_sock_delattr(sk);
+		break;
+	}
 }
 
 /**
@@ -987,7 +991,11 @@ req_setattr_return:
 */
 void netlbl_req_delattr(struct request_sock *req)
 {
-	cipso_v4_req_delattr(req);
+	switch (req->rsk_ops->family) {
+	case AF_INET:
+		cipso_v4_req_delattr(req);
+		break;
+	}
 }
 
 /**

