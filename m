From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [net-next PATCH 6/6] macvtap: remove unused paramter in macvtap_do_read()
Date: Fri,  6 Dec 2013 06:28:47 +0800
Message-ID: <1386282527-14094-7-git-send-email-zwu.kernel@gmail.com>
References: <1386282527-14094-1-git-send-email-zwu.kernel@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:35952 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754389Ab3LEW3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 17:29:20 -0500
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <zwu.kernel@gmail.com>;
	Thu, 5 Dec 2013 15:29:19 -0700
In-Reply-To: <1386282527-14094-1-git-send-email-zwu.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 drivers/net/macvtap.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 4914d85..4a34bcb 100644
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
 	if (ret > 0)
 		iocb->ki_pos = ret;
@@ -1104,7 +1104,7 @@ static int macvtap_recvmsg(struct kiocb *iocb, struct socket *sock,
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
