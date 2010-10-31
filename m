From: Vasiliy Kulikov <segooon@gmail.com>
Subject: [PATCH 1/3] net: ax25: fix information leak to userland
Date: Sun, 31 Oct 2010 20:10:22 +0300
Message-ID: <1288545022-16393-1-git-send-email-segooon@gmail.com>
Cc: Joerg Reuter <jreuter@yaina.de>,
	Ralf Baechle <ralf@linux-mips.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:53346 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756093Ab0JaRKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Oct 2010 13:10:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sometimes ax25_getname() doesn't initialize all members of fsa_digipeater
field of fsa struct.  This structure is then copied to userland.  It leads to
leaking of contents of kernel stack memory.  We have to initialize them to zero.

Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>
---
 net/ax25/af_ax25.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 26eaebf..a324d83 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1392,6 +1392,7 @@ static int ax25_getname(struct socket *sock, struct sockaddr *uaddr,
 	ax25_cb *ax25;
 	int err = 0;
 
+	memset(&fsa->fsa_digipeater, 0, sizeof(fsa->fsa_digipeater));
 	lock_sock(sk);
 	ax25 = ax25_sk(sk);
 
-- 
1.7.0.4

