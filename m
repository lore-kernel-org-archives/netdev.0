From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 2/2] inet_diag: Rename inet_diag_req_compat into inet_diag_req
Date: Wed, 11 Jan 2012 12:37:26 +0400
Message-ID: <4F0D4A46.2070404@parallels.com>
References: <4F0D49D4.7040100@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:1530 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756978Ab2AKIhe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jan 2012 03:37:34 -0500
In-Reply-To: <4F0D49D4.7040100@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/inet_diag.h |    2 +-
 net/ipv4/inet_diag.c      |    8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index a5b7e91..f1362b5 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -22,7 +22,7 @@ struct inet_diag_sockid {
 
 /* Request structure */
 
-struct inet_diag_req_compat {
+struct inet_diag_req {
 	__u8	idiag_family;		/* Family of addresses. */
 	__u8	idiag_src_len;
 	__u8	idiag_dst_len;
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index cf23a7c..fcf2818 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -909,10 +909,10 @@ static inline int inet_diag_type2proto(int type)
 
 static int inet_diag_dump_compat(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct inet_diag_req_compat *rc = NLMSG_DATA(cb->nlh);
+	struct inet_diag_req *rc = NLMSG_DATA(cb->nlh);
 	struct inet_diag_req_v2 req;
 	struct nlattr *bc = NULL;
-	int hdrlen = sizeof(struct inet_diag_req_compat);
+	int hdrlen = sizeof(struct inet_diag_req);
 
 	req.sdiag_family = AF_UNSPEC; /* compatibility */
 	req.sdiag_protocol = inet_diag_type2proto(cb->nlh->nlmsg_type);
@@ -929,7 +929,7 @@ static int inet_diag_dump_compat(struct sk_buff *skb, struct netlink_callback *c
 static int inet_diag_get_exact_compat(struct sk_buff *in_skb,
 			       const struct nlmsghdr *nlh)
 {
-	struct inet_diag_req_compat *rc = NLMSG_DATA(nlh);
+	struct inet_diag_req *rc = NLMSG_DATA(nlh);
 	struct inet_diag_req_v2 req;
 
 	req.sdiag_family = rc->idiag_family;
@@ -943,7 +943,7 @@ static int inet_diag_get_exact_compat(struct sk_buff *in_skb,
 
 static int inet_diag_rcv_msg_compat(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
-	int hdrlen = sizeof(struct inet_diag_req_compat);
+	int hdrlen = sizeof(struct inet_diag_req);
 
 	if (nlh->nlmsg_type >= INET_DIAG_GETSOCK_MAX ||
 	    nlmsg_len(nlh) < hdrlen)
-- 
1.5.5.6
