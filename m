From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix #51791 - bug? mac 00:00:00:00:00:00 with natsemi
 DP83815 after driver load
Date: Tue, 18 Nov 2014 15:49:17 -0500 (EST)
Message-ID: <20141118.154917.171051693633411092.davem@davemloft.net>
References: <trinity-1cec0308-6242-413f-a63f-b09cded30a4f-1416096326518@3capp-webde-bs03>
	<trinity-9c3b63ff-f474-4d99-84d8-29034921bb3c-1416183467662@3capp-webde-bs06>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: devzero@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56752 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755312AbaKRUtT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 15:49:19 -0500
In-Reply-To: <trinity-9c3b63ff-f474-4d99-84d8-29034921bb3c-1416183467662@3capp-webde-bs06>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Roland Kletzing" <devzero@web.de>
Date: Mon, 17 Nov 2014 01:17:47 +0100

> This one should fix Bugzilla #51791 (details below).=20
>=20
> Natsemi driver does not read MAC correctly from eeprom, while natsemi=
-diag from nictools-pci does. Apparently, tt`s a timing issue in the ke=
rnel driver.
>=20
> According to ftp://ftp.gwdg.de/pub/linux/misc/donald.becker/diag/nats=
emi-diag.c , eeprom_delay(ee_addr) is defined as follows:
>=20
> /* Delay between EEPROM clock transitions.
>    This flushes the write buffer to prevent quick double-writes.
> */
> #define eeprom_delay(ee_addr) 	inl(ee_addr); inl(ee_addr)
>=20
> while in the natsemi linux kernel driver, the delay is done this way =
:
>=20
> #define eeprom_delay(ee_addr)   readl(ee_addr)
>=20
> , which results in the MAC being all zero`s.
>=20
> So i simply added a second readl() to increase delay (instead of turn=
ing into inl() as proposed before). This may look a little bit ugly, bu=
t it`s fixing the problem for me.
>=20
> I=B4m not sure how many natsemi users being left on this planet (prob=
ably few), but i guess this change does not do any harm on platforms wh=
ere the driver does not behave buggy, so please consider adding it to m=
ainline/stable/longterm.
>=20
> Signed-off-by: Roland Kletzing <devzero@web.de>

Please post your patch as a clean new email, without quoting things
after your signoff etc.

Also, please break your lines up to 80 columns max.

Thanks.
