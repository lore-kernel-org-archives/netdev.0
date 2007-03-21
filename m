From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/5] [TCP] vegas: Use type safe netlink interface
Date: Wed, 21 Mar 2007 01:18:11 +0100
Message-ID: <20070321001900.336479529@lsx.localdomain>
References: <20070321001810.616784269@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:44297 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932275AbXCUATx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 20:19:53 -0400
Content-Disposition: inline; filename=nl_tcp_vegas
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/net/ipv4/tcp_vegas.c
===================================================================
--- net-2.6.22.orig/net/ipv4/tcp_vegas.c	2007-03-20 23:53:19.000000000 +0100
+++ net-2.6.22/net/ipv4/tcp_vegas.c	2007-03-21 01:10:15.000000000 +0100
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

