From: Gavin McCullagh <gavin.mccullagh@nuim.ie>
Subject: Re: [PATCH] fix integer overflow in H-TCP congestion control
Date: Wed, 25 Oct 2006 09:47:26 +0100
Message-ID: <20061025084726.GE18364@nuim.ie>
References: <20061024141739.GB18364@nuim.ie>
 <20061024.153023.131917915.davem@davemloft.net>
Reply-To: Gavin McCullagh <gavin.mccullagh@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, doug.leith@nuim.ie, baruch@ev-en.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nuim.ie ([149.157.1.19]:13053 "EHLO LARCH.MAY.IE")
	by vger.kernel.org with ESMTP id S1423047AbWJYIr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 04:47:28 -0400
Received: from retina-bcl.hamilton.local ([149.157.192.252])
 by NUIM.IE (PMDF V6.2-X17 #30789) with ESMTPA id <01M8RSRB5A7K018PMS@NUIM.IE>
 for netdev@vger.kernel.org; Wed, 25 Oct 2006 09:47:41 +0000 (GMT)
In-reply-to: <20061024.153023.131917915.davem@davemloft.net>
To: David Miller <davem@davemloft.net>
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


When using H-TCP with a single flow on a 500Mbit connection (or less
actually), alpha can exceed 65000, so alpha needs to be a u32.

Signed-off-by: Gavin McCullagh <gavin.mccullagh@nuim.ie>
Signed-off-by: Doug Leith <doug.leith@nuim.ie>


diff --git a/net/ipv4/tcp_htcp.c b/net/ipv4/tcp_htcp.c
index 6edfe5e..8072b6d 100644
--- a/net/ipv4/tcp_htcp.c
+++ b/net/ipv4/tcp_htcp.c
@@ -23,7 +23,7 @@ module_param(use_bandwidth_switch, int, 
 MODULE_PARM_DESC(use_bandwidth_switch, "turn on/off bandwidth switcher");
 
 struct htcp {
-	u16	alpha;		/* Fixed point arith, << 7 */
+	u32	alpha;		/* Fixed point arith, << 7 */
 	u8	beta;           /* Fixed point arith, << 7 */
 	u8	modeswitch;     /* Delay modeswitch until we had at least one congestion event */
 	u32	last_cong;	/* Time since last congestion event end */

