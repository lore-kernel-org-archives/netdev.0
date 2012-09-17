From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] af_unux: old_cred is surplus
Date: Mon, 17 Sep 2012 11:52:41 +0100
Message-ID: <20120917105234.30031.82700.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:32913 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313Ab2IQKeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 06:34:13 -0400
Received: from localhost.localdomain (earthlight.etchedpixels.co.uk [81.2.110.250])
	by lxorguk.ukuu.org.uk (8.14.5/8.14.1) with ESMTP id q8HB6fQ2000793
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2012 12:06:49 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@linux.intel.com>

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 net/unix/af_unix.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 8a84ab6..5b5c876 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -441,7 +441,7 @@ static int unix_release_sock(struct sock *sk, int embrion)
 	/* ---- Socket is dead now and most probably destroyed ---- */
 
 	/*
-	 * Fixme: BSD difference: In BSD all sockets connected to use get
+	 * Fixme: BSD difference: In BSD all sockets connected to us get
 	 *	  ECONNRESET and we die on the spot. In Linux we behave
 	 *	  like files and pipes do and wait for the last
 	 *	  dereference.
@@ -481,7 +481,6 @@ static int unix_listen(struct socket *sock, int backlog)
 	struct sock *sk = sock->sk;
 	struct unix_sock *u = unix_sk(sk);
 	struct pid *old_pid = NULL;
-	const struct cred *old_cred = NULL;
 
 	err = -EOPNOTSUPP;
 	if (sock->type != SOCK_STREAM && sock->type != SOCK_SEQPACKET)
@@ -503,8 +502,6 @@ static int unix_listen(struct socket *sock, int backlog)
 out_unlock:
 	unix_state_unlock(sk);
 	put_pid(old_pid);
-	if (old_cred)
-		put_cred(old_cred);
 out:
 	return err;
 }
