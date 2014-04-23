From: roy.qing.li@gmail.com
Subject: [PATCH][net-next] tcp: remove the duplicate prefixes in the logging message
Date: Wed, 23 Apr 2014 17:28:55 +0800
Message-ID: <1398245335-18780-1-git-send-email-roy.qing.li@gmail.com>
Cc: joe@perches.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:60532 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752618AbaDWJ24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 05:28:56 -0400
Received: by mail-pd0-f178.google.com with SMTP id x10so596207pdj.37
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 02:28:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

The current message is:
	TCP: TCP: Possible SYN flooding on port 80. Sending cookies. ...

The cause is that pr_info will implicitly print the pr_fmt string, which is standard
prefix, and explicitly print the "proto" which is "TCP:" too

it is unsuitable to not print proto, since proto maybe TCPv6, so use printk directly.

Cc: Joe Perches <joe@perches.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv4/tcp_ipv4.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 438f3b9..85ebe68 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -892,8 +892,8 @@ bool tcp_syn_flood_action(struct sock *sk,
 	lopt = inet_csk(sk)->icsk_accept_queue.listen_opt;
 	if (!lopt->synflood_warned && sysctl_tcp_syncookies != 2) {
 		lopt->synflood_warned = 1;
-		pr_info("%s: Possible SYN flooding on port %d. %s.  Check SNMP counters.\n",
-			proto, ntohs(tcp_hdr(skb)->dest), msg);
+		printk(KERN_INFO "%s: Possible SYN flooding on port %d. %s. Check SNMP counters.\n",
+		       proto, ntohs(tcp_hdr(skb)->dest), msg);
 	}
 	return want_cookie;
 }
-- 
1.7.10.4
