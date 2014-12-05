From: Luis Henriques <luis.henriques@canonical.com>
Subject: [3.16.y-ckt stable] Patch "net/ping: handle protocol mismatching scenario" has been added to staging queue
Date: Fri,  5 Dec 2014 17:09:24 +0000
Message-ID: <1417799364-22010-1-git-send-email-luis.henriques@canonical.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Yiwei Zhao <gbjc64@motorola.com>,
	Luis Henriques <luis.henriques@canonical.com>,
	kernel-team@lists.ubuntu.com
To: Jane Zhou <a17711@motorola.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:37007 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563AbaLERJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 12:09:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a note to let you know that I have just added a patch titled

    net/ping: handle protocol mismatching scenario

to the linux-3.16.y-queue branch of the 3.16.y-ckt extended stable tree 
which can be found at:

 http://kernel.ubuntu.com/git?p=ubuntu/linux.git;a=shortlog;h=refs/heads/linux-3.16.y-queue

This patch is scheduled to be released in version 3.16.7-ckt3.

If you, or anyone else, feels it should not be added to this tree, please 
reply to this email.

For more information about the 3.16.y-ckt tree, see
https://wiki.ubuntu.com/Kernel/Dev/ExtendedStable

Thanks.
-Luis

------

>From ea56ab19520e241612bd1f9e4d9e900823ffb645 Mon Sep 17 00:00:00 2001
From: Jane Zhou <a17711@motorola.com>
Date: Mon, 24 Nov 2014 11:44:08 -0800
Subject: net/ping: handle protocol mismatching scenario

commit 91a0b603469069cdcce4d572b7525ffc9fd352a6 upstream.

ping_lookup() may return a wrong sock if sk_buff's and sock's protocols
dont' match. For example, sk_buff's protocol is ETH_P_IPV6, but sock's
sk_family is AF_INET, in that case, if sk->sk_bound_dev_if is zero, a wrong
sock will be returned.
the fix is to "continue" the searching, if no matching, return NULL.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Jane Zhou <a17711@motorola.com>
Signed-off-by: Yiwei Zhao <gbjc64@motorola.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Luis Henriques <luis.henriques@canonical.com>
---
 net/ipv4/ping.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 044a0ddf6a79..620e8ffa62e8 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -217,6 +217,8 @@ static struct sock *ping_lookup(struct net *net, struct sk_buff *skb, u16 ident)
 					     &ipv6_hdr(skb)->daddr))
 				continue;
 #endif
+		} else {
+			continue;
 		}

 		if (sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif)
