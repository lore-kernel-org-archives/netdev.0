From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/5] [TCP] westwood: Use type safe netlink interface
Date: Wed, 21 Mar 2007 01:18:12 +0100
Message-ID: <20070321001900.471828016@lsx.localdomain>
References: <20070321001810.616784269@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:44304 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932240AbXCUAT6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 20:19:58 -0400
Content-Disposition: inline; filename=nl_tcp_westwood
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/net/ipv4/tcp_westwood.c
===================================================================
--- net-2.6.22.orig/net/ipv4/tcp_westwood.c	2007-03-20 23:53:19.000000000 +0100
+++ net-2.6.22/net/ipv4/tcp_westwood.c	2007-03-21 01:10:16.000000000 +0100
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

