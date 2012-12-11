From: "Cedric VONCKEN" <cedric.voncken@acksys.fr>
Subject: Gianfar driver issue
Date: Tue, 11 Dec 2012 10:59:03 +0100
Message-ID: <773DB8A82AB6A046AE0195C68612A31901412124@sbs2003.acksys.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out05.msg.oleane.net ([62.161.7.3]:48954 "EHLO
	smtp-out05.msg.oleane.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752904Ab2LKMGQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 07:06:16 -0500
Received: from smtp29.msg.oleane.net (smtp29.mail.priv [172.17.20.151])
	by smtp-out05.msg.oleane.net with ESMTP id qBBAJUQo018097
	for <netdev@vger.kernel.org>; Tue, 11 Dec 2012 11:19:30 +0100
Received: from acksys.fr ([195.6.104.67]) (authenticated)
	by smtp29.msg.oleane.net (MTA) with ESMTP id qBB9x4oZ014707
	for <netdev@vger.kernel.org>; Tue, 11 Dec 2012 10:59:04 +0100
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Hi all, 

	I think he have an issue in Gianfar driver.

	When the Netdev tx queue timeout occurred, the function
gfar_timeout(..) is called. This function calls indirectly the
gfar_init_mac(..) function.

	In this function, the rctrl register is set to a default value.

	If the Promiscuous is enable on the net dev ( flag IFF_PROMISC
is set), the gfar_init_function does not reactivate it. 

	The Promiscuous mode is used for example when the netdev is
bridged. 
	
	I apply this patch to fix it.

	--- a/drivers/net/ethernet/freescale/gianfar.c.	2012-06-01
09:16:13.000000000 +0200
	+++ b/drivers/net/ethernet/freescale/gianfar.c	2012-12-11
10:38:23.000000000 +0100
	@@ -356,6 +356,11 @@
 	/* Configure the coalescing support */
 	gfar_configure_coalescing(priv, 0xFF, 0xFF);
 
+	if (ndev->flags & IFF_PROMISC) {
+		/* Set RCTRL to PROM */
+		rctrl |= RCTRL_PROM;
+	}
+
 	if (priv->rx_filer_enable) {
 		rctrl |= RCTRL_FILREN;
 		/* Program the RIR0 reg with the required distribution
*/



Cedric Voncken 
