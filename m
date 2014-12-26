From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next] tun: Fixed unsigned/signed comparison
Date: Thu, 25 Dec 2014 23:05:03 -0800
Message-ID: <1419577503-12862-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>, Alex Gartrell <agartrell@fb.com>
To: <davem@davemloft.net>, <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Validated that this was actually using the unsigned comparison with gdb.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 drivers/net/tun.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index a5cbf67..6c63e21 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1499,7 +1499,7 @@ static int tun_recvmsg(struct kiocb *iocb, struct socket *sock,
 		goto out;
 	}
 	ret = tun_do_read(tun, tfile, &m->msg_iter, flags & MSG_DONTWAIT);
-	if (ret > total_len) {
+	if (ret > (ssize_t)total_len) {
 		m->msg_flags |= MSG_TRUNC;
 		ret = flags & MSG_TRUNC ? ret : total_len;
 	}
-- 
Alex Gartrell <agartrell@fb.com>
