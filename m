From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 10/12] ppp_read(): switch to skb_copy_datagram_iter()
Date: Fri,  5 Dec 2014 05:58:51 +0000
Message-ID: <1417759133-18370-10-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141205055623.GQ29748@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141205055623.GQ29748@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 drivers/net/ppp/ppp_generic.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 794a473..af034db 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -417,6 +417,7 @@ static ssize_t ppp_read(struct file *file, char __user *buf,
 	ssize_t ret;
 	struct sk_buff *skb = NULL;
 	struct iovec iov;
+	struct iov_iter to;
 
 	ret = count;
 
@@ -462,7 +463,8 @@ static ssize_t ppp_read(struct file *file, char __user *buf,
 	ret = -EFAULT;
 	iov.iov_base = buf;
 	iov.iov_len = count;
-	if (skb_copy_datagram_iovec(skb, 0, &iov, skb->len))
+	iov_iter_init(&to, READ, &iov, 1, count);
+	if (skb_copy_datagram_iter(skb, 0, &to, skb->len))
 		goto outf;
 	ret = skb->len;
 
-- 
2.1.3
