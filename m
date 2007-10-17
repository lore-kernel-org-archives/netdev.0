From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH] fix EMAC driver for proper napi_synchronize API
Date: Thu, 18 Oct 2007 09:14:03 +1000
Message-ID: <1192662843.6783.48.camel@pasglop>
References: <1192513792.19073.23.camel@pasglop>
	 <20071016115318.0fc36af3@freepuppy.rosehill>
	 <1192589522.11899.130.camel@pasglop> <47157EA4.1000500@garzik.org>
	 <1192591481.11899.134.camel@pasglop>
	 <20071017083107.6a1b1bd3@freepuppy.rosehill>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Roland Dreier <rdreier@cisco.com>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:35205 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754398AbXJQXOU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 19:14:20 -0400
In-Reply-To: <20071017083107.6a1b1bd3@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The EMAC driver "fix" was merged by mistake before the dust had settled on
the new napi synchronize interface (and before it got merged). The final
version of that function is spelled without underscores.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
--- 

Index: linux-work/drivers/net/ibm_newemac/mal.c
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/mal.c	2007-10-18 08:02:22.000000000 +1000
+++ linux-work/drivers/net/ibm_newemac/mal.c	2007-10-18 08:02:24.000000000 +1000
@@ -322,7 +322,7 @@ void mal_poll_disable(struct mal_instanc
 		msleep(1);
 
 	/* Synchronize with the MAL NAPI poller */
-	__napi_synchronize(&mal->napi);
+	napi_synchronize(&mal->napi);
 }
 
 void mal_poll_enable(struct mal_instance *mal, struct mal_commac *commac)


