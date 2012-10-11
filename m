From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] vti: fix sparse bit endian warnings
Date: Thu, 11 Oct 2012 15:51:28 -0700
Message-ID: <20121011155128.64774827@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43441 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757144Ab2JKWwI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2012 18:52:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use be32_to_cpu instead of htonl to keep sparse happy.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.org>

--- a/net/ipv4/ip_vti.c	2012-10-10 11:54:57.165566432 -0700
+++ b/net/ipv4/ip_vti.c	2012-10-11 11:06:35.696333265 -0700
@@ -374,7 +374,7 @@ static netdev_tx_t vti_tunnel_xmit(struc
 
 	memset(&fl4, 0, sizeof(fl4));
 	flowi4_init_output(&fl4, tunnel->parms.link,
-			   htonl(tunnel->parms.i_key), RT_TOS(tos),
+			   be32_to_cpu(tunnel->parms.i_key), RT_TOS(tos),
 			   RT_SCOPE_UNIVERSE,
 			   IPPROTO_IPIP, 0,
 			   dst, tiph->saddr, 0, 0);
@@ -441,7 +441,7 @@ static int vti_tunnel_bind_dev(struct ne
 		struct flowi4 fl4;
 		memset(&fl4, 0, sizeof(fl4));
 		flowi4_init_output(&fl4, tunnel->parms.link,
-				   htonl(tunnel->parms.i_key),
+				   be32_to_cpu(tunnel->parms.i_key),
 				   RT_TOS(iph->tos), RT_SCOPE_UNIVERSE,
 				   IPPROTO_IPIP, 0,
 				   iph->daddr, iph->saddr, 0, 0);
