From: "Matvejchikov Ilya" <matvejchikov@gmail.com>
Subject: [PATCH] fs_enet and multicasting
Date: Thu, 17 May 2007 16:15:53 +0400
Message-ID: <8496f91a0705170515i1ac47671u83f8f4e602dc10b0@mail.gmail.com>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.229]:19483 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753078AbXEQMP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2007 08:15:57 -0400
Received: by nz-out-0506.google.com with SMTP id r28so926315nza
        for <netdev@vger.kernel.org>; Thu, 17 May 2007 05:15:53 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Good Day!

There is a problem in fs_enet driver. When restart function is called
the multicast settings do not restore. This patch fixes this bug.

Signed-off-by: Matvejchikov Ilya <matvejchikov@gmail.com>
---

diff -purN linux-2.6.21-clean/drivers/net/fs_enet/mac-fcc.c
linux-2.6.21/drivers/net/fs_enet/mac-fcc.c
--- linux-2.6.21-clean/drivers/net/fs_enet/mac-fcc.c	2007-04-26
07:08:32.000000000 +0400
+++ linux-2.6.21/drivers/net/fs_enet/mac-fcc.c	2007-05-17
12:43:02.000000000 +0400
@@ -433,6 +433,8 @@ static void restart(struct net_device *d
 	else
  		C32(fccp, fcc_fpsmr, FCC_PSMR_FDE | FCC_PSMR_LPB);

+	set_multicast_list(dev);
+
  	S32(fccp, fcc_gfmr, FCC_GFMR_ENR | FCC_GFMR_ENT);
 }
diff -purN linux-2.6.21-clean/drivers/net/fs_enet/mac-fec.c
linux-2.6.21/drivers/net/fs_enet/mac-fec.c
--- linux-2.6.21-clean/drivers/net/fs_enet/mac-fec.c	2007-04-26
07:08:32.000000000 +0400
+++ linux-2.6.21/drivers/net/fs_enet/mac-fec.c	2007-05-17
12:35:59.000000000 +0400
@@ -366,6 +366,8 @@ static void restart(struct net_device *d
  		FC(fecp, x_cntrl, FEC_TCNTRL_FDEN);	/* FD disable */
 	}

+	set_multicast_list(dev);
+
 	/*
 	 * Enable interrupts we wish to service.
 	 */
diff -purN linux-2.6.21-clean/drivers/net/fs_enet/mac-scc.c
linux-2.6.21/drivers/net/fs_enet/mac-scc.c
--- linux-2.6.21-clean/drivers/net/fs_enet/mac-scc.c	2007-04-26
07:08:32.000000000 +0400
+++ linux-2.6.21/drivers/net/fs_enet/mac-scc.c	2007-05-17
12:36:11.000000000 +0400
@@ -371,6 +371,8 @@ static void restart(struct net_device *d
  	if (fep->phydev->duplex)
  		S16(sccp, scc_psmr, SCC_PSMR_LPB | SCC_PSMR_FDE);

+	set_multicast_list(dev);
+
  	S32(sccp, scc_gsmrl, SCC_GSMRL_ENR | SCC_GSMRL_ENT);
 }
