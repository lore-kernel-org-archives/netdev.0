From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: fec: Fix multicast list setup in fec_restart().
Date: Fri, 21 Jun 2013 10:25:08 -0700
Message-ID: <1371835508.19215.50.camel@joe-AO722>
References: <61455.62.178.124.14.1371832855.squirrel@mail.theobroma-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	netdev@vger.kernel.org
To: Christoph =?ISO-8859-1?Q?M=FCllner?=
	<christoph.muellner@theobroma-systems.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <61455.62.178.124.14.1371832855.squirrel@mail.theobroma-systems.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-06-21 at 18:40 +0200, Christoph M=FCllner wrote:
> Setup the multicast list of the net_device instead of
> clearing it blindly. This restores the multicast groups
> in case of a link down/up event.
>=20
> Signed-off-by: Christoph Muellner <christoph.muellner@theobroma-syste=
ms.com>

Theobroma?
food of the gods or does your company just like chocolate?

> diff --git a/drivers/net/ethernet/freescale/fec_main.c
[]
> +static void set_multicast_list(struct net_device *ndev);
[]
> @@ -472,8 +474,7 @@ fec_restart(struct net_device *ndev, int duplex)
>         writel(0xffc00000, fep->hwp + FEC_IEVENT);
>=20
>         /* Reset all multicast. */
> -       writel(0, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
> -       writel(0, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
> +       set_multicast_list(ndev);

maybe dev_set_rx_mode(ndev) ?
