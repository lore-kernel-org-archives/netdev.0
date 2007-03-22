From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/8] [TCP] westwood: Use type safe netlink interface
Date: Thu, 22 Mar 2007 23:18:06 +0100
Message-ID: <20070322221849.416346225@lsx.localdomain>
References: <20070322221804.000124130@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56181 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161155AbXCVWVq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 18:21:46 -0400
Content-Disposition: inline; filename=nl_tcp_westwood
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/net/ipv4/tcp_westwood.c
===================================================================
--- net-2.6.22.orig/net/ipv4/tcp_westwood.c	2007-03-22 23:08:48.000000000 +0100
+++ net-2.6.22/net/ipv4/tcp_westwood.c	2007-03-22 23:09:23.000000000 +0100
@@ -260,16 +260,13 @@ static void tcp_westwood_info(struct soc
 {
 	const struct westwood *ca = inet_csk_ca(sk);
 	if (ext & (1 << (INET_DIAG_VEGASINFO - 1))) {
-		struct rtattr *rta;
-		struct tcpvegas_info *info;
+		struct tcpvegas_info info = {
+			.tcpv_enabled = 1,
+			.tcpv_rtt = jiffies_to_usecs(ca->rtt),
+			.tcpv_minrtt = jiffies_to_usecs(ca->rtt_min),
+		};
 
-		rta = __RTA_PUT(skb, INET_DIAG_VEGASINFO, sizeof(*info));
-		info = RTA_DATA(rta);
-		info->tcpv_enabled = 1;
-		info->tcpv_rttcnt = 0;
-		info->tcpv_rtt = jiffies_to_usecs(ca->rtt);
-		info->tcpv_minrtt = jiffies_to_usecs(ca->rtt_min);
-	rtattr_failure:	;
+		nla_put(skb, INET_DIAG_VEGASINFO, sizeof(info), &info);
 	}
 }
 

--

