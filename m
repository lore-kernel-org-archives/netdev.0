From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] ems_usb: Added support for EMS CPC-USB/ARM7 CAN/USB
 interface
Date: Tue, 15 Sep 2009 13:10:34 +0200
Message-ID: <4AAF762A.5030605@gmail.com>
References: <20090914080945.5441.45509.stgit@localhost.localdomain> <20090914082229.5441.16650.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, greg@kroah.com, wg@grandegger.com,
	oliver@hartkopp.net, socketcan-core@lists.berlios.de,
	linux-usb@vger.kernel.org
To: Sebastian Haas <haas@ems-wuensche.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59354 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750913AbZIOLKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 07:10:43 -0400
In-Reply-To: <20090914082229.5441.16650.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sebastian Haas a =C3=A9crit :
> This patch adds support for one channel CAN/USB interace CPC-USB/ARM7=
 from
> EMS Dr. Thomas Wuensche (http://www.ems-wuensche.com).
>=20
> Signed-off-by: Sebastian Haas <haas@ems-wuensche.com>
> ---
>=20

=2E..

> +	netif_rx(skb);
> +
> +	dev->netdev->last_rx =3D jiffies;

Please dont update last_rx unless your driver *really* needs to.

drivers/net/sky2.c is an example of driver that has to update ->last_rx
for its internal use.

But most drivers dont need it anymore, since core network
already update it if necessary  (check skb_bond_should_drop())


> +	stats->rx_packets++;
> +	stats->rx_bytes +=3D cf->can_dlc;
> +}
> +
