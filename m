From: Jeffrin Jose <ahiliation@yahoo.co.in>
Subject: patch for format issues and header bug in net/ipv4/icmp.c
Date: Sat, 19 Mar 2011 00:05:29 +0530
Message-ID: <20110318183529.GA3617@debian.Jeff>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="+HP7ph2BbKc20aGI"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm4-vm0.bullet.mail.in.yahoo.com ([121.101.151.213]:21802 "HELO
	nm4-vm0.bullet.mail.in.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753937Ab1CRSfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 14:35:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--+HP7ph2BbKc20aGI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

hello ,

I have created a patch for net/ipv4/icmp.c
using checkpatch.pl script to fix several warnings
and an error.

I have attached the patch along with this mail.

/Thanks

-- 
software engineer.
department of computer science
rajagiri school of engineering and technology.

--+HP7ph2BbKc20aGI
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-net-Fixed-format-issues-and-header-bug-in-net-ipv4-i.patch"

>From 01861eb7151d397d10e1e8be58ac79252b04e254 Mon Sep 17 00:00:00 2001
From: Jeffrin Jose <ahiliation@yahoo.co.in>
Date: Fri, 18 Mar 2011 23:20:24 +0530
Subject: [PATCH] net : Fixed format issues and header bug in net/ipv4/icmp.c
 This is a patch to net/ipv4/icmp.c  file that fixes several
 line limit and several format ones and also a header path
 issue found by the checkpatch.pl tool.
 Author:		Jeffrin Jose <ahiliation@yahoo.co.in>
 Signed-off-by:  Jeffrin Jose

---
 net/ipv4/icmp.c |   30 +++++++++++++++++-------------
 1 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index a91dc16..348cc17 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -53,7 +53,7 @@
  *					- ICMP header length was not accounted
  *					  at all.
  *              Tristan Greaves :       Added sysctl option to ignore bogus
- *              			broadcast responses from broken routers.
+ *					broadcast responses from broken routers.
  *
  * To Fix:
  *
@@ -89,7 +89,7 @@
 #include <linux/timer.h>
 #include <linux/init.h>
 #include <asm/system.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <net/checksum.h>
 #include <net/xfrm.h>
 #include <net/inet_common.h>
@@ -113,7 +113,8 @@ struct icmp_bxm {
 };
 
 /* An array of errno for error messages from dest unreach. */
-/* RFC 1122: 3.2.2.1 States that NET_UNREACH, HOST_UNREACH and SR_FAILED MUST be considered 'transient errs'. */
+/* RFC 1122: 3.2.2.1 States that NET_UNREACH, HOST_UNREACH and SR_FAILED MUST
+be considered 'transient errs'. */
 
 const struct icmp_err icmp_err_convert[] = {
 	{
@@ -303,7 +304,7 @@ static void icmp_push_reply(struct icmp_bxm *icmp_param,
 			   ipc, rt, MSG_DONTWAIT) < 0) {
 		ICMP_INC_STATS_BH(sock_net(sk), ICMP_MIB_OUTERRORS);
 		ip_flush_pending_frames(sk);
-	} else if ((skb = skb_peek(&sk->sk_write_queue)) != NULL) {
+	} else if ((skb == skb_peek(&sk->sk_write_queue)) != NULL) {
 		struct icmphdr *icmph = icmp_hdr(skb);
 		__wsum csum = 0;
 		struct sk_buff *skb1;
@@ -411,7 +412,8 @@ static struct rtable *icmp_route_lookup(struct net *net, struct sk_buff *skb_in,
 	} else
 		return rt;
 
-	err = xfrm_decode_session_reverse(skb_in, flowi4_to_flowi(&fl4), AF_INET);
+	err = xfrm_decode_session_reverse(skb_in, \
+	flowi4_to_flowi(&fl4), AF_INET);
 	if (err)
 		goto relookup_failed;
 
@@ -648,7 +650,7 @@ static void icmp_unreach(struct sk_buff *skb)
 
 	/*
 	 *	Incomplete header ?
-	 * 	Only checks for the IP header, there should be an
+	 *	Only checks for the IP header, there should be an
 	 *	additional check for longer headers in upper levels.
 	 */
 
@@ -670,18 +672,20 @@ static void icmp_unreach(struct sk_buff *skb)
 			break;
 		case ICMP_FRAG_NEEDED:
 			if (ipv4_config.no_pmtu_disc) {
-				LIMIT_NETDEBUG(KERN_INFO "ICMP: %pI4: fragmentation needed and DF set.\n",
+				LIMIT_NETDEBUG(KERN_INFO "ICMP: %pI4: \
+	fragmentation needed and DF set.\n",
 					       &iph->daddr);
 			} else {
 				info = ip_rt_frag_needed(net, iph,
-							 ntohs(icmph->un.frag.mtu),
+						 ntohs(icmph->un.frag.mtu),
 							 skb->dev);
 				if (!info)
 					goto out;
 			}
 			break;
 		case ICMP_SR_FAILED:
-			LIMIT_NETDEBUG(KERN_INFO "ICMP: %pI4: Source Route Failed.\n",
+			LIMIT_NETDEBUG(KERN_INFO "ICMP: %pI4: \
+	 Source Route Failed.\n",
 				       &iph->daddr);
 			break;
 		default:
@@ -875,7 +879,7 @@ out_err:
  *
  * RFC1812 (4.3.3.9).	A router MUST implement it.
  *			A router SHOULD have switch turning it on/off.
- *		      	This switch MUST be ON by default.
+ *			This switch MUST be ON by default.
  *
  * Gratuitous replies, zero-source replies are not implemented,
  * that complies with RFC. DO NOT implement them!!! All the idea
@@ -1163,7 +1167,7 @@ static int __net_init icmp_sk_init(struct net *net)
 	net->ipv4.sysctl_icmp_ignore_bogus_error_responses = 1;
 
 	/*
-	 * 	Configurable global rate limit.
+	 *	Configurable global rate limit.
 	 *
 	 *	ratelimit defines tokens/packet consumed for dst->rate_token
 	 *	bucket ratemask defines which icmp types are ratelimited by
@@ -1188,8 +1192,8 @@ fail:
 }
 
 static struct pernet_operations __net_initdata icmp_sk_ops = {
-       .init = icmp_sk_init,
-       .exit = icmp_sk_exit,
+	.init = icmp_sk_init,
+	.exit = icmp_sk_exit,
 };
 
 int __init icmp_init(void)
-- 
1.7.1


--+HP7ph2BbKc20aGI--
