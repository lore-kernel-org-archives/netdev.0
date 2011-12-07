From: Djalal Harouni <tixxdz@opendz.org>
Subject: [PATCH] ppp: fix pptp double release_sock in pptp_bind()
Date: Wed, 7 Dec 2011 02:47:12 +0100
Message-ID: <20111207014712.GB25869@dztty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dmitry Kozlov <xeb@mail.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Djalal Harouni <tixxdz@opendz.org>
---
 drivers/net/ppp/pptp.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index 89f829f..f8a6853 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -423,10 +423,8 @@ static int pptp_bind(struct socket *sock, struct sockaddr *uservaddr,
 	lock_sock(sk);
 
 	opt->src_addr = sp->sa_addr.pptp;
-	if (add_chan(po)) {
-		release_sock(sk);
+	if (add_chan(po))
 		error = -EBUSY;
-	}
 
 	release_sock(sk);
 	return error;
-- 
1.7.1
