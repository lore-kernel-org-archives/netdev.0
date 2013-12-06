From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [PATCH 1/2] macvtap: remove useless codes in macvtap_aio_read() and macvtap_recvmsg()
Date: Sat,  7 Dec 2013 04:54:59 +0800
Message-ID: <1386363300-19040-1-git-send-email-zwu.kernel@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

By checking related codes, it is impossible that ret > len or total_len,
so we should remove some useless coeds in both above functions.

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 drivers/net/macvtap.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 4c6f84c..7f4ccdd 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -871,7 +871,6 @@ static ssize_t macvtap_aio_read(struct kiocb *iocb, const struct iovec *iv,
 	}
 
 	ret = macvtap_do_read(q, iv, len, file->f_flags & O_NONBLOCK);
-	ret = min_t(ssize_t, ret, len); /* XXX copied from tun.c. Why? */
 out:
 	return ret;
 }
@@ -1104,10 +1103,6 @@ static int macvtap_recvmsg(struct kiocb *iocb, struct socket *sock,
 		return -EINVAL;
 	ret = macvtap_do_read(q, m->msg_iov, total_len,
 			  flags & MSG_DONTWAIT);
-	if (ret > total_len) {
-		m->msg_flags |= MSG_TRUNC;
-		ret = flags & MSG_TRUNC ? ret : total_len;
-	}
 	return ret;
 }
 
-- 
1.7.6.5
