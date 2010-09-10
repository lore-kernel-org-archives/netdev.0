From: Dan Carpenter <error27@gmail.com>
Subject: [patch] net/llc: make opt unsigned in llc_ui_setsockopt()
Date: Fri, 10 Sep 2010 13:56:16 +0200
Message-ID: <20100910115616.GD5959@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:52076 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753261Ab0IJL4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 07:56:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The members of struct llc_sock are unsigned so if we pass a negative
value for "opt" it can cause a sign bug.  Also it can cause an integer
overflow when we multiply "opt * HZ".

CC: stable@kernel.org
Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 023ba82..5826129 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -1024,7 +1024,8 @@ static int llc_ui_setsockopt(struct socket *sock, int level, int optname,
 {
 	struct sock *sk = sock->sk;
 	struct llc_sock *llc = llc_sk(sk);
-	int rc = -EINVAL, opt;
+	unsigned int opt;
+	int rc = -EINVAL;
 
 	lock_sock(sk);
 	if (unlikely(level != SOL_LLC || optlen != sizeof(int)))
