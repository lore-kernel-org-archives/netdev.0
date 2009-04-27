From: David Miller <davem@davemloft.net>
Subject: Re: tun: add IFF_TUN_EXCL flag to avoid opening a persistent
 device.
Date: Mon, 27 Apr 2009 03:24:05 -0700 (PDT)
Message-ID: <20090427.032405.50493174.davem@davemloft.net>
References: <1240506258.15245.11.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45977
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753189AbZD0KYM convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Apr 2009 06:24:12 -0400
In-Reply-To: <1240506258.15245.11.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Woodhouse <dwmw2@infradead.org>
Date: Thu, 23 Apr 2009 18:04:18 +0100

> When creating a certain types of VPN, NetworkManager will first attem=
pt
> to find an available tun device by iterating through 'vpn%d' until it
> finds one that isn't already busy. Then it'll set that to be persiste=
nt
> and owned by the otherwise unprivileged user that the VPN d=E6mon its=
elf
> runs as.
>=20
> There's a race condition here -- during the period where the vpn%d
> device is created and we're waiting for the VPN d=E6mon to actually
> connect and use it, if we try to create _another_ device we could end=
 up
> re-using the same one -- because trying to open it again doesn't get
> -EBUSY as it would while it's _actually_ busy.
>=20
> So solve this, we add an IFF_TUN_EXCL flag which causes tun_set_iff()=
 to
> fail if it would be opening an existing persistent tundevice -- so th=
at
> we can make sure we're getting an entirely _new_ device.
>=20
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

Applied to net-next-2.6, thanks David.
