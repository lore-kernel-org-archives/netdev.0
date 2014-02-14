From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 4/4] appletalk: fix checkpatch error with indent
Date: Fri, 14 Feb 2014 15:43:46 +0800
Message-ID: <1392363826-8256-5-git-send-email-wangweidong1@huawei.com>
References: <1392363826-8256-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <acme@ghostprotocols.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:19549 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139AbaBNHoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 02:44:10 -0500
In-Reply-To: <1392363826-8256-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

checkpatch error: switch and case should be at the same indent.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/appletalk/ddp.c | 90 ++++++++++++++++++++++++++---------------------------
 1 file changed, 45 insertions(+), 45 deletions(-)

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 786255c..5fd5122 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1789,53 +1789,53 @@ static int atalk_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	void __user *argp = (void __user *)arg;
 
 	switch (cmd) {
-		/* Protocol layer */
-		case TIOCOUTQ: {
-			long amount = sk->sk_sndbuf - sk_wmem_alloc_get(sk);
+	/* Protocol layer */
+	case TIOCOUTQ: {
+		long amount = sk->sk_sndbuf - sk_wmem_alloc_get(sk);
 
-			if (amount < 0)
-				amount = 0;
-			rc = put_user(amount, (int __user *)argp);
-			break;
-		}
-		case TIOCINQ: {
-			/*
-			 * These two are safe on a single CPU system as only
-			 * user tasks fiddle here
-			 */
-			struct sk_buff *skb = skb_peek(&sk->sk_receive_queue);
-			long amount = 0;
+		if (amount < 0)
+			amount = 0;
+		rc = put_user(amount, (int __user *)argp);
+		break;
+	}
+	case TIOCINQ: {
+		/*
+		 * These two are safe on a single CPU system as only
+		 * user tasks fiddle here
+		 */
+		struct sk_buff *skb = skb_peek(&sk->sk_receive_queue);
+		long amount = 0;
 
-			if (skb)
-				amount = skb->len - sizeof(struct ddpehdr);
-			rc = put_user(amount, (int __user *)argp);
-			break;
-		}
-		case SIOCGSTAMP:
-			rc = sock_get_timestamp(sk, argp);
-			break;
-		case SIOCGSTAMPNS:
-			rc = sock_get_timestampns(sk, argp);
-			break;
-		/* Routing */
-		case SIOCADDRT:
-		case SIOCDELRT:
-			rc = -EPERM;
-			if (capable(CAP_NET_ADMIN))
-				rc = atrtr_ioctl(cmd, argp);
-			break;
-		/* Interface */
-		case SIOCGIFADDR:
-		case SIOCSIFADDR:
-		case SIOCGIFBRDADDR:
-		case SIOCATALKDIFADDR:
-		case SIOCDIFADDR:
-		case SIOCSARP:		/* proxy AARP */
-		case SIOCDARP:		/* proxy AARP */
-			rtnl_lock();
-			rc = atif_ioctl(cmd, argp);
-			rtnl_unlock();
-			break;
+		if (skb)
+		amount = skb->len - sizeof(struct ddpehdr);
+		rc = put_user(amount, (int __user *)argp);
+		break;
+	}
+	case SIOCGSTAMP:
+		rc = sock_get_timestamp(sk, argp);
+		break;
+	case SIOCGSTAMPNS:
+		rc = sock_get_timestampns(sk, argp);
+		break;
+	/* Routing */
+	case SIOCADDRT:
+	case SIOCDELRT:
+		rc = -EPERM;
+		if (capable(CAP_NET_ADMIN))
+			rc = atrtr_ioctl(cmd, argp);
+		break;
+	/* Interface */
+	case SIOCGIFADDR:
+	case SIOCSIFADDR:
+	case SIOCGIFBRDADDR:
+	case SIOCATALKDIFADDR:
+	case SIOCDIFADDR:
+	case SIOCSARP:		/* proxy AARP */
+	case SIOCDARP:		/* proxy AARP */
+		rtnl_lock();
+		rc = atif_ioctl(cmd, argp);
+		rtnl_unlock();
+		break;
 	}
 
 	return rc;
-- 
1.7.12
