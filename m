From: Horms <horms@verge.net.au>
Subject: [PATCH] [IPVS] use msleep_interruptable() instead of ssleep() aka msleep()
Date: Tue, 28 Nov 2006 15:27:18 +0900
Message-ID: <20061128062716.GA32377@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Dean Manners <deanm@ispone.com.au>,
	Wensong Zhan <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>, Joseph Mack NA3T <jmack@wm7d.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:25746 "EHLO koto.vergenet.net")
	by vger.kernel.org with ESMTP id S935656AbWK1Gto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Nov 2006 01:49:44 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dean Manners notices that when an IPVS synchonisation daemons are
started the system load slowly climbs up to 1. This seems to be related
to the call to ssleep(1) (aka msleep(1000) in the main loop. Replacing
this with a call to msleep_interruptable() seems to make the problem go
away. Though I'm not sure that it is correct.

Cc: Dean Manners <deanm@ispone.com.au>
Signed-Off-By: Simon Horman <horms@verge.net.au>

Index: linux-2.6/net/ipv4/ipvs/ip_vs_sync.c
===================================================================
--- linux-2.6.orig/net/ipv4/ipvs/ip_vs_sync.c	2006-11-10 15:33:42.000000000 +0900
+++ linux-2.6/net/ipv4/ipvs/ip_vs_sync.c	2006-11-10 15:33:52.000000000 +0900
@@ -657,7 +657,7 @@
 		if (stop_master_sync)
 			break;
 
-		ssleep(1);
+		msleep_interruptible(1000);
 	}
 
 	/* clean up the sync_buff queue */
