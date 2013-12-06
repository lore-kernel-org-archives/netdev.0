From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [PATCH v4 net-next 3/4] macvtap: remove unused parameter in macvtap_do_read()
Date: Sat,  7 Dec 2013 04:13:05 +0800
Message-ID: <1386360786-17687-4-git-send-email-zwu.kernel@gmail.com>
References: <1386360786-17687-1-git-send-email-zwu.kernel@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386360786-17687-1-git-send-email-zwu.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 drivers/net/macvtap.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index f599c47..4c6f84c 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -819,7 +819,7 @@ done:
 	return ret ? ret : copied;
 }
 
-static ssize_t macvtap_do_read(struct macvtap_queue *q, struct kiocb *iocb,
+static ssize_t macvtap_do_read(struct macvtap_queue *q,
 			       const struct iovec *iv, unsigned long len,
 			       int noblock)
 {
@@ -870,7 +870,7 @@ static ssize_t macvtap_aio_read(struct kiocb *iocb, const struct iovec *iv,
 		goto out;
 	}
 
-	ret = macvtap_do_read(q, iocb, iv, len, file->f_flags & O_NONBLOCK);
+	ret = macvtap_do_read(q, iv, len, file->f_flags & O_NONBLOCK);
 	ret = min_t(ssize_t, ret, len); /* XXX copied from tun.c. Why? */
 out:
 	return ret;
@@ -1102,7 +1102,7 @@ static int macvtap_recvmsg(struct kiocb *iocb, struct socket *sock,
 	int ret;
 	if (flags & ~(MSG_DONTWAIT|MSG_TRUNC))
 		return -EINVAL;
-	ret = macvtap_do_read(q, iocb, m->msg_iov, total_len,
+	ret = macvtap_do_read(q, m->msg_iov, total_len,
 			  flags & MSG_DONTWAIT);
 	if (ret > total_len) {
 		m->msg_flags |= MSG_TRUNC;
-- 
1.7.6.5
