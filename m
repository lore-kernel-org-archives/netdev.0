From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [PATCH 2/2] tun: remove useless codes in tun_chr_aio_read() and tun_recvmsg()
Date: Sat,  7 Dec 2013 04:55:00 +0800
Message-ID: <1386363300-19040-2-git-send-email-zwu.kernel@gmail.com>
References: <1386363300-19040-1-git-send-email-zwu.kernel@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386363300-19040-1-git-send-email-zwu.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

By checking related codes, it is impossible that ret > len or total_len,
so we should remove some useless codes in both above functions.

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 drivers/net/tun.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index f9c935a..d61719c 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1354,7 +1354,6 @@ static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
 
 	ret = tun_do_read(tun, tfile, iv, len,
 			  file->f_flags & O_NONBLOCK);
-	ret = min_t(ssize_t, ret, len);
 out:
 	tun_put(tun);
 	return ret;
@@ -1453,10 +1452,6 @@ static int tun_recvmsg(struct kiocb *iocb, struct socket *sock,
 	}
 	ret = tun_do_read(tun, tfile, m->msg_iov, total_len,
 			  flags & MSG_DONTWAIT);
-	if (ret > total_len) {
-		m->msg_flags |= MSG_TRUNC;
-		ret = flags & MSG_TRUNC ? ret : total_len;
-	}
 out:
 	tun_put(tun);
 	return ret;
-- 
1.7.6.5
