From: Andreas Jaggi <aj@open.ch>
Subject: [PATCH] gre: fix ToS/DiffServ inherit bug
Date: Tue, 14 Jul 2009 17:36:48 +0200
Message-ID: <20090714153648.GC8461@urbino.open.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, kaber@trash.net,
	davem@davemloft.net
To: Wojtek Sawasciuk <voyo@no-ip.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.open.ch ([213.156.224.131]:57212 "EHLO mail6.open.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755020AbZGNPgg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jul 2009 11:36:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes two bugs:
- ToS/DiffServ inheritance was unintentionally activated when using impair fixed ToS values
- ECN bit was lost during ToS/DiffServ inheritance

Signed-off-by: Andreas Jaggi <aj@open.ch>

--- vanilla-linux-2.6.29.4/net/ipv4/ip_gre.c	2009-05-19 01:52:34.000000000 +0200
+++ gre-dev-2/net/ipv4/ip_gre.c	2009-07-14 17:14:34.000000000 +0200
@@ -677,10 +677,10 @@
 	}
 
 	tos = tiph->tos;
-	if (tos&1) {
+	if (tos == 1) {
+		tos = 0;
 		if (skb->protocol == htons(ETH_P_IP))
 			tos = old_iph->tos;
-		tos &= ~1;
 	}
 
 	{
