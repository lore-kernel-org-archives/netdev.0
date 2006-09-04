From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] DM9000 interrupt is hardware dependant
Date: Mon, 4 Sep 2006 23:11:28 +0200
Message-ID: <20060904211128.GA27614@electric-eye.fr.zoreil.com>
References: <200609042217.09004.linux@schindele.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:43740 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751460AbWIDVML
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Sep 2006 17:12:11 -0400
To: =?iso-8859-1?Q?J=FCrgen?= Schindele <linux@schindele.name>
Content-Disposition: inline
In-Reply-To: <200609042217.09004.linux@schindele.name>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

J=FCrgen Schindele <linux@schindele.name> :
[...]
> Please comment an review my patch which is attached here

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 24996da..0a71f7b 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -598,10 +598,11 @@ static int
 dm9000_open(struct net_device *dev)
 {
 	board_info_t *db =3D (board_info_t *) dev->priv;
+	unsigned long sa_flags =3D resource_sa_flags(db->irq_res);
=20
 	PRINTK2("entering dm9000_open\n");
=20
-	if (request_irq(dev->irq, &dm9000_interrupt, SA_SHIRQ, dev->name, dev=
))
+	if (request_irq(dev->irq, &dm9000_interrupt, SA_SHIRQ | sa_flags, dev=
->name, dev))

SA_SHIRQ has been replaced by IRQF_SHARED.

Please check include/linux/interrupt.h in a recent kernel 2.6.18-rc ker=
nel.

--=20
Ueimor
