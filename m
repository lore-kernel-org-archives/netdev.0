From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 3/5] unix_diag: Add the MEMINFO extension
Date: Thu, 29 Dec 2011 18:13:39 +0400
Message-ID: <4EFC7593.5020903@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:30407 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750890Ab1L2ONo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Dec 2011 09:13:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/unix_diag.h |    2 ++
 net/unix/diag.c           |    4 ++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/linux/unix_diag.h b/include/linux/unix_diag.h
index 3f7afb0..5255f51 100644
--- a/include/linux/unix_diag.h
+++ b/include/linux/unix_diag.h
@@ -16,6 +16,7 @@ struct unix_diag_req {
 #define UDIAG_SHOW_PEER		0x00000004	/* show peer socket info */
 #define UDIAG_SHOW_ICONS	0x00000008	/* show pending connections */
 #define UDIAG_SHOW_RQLEN	0x00000010	/* show skb receive queue len */
+#define UDIAG_SHOW_MEMINFO	0x00000020	/* show memory info of a socket */
 
 struct unix_diag_msg {
 	__u8	udiag_family;
@@ -33,6 +34,7 @@ enum {
 	UNIX_DIAG_PEER,
 	UNIX_DIAG_ICONS,
 	UNIX_DIAG_RQLEN,
+	UNIX_DIAG_MEMINFO,
 
 	UNIX_DIAG_MAX,
 };
diff --git a/net/unix/diag.c b/net/unix/diag.c
index c5bdbcb..9517bdd 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -146,6 +146,10 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct unix_diag_r
 			sk_diag_show_rqlen(sk, skb))
 		goto nlmsg_failure;
 
+	if ((req->udiag_show & UDIAG_SHOW_MEMINFO) &&
+			sock_diag_put_meminfo(sk, skb, UNIX_DIAG_MEMINFO))
+		goto nlmsg_failure;
+
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 
-- 
1.5.5.6
