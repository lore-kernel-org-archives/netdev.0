From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH 1/5] new pcmcia IDs for hostap - ASUS WL-110
Date: Fri, 12 May 2006 09:57:06 -0700
Message-ID: <20060512165706.GA4079@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:19082 "EHLO palrel10.hp.com")
	by vger.kernel.org with ESMTP id S1750762AbWELQ5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 May 2006 12:57:13 -0400
To: Marcin Juszkiewicz <linux-arm@hrw.one.pl>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marcin Juszkiewicz wrote :
> 
> This time I checked more carefully my changeset and split it into
> smaller parts. Few of my patches was tested by OpenZaurus users, some
> are waiting for testing.

	I'm sorry, but I will have again to veto part of your patch.
	You are removing IDs from the Orinoco driver. Please don't do
that, those card work perfectly with the orinoco driver, and some of
us run them with the orinoco driver (orinoco is one third the
footprint of hostap).

> We switched to pcmciautils when moved to 2.6.16 and many users complain
> that their WiFi CompactFlash cards are driven by orinoco instead of
> hostap.
> 
> BTW - how to force using of hostap_cs when both hostap_cs and orinoco_cs
> has card in device table?

	The overall architecture of hotplug/udev module loading is
broken as it does not allow user override. I have explained in details
the problem to the concerned people, but it seems that they don't
really care. The standard answer is "blacklist the orinoco
module". Let's not even mention libusual.

> --- linux.orig/drivers/net/wireless/orinoco_cs.c	2006-05-12 15:02:13.000000000 +0200
> +++ linux/drivers/net/wireless/orinoco_cs.c	2006-05-12 15:03:31.000000000 +0200
> @@ -533,7 +533,6 @@
>  	PCMCIA_DEVICE_MANF_CARD(0x0274, 0x1613), /* Linksys WPC11 Version 3 */
>  	PCMCIA_DEVICE_MANF_CARD(0x028a, 0x0002), /* Compaq HNW-100 11 Mbps Wireless Adapter \
> */  PCMCIA_DEVICE_MANF_CARD(0x028a, 0x0673), /* Linksys WCF12 Wireless CompactFlash \
>                 Card */
> -	PCMCIA_DEVICE_MANF_CARD(0x02aa, 0x0002), /* ASUS SpaceLink WL-100 */
>  	PCMCIA_DEVICE_MANF_CARD(0x02ac, 0x0002), /* SpeedStream SS1021 Wireless Adapter */
>  	PCMCIA_DEVICE_MANF_CARD(0x14ea, 0xb001), /* PLANEX RoadLannerWave GW-NS11H */
>  	PCMCIA_DEVICE_MANF_CARD(0x50c2, 0x7300), /* Airvast WN-100 */
> @@ -548,8 +547,6 @@
>  	PCMCIA_DEVICE_PROD_ID12("Addtron", "AWP-100 Wireless PCMCIA", 0xe6ec52ce, \
> 0x08649af2),  PCMCIA_DEVICE_PROD_ID123("AIRVAST", "IEEE 802.11b Wireless PCMCIA \
> Card", "HFA3863", 0xea569531, 0x4bcb9645, 0x355cb092),  \
> PCMCIA_DEVICE_PROD_ID12("Allied Telesyn", "AT-WCL452 Wireless PCMCIA Radio", \
>                 0x5cd01705, 0x4271660f),
> -	PCMCIA_DEVICE_PROD_ID12("ASUS", "802_11b_PC_CARD_25", 0x78fc06ee, 0xdb9aa842),
> -	PCMCIA_DEVICE_PROD_ID12("ASUS", "802_11B_CF_CARD_25", 0x78fc06ee, 0x45a50c1e),
>  	PCMCIA_DEVICE_PROD_ID12("Avaya Communication", "Avaya Wireless PC Card", \
> 0xd8a43b78, 0x0d341169),  PCMCIA_DEVICE_PROD_ID12("BENQ", "AWL100 PCMCIA ADAPTER", \
> 0x35dadc74, 0x01f7fedb),  PCMCIA_DEVICE_PROD_ID12("BUFFALO", "WLI-PCM-L11G", \
>                 0x2decece3, 0xf57ca4b3),

	Please do *NOT* remove those IDs from the Orinoco driver. The
Orinoco driver do support those devices properly.

	Regards,

	Jean
