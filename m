From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 4/9] net/sctp: Eliminate useless code
Date: Sat, 16 Jan 2010 16:58:40 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1001161657570.28745@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kern
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:44172 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932182Ab0APP6m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Jan 2010 10:58:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

The variable newinet is initialized twice to the same (side effect-free)
expression.  Drop one initialization.

A simplified version of the semantic match that finds this problem is:
(http://coccinelle.lip6.fr/)

// <smpl>
@forall@
idexpression *x;
identifier f!=ERR_PTR;
@@

x = f(...)
... when != x
(
x = f(...,<+...x...+>,...)
|
* x = f(...)
)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 net/sctp/socket.c                   |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 67fdac9..f6d1e59 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6359,7 +6359,7 @@ void sctp_copy_sock(struct sock *newsk, struct sock *sk,
 		    struct sctp_association *asoc)
 {
 	struct inet_sock *inet = inet_sk(sk);
-	struct inet_sock *newinet = inet_sk(newsk);
+	struct inet_sock *newinet;
 
 	newsk->sk_type = sk->sk_type;
 	newsk->sk_bound_dev_if = sk->sk_bound_dev_if;
