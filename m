From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 02/12] phylib: do not filter phy_mii_ioctl()
Date: Tue, 15 Jun 2010 10:26:54 -0600
Message-ID: <AANLkTiliSFzs0dowKbMW-dqcmwEncHT98vGyEmXE3O3Q@mail.gmail.com>
References: <cover.1276615626.git.richard.cochran@omicron.at>
	<4cd127a2aa2c40a1b573e079e0624f10d1d94867.1276615626.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <4cd127a2aa2c40a1b573e079e0624f10d1d94867.1276615626.git.richard.cochran@omicron.at>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 15, 2010 at 10:07 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> Two maverick drivers filter the ioctl commands passed to phy_mii_ioctl().
> This is unnecessary since phylib will check the command in any case.
>
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>

At a glance, looks okay to me.

> ---
> =A0drivers/net/cpmac.c =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A05 +----
> =A0drivers/net/stmmac/stmmac_main.c | =A0 22 ++++++++--------------
> =A02 files changed, 9 insertions(+), 18 deletions(-)
>
> diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
> index d4c5ca4..0e47ca1 100644
> --- a/drivers/net/cpmac.c
> +++ b/drivers/net/cpmac.c
> @@ -846,11 +846,8 @@ static int cpmac_ioctl(struct net_device *dev, struc=
t ifreq *ifr, int cmd)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> =A0 =A0 =A0 =A0if (!priv->phy)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> - =A0 =A0 =A0 if ((cmd =3D=3D SIOCGMIIPHY) || (cmd =3D=3D SIOCGMIIREG) ||
> - =A0 =A0 =A0 =A0 =A0 (cmd =3D=3D SIOCSMIIREG))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return phy_mii_ioctl(priv->phy, ifr, cmd);
>
> - =A0 =A0 =A0 return -EOPNOTSUPP;
> + =A0 =A0 =A0 return phy_mii_ioctl(priv->phy, ifr, cmd);
> =A0}
>
> =A0static int cpmac_get_settings(struct net_device *dev, struct ethtool_c=
md *cmd)
> diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac=
_main.c
> index 6af7471..acf0616 100644
> --- a/drivers/net/stmmac/stmmac_main.c
> +++ b/drivers/net/stmmac/stmmac_main.c
> @@ -1437,24 +1437,18 @@ static void stmmac_poll_controller(struct net_dev=
ice *dev)
> =A0static int stmmac_ioctl(struct net_device *dev, struct ifreq *rq, int =
cmd)
> =A0{
> =A0 =A0 =A0 =A0struct stmmac_priv *priv =3D netdev_priv(dev);
> - =A0 =A0 =A0 int ret =3D -EOPNOTSUPP;
> + =A0 =A0 =A0 int ret;
>
> =A0 =A0 =A0 =A0if (!netif_running(dev))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
>
> - =A0 =A0 =A0 switch (cmd) {
> - =A0 =A0 =A0 case SIOCGMIIPHY:
> - =A0 =A0 =A0 case SIOCGMIIREG:
> - =A0 =A0 =A0 case SIOCSMIIREG:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!priv->phydev)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&priv->lock);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D phy_mii_ioctl(priv->phydev, rq, cmd=
);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&priv->lock);
> - =A0 =A0 =A0 default:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 if (!priv->phydev)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> +
> + =A0 =A0 =A0 spin_lock(&priv->lock);
> + =A0 =A0 =A0 ret =3D phy_mii_ioctl(priv->phydev, rq, cmd);
> + =A0 =A0 =A0 spin_unlock(&priv->lock);
> +
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> --
> 1.6.3.3
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>



-- =

Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
