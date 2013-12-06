From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [net-next PATCH v3 6/6] tun: remove unused parameter in tun_do_read()
Date: Fri,  6 Dec 2013 14:19:42 +0800
Message-ID: <1386310782-9378-7-git-send-email-zwu.kernel@gmail.com>
References: <1386310782-9378-1-git-send-email-zwu.kernel@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:38920 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754297Ab3LFGUS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 01:20:18 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <zwu.kernel@gmail.com>;
	Fri, 6 Dec 2013 01:20:17 -0500
In-Reply-To: <1386310782-9378-1-git-send-email-zwu.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 drivers/net/tun.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 782e38b..f9c935a 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1289,8 +1289,7 @@ done:
 }
 
 static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
-			   struct kiocb *iocb, const struct iovec *iv,
-			   ssize_t len, int noblock)
+			   const struct iovec *iv, ssize_t len, int noblock)
 {
 	DECLARE_WAITQUEUE(wait, current);
 	struct sk_buff *skb;
@@ -1353,7 +1352,7 @@ static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
 		goto out;
 	}
 
-	ret = tun_do_read(tun, tfile, iocb, iv, len,
+	ret = tun_do_read(tun, tfile, iv, len,
 			  file->f_flags & O_NONBLOCK);
 	ret = min_t(ssize_t, ret, len);
 out:
@@ -1452,7 +1451,7 @@ static int tun_recvmsg(struct kiocb *iocb, struct socket *sock,
 					 SOL_PACKET, TUN_TX_TIMESTAMP);
 		goto out;
 	}
-	ret = tun_do_read(tun, tfile, iocb, m->msg_iov, total_len,
+	ret = tun_do_read(tun, tfile, m->msg_iov, total_len,
 			  flags & MSG_DONTWAIT);
 	if (ret > total_len) {
 		m->msg_flags |= MSG_TRUNC;
-- 
1.7.6.5
