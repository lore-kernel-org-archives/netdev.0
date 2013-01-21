From: "Cedric VONCKEN" <cedric.voncken@acksys.fr>
Subject: [patch]  Gianfar : Enable promiscous mode after queue time out
Date: Mon, 21 Jan 2013 17:24:43 +0100
Message-ID: <773DB8A82AB6A046AE0195C68612A319014B7309@sbs2003.acksys.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Claudiu Manoil" <claudiu.manoil@freescale.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out04.msg.oleane.net ([62.161.7.2]:40403 "EHLO
	smtp-out04.msg.oleane.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052Ab3AURL2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 12:11:28 -0500
Received: from smtp01.msg.oleane.net (smtp01.mail.priv [172.17.20.110])
	by smtp-out04.msg.oleane.net with ESMTP id r0LGjcwU001812
	for <netdev@vger.kernel.org>; Mon, 21 Jan 2013 17:45:38 +0100
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Hi all, 

	When the Netdev tx queue timeout occurred, the function
gfar_timeout(..) is called. This function calls indirectly the
gfar_init_mac(..) function.

 	In this function, the rctrl register is set to a default value.

 	If the Promiscuous is enable on the net dev ( flag IFF_PROMISC
is  set), the gfar_init_function does not reactivate it.

 	The Promiscuous mode is used for example when the netdev is
bridged.
 	
 	I apply this patch on the kernel 3.8-rc4 to fix it.

	Signed-off-by : Voncken C Acksys <cedric.voncken@acksys.fr>

--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -349,6 +349,11 @@ static void gfar_init_mac(struct net_dev
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
