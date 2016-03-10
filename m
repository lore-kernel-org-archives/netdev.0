From: Karol Herbst <git@karolherbst.de>
Subject: Re: [PATCH 2/2] net/forcedeth: add wol p support
Date: Thu, 10 Mar 2016 17:13:24 +0100 (CET)
Message-ID: <184411394.167711.1457626404184.JavaMail.open-xchange@www.ud-mail.de>
References: <1457621884-2479-1-git-send-email-git@karolherbst.de> <1457621884-2479-3-git-send-email-git@karolherbst.de>
Reply-To: Karol Herbst <git@karolherbst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"David S . Miller" <davem@davemloft.net>
To: linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp03.udag.de ([62.146.106.29]:35376 "EHLO smtp03.udag.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753263AbcCJQN0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 11:13:26 -0500
In-Reply-To: <1457621884-2479-3-git-send-email-git@karolherbst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

one note though:

I am not _really_ sure it is the right flag. I've contacted somebody at=
 nvidia
and asked for documentation regarding this mmio reg.

I still get some random wakeups and I don't know where they are comming=
 from.

> Karol Herbst <git@karolherbst.de> hat am 10. M=C3=A4rz 2016 um 15:58 =
geschrieben:
>=20
>=20
> REd on my mac mini. No idea if that also works on other ethernet card=
s
> supported by forcedeth, but I doubt anybody cares at all, otherwise s=
omebody
> else would have REd it already.
>=20
> Signed-off-by: Karol Herbst <nouveau@karolherbst.de>
> ---
>  drivers/net/ethernet/nvidia/forcedeth.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/nvidia/forcedeth.c
> b/drivers/net/ethernet/nvidia/forcedeth.c
> index bdce33b..8e4e894 100644
> --- a/drivers/net/ethernet/nvidia/forcedeth.c
> +++ b/drivers/net/ethernet/nvidia/forcedeth.c
> @@ -291,6 +291,7 @@ enum {
>  #define NVREG_WAKEUPFLAGS_ACCEPT_WAKEUPPAT	0x02
>  #define NVREG_WAKEUPFLAGS_ACCEPT_LINKCHANGE	0x04
>  #define NVREG_WAKEUPFLAGS_ENABLE_G	0x01111
> +#define NVREG_WAKEUPFLAGS_ENABLE_P	0x12000
> =20
>  	NvRegMgmtUnitGetVersion =3D 0x204,
>  #define NVREG_MGMTUNITGETVERSION	0x01
> @@ -4216,12 +4217,14 @@ static void nv_get_drvinfo(struct net_device =
*dev,
> struct ethtool_drvinfo *info)
>  static void nv_get_wol(struct net_device *dev, struct ethtool_wolinf=
o
> *wolinfo)
>  {
>  	struct fe_priv *np =3D netdev_priv(dev);
> -	wolinfo->supported =3D WAKE_MAGIC;
> +	wolinfo->supported =3D WAKE_MAGIC | WAKE_PHY;
> =20
>  	spin_lock_irq(&np->lock);
>  	wolinfo->wolopts =3D 0;
>  	if (np->wolenabled & WAKE_MAGIC)
>  		wolinfo->wolopts |=3D WAKE_MAGIC;
> +	if (np->wolenabled & WAKE_PHY)
> +		wolinfo->wolopts |=3D WAKE_PHY;
>  	spin_unlock_irq(&np->lock);
>  }
> =20
> @@ -4236,6 +4239,10 @@ static int nv_set_wol(struct net_device *dev, =
struct
> ethtool_wolinfo *wolinfo)
>  		np->wolenabled |=3D WAKE_MAGIC;
>  		np->wol_flags |=3D NVREG_WAKEUPFLAGS_ENABLE_G;
>  	}
> +	if (wolinfo->wolopts & WAKE_PHY) {
> +		np->wolenabled |=3D WAKE_PHY;
> +		np->wol_flags |=3D NVREG_WAKEUPFLAGS_ENABLE_P;
> +	}
>  	if (netif_running(dev)) {
>  		spin_lock_irq(&np->lock);
>  		writel(np->wol_flags, base + NvRegWakeUpFlags);
> --=20
> 2.7.2
>
