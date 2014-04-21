From: roy.qing.li@gmail.com
Subject: [PATCH][net-next] tcp: remove the duplicate prefixes in the logging message
Date: Mon, 21 Apr 2014 21:17:57 +0800
Message-ID: <1398086277-27943-1-git-send-email-roy.qing.li@gmail.com>
Cc: joe@perches.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:50080 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752063AbaDUNSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 09:18:01 -0400
Received: by mail-pb0-f47.google.com with SMTP id up15so3694994pbc.6
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 06:18:01 -0700 (PDT)
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
index 6379894..370fa46 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -892,8 +892,8 @@ bool tcp_syn_flood_action(struct sock *sk,
 	lopt = inet_csk(sk)->icsk_accept_queue.listen_opt;
 	if (!lopt->synflood_warned && sysctl_tcp_syncookies != 2) {
 		lopt->synflood_warned = 1;
-		pr_info("%s: Possible SYN flooding on port %d. %s.  Check SNMP counters.\n",
-			proto, ntohs(tcp_hdr(skb)->dest), msg);
+		printk(KERN_INFO "%s: Possible SYN flooding on port %d. %s. Check SNMP counters.\n"
+		       proto, ntohs(tcp_hdr(skb)->dest), msg);
 	}
 	return want_cookie;
 }
-- 
1.7.10.4
