From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] DCCP: Fix to handle short sequence numbers packet correctly
Date: Fri, 23 May 2008 09:08:48 +0800
Message-ID: <48361920.9090309@cn.fujitsu.com>
References: <4834EA23.3070309@cn.fujitsu.com> <20080522090720.GA4827@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yjwei@cn.fujitsu.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52227 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1758105AbYEWBIp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 21:08:45 -0400
In-Reply-To: <20080522090720.GA4827@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC4340 said:
  8.5.  Pseudocode
       ...
       If P.type is not Data, Ack, or DataAck and P.X == 0 (the packet
             has short sequence numbers), drop packet and return

But DCCP has some mistake to handle short sequence numbers packet, now 
it drop packet only if P.type is Data, Ack, or DataAck and P.X == 0.

This patch fixed this problem.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

--- a/net/dccp/ipv4.c	2008-05-18 11:54:29.000000000 -0400
+++ b/net/dccp/ipv4.c	2008-05-18 11:55:51.000000000 -0400
@@ -741,8 +741,8 @@ int dccp_invalid_packet(struct sk_buff *
 	 * If P.type is not Data, Ack, or DataAck and P.X == 0 (the packet
 	 * has short sequence numbers), drop packet and return
 	 */
-	if (dh->dccph_type >= DCCP_PKT_DATA    &&
-	    dh->dccph_type <= DCCP_PKT_DATAACK && dh->dccph_x == 0)  {
+	if ((dh->dccph_type < DCCP_PKT_DATA    ||
+	    dh->dccph_type > DCCP_PKT_DATAACK) && dh->dccph_x == 0)  {
 		DCCP_WARN("P.type (%s) not Data || [Data]Ack, while P.X == 0\n",
 			  dccp_packet_name(dh->dccph_type));
 		return 1;




