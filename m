From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 2/4] net: ethoc: don't advertise gigabit speed on attached
 PHY
Date: Tue, 28 Jan 2014 22:47:35 -0800
Message-ID: <52E8A407.1020809@gmail.com>
References: <1390975218-13863-1-git-send-email-jcmvbkbc@gmail.com> <1390975218-13863-3-git-send-email-jcmvbkbc@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@cadence.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>
To: Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390975218-13863-3-git-send-email-jcmvbkbc@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Max,

Le 28/01/2014 22:00, Max Filippov a =E9crit :
> OpenCores 10/100 Mbps MAC does not support speeds above 100 Mbps, but=
 does
> not disable advertisement when PHY supports them. This results in
> non-functioning network when the MAC is connected to a gigabit PHY co=
nnected
> to a gigabit switch.
>
> The fix is to disable gigabit speed advertisement on attached PHY
> unconditionally.
>
> Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
> ---
> Changes v1->v2:
> - disable both gigabit advertisement and support.
>
>   drivers/net/ethernet/ethoc.c | 8 ++++++++
>   1 file changed, 8 insertions(+)
>
> diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/etho=
c.c
> index 4de8cfd..5643b2d 100644
> --- a/drivers/net/ethernet/ethoc.c
> +++ b/drivers/net/ethernet/ethoc.c
> @@ -688,6 +688,14 @@ static int ethoc_mdio_probe(struct net_device *d=
ev)
>   	}
>
>   	priv->phy =3D phy;
> +	phy_update_advert(phy,
> +			  ADVERTISED_1000baseT_Full |
> +			  ADVERTISED_1000baseT_Half, 0);
> +	phy_start_aneg(phy);

This does not look necessary, you should not have to call=20
phy_start_aneg() because the PHY state machine is not yet started, at=20
best this calls does nothing.

> +	phy_update_supported(phy,
> +			     SUPPORTED_1000baseT_Full |
> +			     SUPPORTED_1000baseT_Half, 0);
> +
>   	return 0;
>   }
>
>
