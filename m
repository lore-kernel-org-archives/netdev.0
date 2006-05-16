From: Pavel Roskin <proski@gnu.org>
Subject: Re: [PATCH 3/6] new pcmcia IDs for hostap
Date: Tue, 16 May 2006 17:15:44 -0400
Message-ID: <1147814144.14914.38.camel@dv>
References: <200605161621.22459.linux-arm@hrw.one.pl>
	 <4469E3F6.5070302@garzik.org>  <200605161724.53495.linux-arm@hrw.one.pl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Jouni Malinen <jkmaline@cc.hut.fi>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:26498 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S1750842AbWEPVQA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 17:16:00 -0400
Received: from proski by fencepost.gnu.org with local (Exim 4.34)
	id 1Fg6tb-0001AZ-6q
	for netdev@vger.kernel.org; Tue, 16 May 2006 17:15:59 -0400
To: Marcin Juszkiewicz <linux-arm@hrw.one.pl>
In-Reply-To: <200605161724.53495.linux-arm@hrw.one.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On Tue, 2006-05-16 at 17:24 +0200, Marcin Juszkiewicz wrote:
> root@c7x0:~# pccardctl ident
> Socket 0:
>   product info: "D-Link", "DCF-660W", "", ""
>   manfid: 0xd601, 0x0005
>   function: 6 (network)

This manfid is in the driver already, and it also covers ZCOMAX XI-325HP
200mw cards, according to
http://tinyshell.be/aircrackng/patches/hostap-driver-0.4.7.patch

> One more Prism2 card which works with HostAP.
> 
> Platform: Sharp Zaurus SL-5500 running 2.4.18 + hostap_cs 0.4.7
> 
> root@collie:~# cardctl ident
> Socket 0:
>   product info: "NETGEAR", "MA701 Wireless CF Card", ""
>   manfid: 0xd601, 0x0002
>   function: 6 (network)

This manfid is in the driver too.

> Platform: Sharp Zaurus SL-C3100 running 2.6.16 + pcmciautils 013
> 
> root@spitz:~# pccardctl ident
> Socket 0:
>   product info: "HITACHI", "microdrive", "", ""
>   manfid: 0x0319, 0x0000
>   function: 4 (fixed disk)
> Socket 1:
>   product info:"PLANEX COMMUNICATION INC","PLANEX GW-CF11X Wireless CF Card", "", ""
>   manfid: 0xd601, 0x0010
>   function: 6 ( network )

This manfid is in the driver.

> From: Jochen Friedrich 
> 
> Yet another card known to work OK with hostap_cs:
> 
> # pccardctl ident
> Socket 0:
>   no product info available
> Socket 1:
>   product info: "U.S. Robotics", "IEEE 802.11b PC-CARD", "Version 01.02", ""
>   manfid: 0x0156, 0x0002
>   function: 6 (network)

Yes, that's needed.  I was thinking maybe we could have a macro to match
manfid and the third string.  0x0156, 0x0002 and "Version 01.02" only
appear for Prism based cards.

> +	PCMCIA_DEVICE_PROD_ID1234("ASUS", "802_11B_CF_CARD_25", "Version 01.00", "",
> +		0x78fc06ee, 0x45a50c1e, 0xa57adb8c, 0x00000000),

I think it would be better to omit the empty string.  It's mostly a
matter of taste, but if there are cards with the same ID except the
fourth string, they would be almost definitely compatible.

This entry shouldn't be needed because the manfid 0x02aa, 0x0002 is
already in the driver.

> +	PCMCIA_DEVICE_PROD_ID12("D-Link", "DCF-660W",
> +		0x1a424a1c, 0xe78b6dcc),

It shouldn't be needed (manfid 0xd601, 0x0005 is in the driver)

> +	PCMCIA_DEVICE_PROD_ID12("NETGEAR", "MA701 Wireless CF Card",
> +		0x9aa79dc3, 0xd9ec98e),

Same thing (0xd601, 0x0002)

> +	PCMCIA_DEVICE_PROD_ID12("PLANEX COMMUNICATION INC", 
> +		"PLANEX GW-CF11X Wireless CF Card",
> +		0x4703cf68, 0xfad7318d),

Same thing (0xd601, 0x0010), according to
http://www.oesf.org/forums/index.php?showtopic=14544

> +	PCMCIA_DEVICE_PROD_ID123(
> +		"Pretec", "CompactWLAN Card 802.11b", "2.5",
> +		0x1cadd3e5, 0xe697636c, 0x7a5bfcf1),

That's a good one.

> +	PCMCIA_DEVICE_PROD_ID1234(
> +		"U.S. Robotics", "IEEE 802.11b PC-CARD", "Version 01.02", ""
> +		0xc7b8df9d, 0x1700d087, 0x4b74baa0, 0x00000000),

Another useful entry, but please don't match the empty string.

-- 
Regards,
Pavel Roskin

