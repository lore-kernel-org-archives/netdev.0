From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/8] [TCP] vegas: Use type safe netlink interface
Date: Thu, 22 Mar 2007 23:18:05 +0100
Message-ID: <20070322221849.272950310@lsx.localdomain>
References: <20070322221804.000124130@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56176 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161152AbXCVWVl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 18:21:41 -0400
Content-Disposition: inline; filename=nl_tcp_vegas
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/net/ipv4/tcp_vegas.c
===================================================================
--- net-2.6.22.orig/net/ipv4/tcp_vegas.c	2007-03-22 23:08:48.000000000 +0100
+++ net-2.6.22/net/ipv4/tcp_vegas.c	2007-03-22 23:09:21.000000000 +0100
@@ -341,16 +341,14 @@ static void tcp_vegas_get_info(struct so
 {
 	const struct vegas *ca = inet_csk_ca(sk);
 	if (ext & (1 << (INET_DIAG_VEGASINFO - 1))) {
-		struct tcpvegas_info *info;
+		struct tcpvegas_info info = {
+			.tcpv_enabled = ca->doing_vegas_now,
+			.tcpv_rttcnt = ca->cntRTT,
+			.tcpv_rtt = ca->baseRTT,
+			.tcpv_minrtt = ca->minRTT,
+		};
 
-		info = RTA_DATA(__RTA_PUT(skb, INET_DIAG_VEGASINFO,
-					  sizeof(*info)));
-
-		info->tcpv_enabled = ca->doing_vegas_now;
-		info->tcpv_rttcnt = ca->cntRTT;
-		info->tcpv_rtt = ca->baseRTT;
-		info->tcpv_minrtt = ca->minRTT;
-	rtattr_failure:	;
+		nla_put(skb, INET_DIAG_VEGASINFO, sizeof(info), &info);
 	}
 }
 

--

