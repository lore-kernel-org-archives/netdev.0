From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCHv2 net-next] net: fec: Ensure clocks are enabled while
 using mdio bus
Date: Sat, 20 Jun 2015 18:01:33 -0700
Message-ID: <55860CED.2070307@gmail.com>
References: <1434816914-9816-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nimrod Andy <B38611@freescale.com>,
	Duan Andy <fugang.duan@freescale.com>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:36380 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755352AbbFUBBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2015 21:01:38 -0400
Received: by oigb199 with SMTP id b199so60347697oig.3
        for <netdev@vger.kernel.org>; Sat, 20 Jun 2015 18:01:38 -0700 (PDT)
In-Reply-To: <1434816914-9816-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/20/15 09:15, Andrew Lunn a =C3=A9crit :
> When a switch is attached to the mdio bus, the mdio bus can be used
> while the interface is not open. If the IPG clock are not enabled,
> MDIO reads/writes will simply time out. So enable the clock before
> starting a transaction, and disable it afterwards. The CCF performs
> reference counting so the clock will only be disabled if there are no
> other users.
>=20
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
> v2:
>   Only enable/disable the IPG clock.
>=20
> drivers/net/ethernet/freescale/fec_main.c | 21 +++++++++++++++++++--
>  1 file changed, 19 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/=
ethernet/freescale/fec_main.c
> index bf4cf3fbb5f2..2b8a043a573c 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -65,6 +65,7 @@
> =20
>  static void set_multicast_list(struct net_device *ndev);
>  static void fec_enet_itr_coal_init(struct net_device *ndev);
> +static int fec_enet_clk_enable(struct net_device *ndev, bool enable)=
;

You do not seem to be using this, unrelated change?
--=20
=46lorian
