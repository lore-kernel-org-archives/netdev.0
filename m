From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 6/8] decnet: fix sparse warnings: symbol shadows an earlier one
Date: Wed, 25 Feb 2009 21:32:39 +0100
Message-ID: <20090225203233.6251.92817.stgit@vmbox.hanneseder.net>
References: <20090225203012.6251.32002.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f176.google.com ([209.85.220.176]:43098 "EHLO
	mail-fx0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755978AbZBYUkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 15:40:47 -0500
Received: by fxm24 with SMTP id 24so177988fxm.37
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2009 12:40:44 -0800 (PST)
In-Reply-To: <20090225203012.6251.32002.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: Remove redundant variable declarations, resp. rename
inner scope variable.

Fix this sparse warnings:
  net/decnet/af_decnet.c:1252:40: warning: symbol 'skb' shadows an earlier one
  net/decnet/af_decnet.c:1223:24: originally declared here
  net/decnet/af_decnet.c:1582:29: warning: symbol 'val' shadows an earlier one
  net/decnet/af_decnet.c:1527:22: originally declared here
  net/decnet/dn_dev.c:687:21: warning: symbol 'err' shadows an earlier one
  net/decnet/dn_dev.c:670:13: originally declared here
  net/decnet/sysctl_net_decnet.c:182:21: warning: symbol 'len' shadows an earlier one
  net/decnet/sysctl_net_decnet.c:173:16: originally declared here

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 net/decnet/af_decnet.c         |   17 +++++++++--------
 net/decnet/dn_dev.c            |    1 -
 net/decnet/sysctl_net_decnet.c |    2 +-
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 12bf7d4..b66fb84 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -1246,11 +1246,12 @@ static int dn_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 
 	case TIOCINQ:
 		lock_sock(sk);
-		if ((skb = skb_peek(&scp->other_receive_queue)) != NULL) {
+		skb = skb_peek(&scp->other_receive_queue);
+		if (skb) {
 			amount = skb->len;
 		} else {
-			struct sk_buff *skb = sk->sk_receive_queue.next;
-			for(;;) {
+			skb = sk->sk_receive_queue.next;
+			for (;;) {
 				if (skb ==
 				    (struct sk_buff *)&sk->sk_receive_queue)
 					break;
@@ -1579,16 +1580,16 @@ static int __dn_getsockopt(struct socket *sock, int level,int optname, char __us
 		default:
 #ifdef CONFIG_NETFILTER
 		{
-			int val, len;
+			int ret, len;
 
 			if(get_user(len, optlen))
 				return -EFAULT;
 
-			val = nf_getsockopt(sk, PF_DECnet, optname,
+			ret = nf_getsockopt(sk, PF_DECnet, optname,
 							optval, &len);
-			if (val >= 0)
-				val = put_user(len, optlen);
-			return val;
+			if (ret >= 0)
+				ret = put_user(len, optlen);
+			return ret;
 		}
 #endif
 		case DSO_STREAM:
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 5e21a2f..31c37ac 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -684,7 +684,6 @@ static int dn_nl_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		return -ENODEV;
 
 	if ((dn_db = dev->dn_ptr) == NULL) {
-		int err;
 		dn_db = dn_dev_create(dev, &err);
 		if (!dn_db)
 			return err;
diff --git a/net/decnet/sysctl_net_decnet.c b/net/decnet/sysctl_net_decnet.c
index 965397a..5bcd592 100644
--- a/net/decnet/sysctl_net_decnet.c
+++ b/net/decnet/sysctl_net_decnet.c
@@ -179,7 +179,7 @@ static int dn_node_address_handler(ctl_table *table, int write,
 	}
 
 	if (write) {
-		int len = (*lenp < DN_ASCBUF_LEN) ? *lenp : (DN_ASCBUF_LEN-1);
+		len = (*lenp < DN_ASCBUF_LEN) ? *lenp : (DN_ASCBUF_LEN-1);
 
 		if (copy_from_user(addr, buffer, len))
 			return -EFAULT;

