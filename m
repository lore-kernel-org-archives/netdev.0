From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2 net-next] r6040: invoke phy_{start,stop} when
 appropriate
Date: Fri, 07 Oct 2011 12:24:47 +0200
Message-ID: <1317983087.3207.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <201110071136.22107.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:34392 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759705Ab1JGKYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 06:24:34 -0400
Received: by bkbzt4 with SMTP id zt4so4688486bkb.19
        for <netdev@vger.kernel.org>; Fri, 07 Oct 2011 03:24:33 -0700 (PDT)
In-Reply-To: <201110071136.22107.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 07 octobre 2011 =C3=A0 11:36 +0200, Florian Fainelli a =C3=A9=
crit :
> Joe reported to me that right after a bring up of a r6040 interface
> the ethtool output had no consistent output with respect to link dupl=
ex
> and speed. Fix this by adding a missing phy_start call in r6040_up an=
d
> conversely a phy_stop call in r6040_down to properly initialize phy s=
tates.
>=20
> Reported-by: Joe Chou <Joe.Chou@rdc.com.tw>
> Signed-off-by: Florian Fainelli <florian@openwrt.org>
> ---
> diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/=
rdc/r6040.c
> index 2bbadc0..a128c3d 100644
> --- a/drivers/net/ethernet/rdc/r6040.c
> +++ b/drivers/net/ethernet/rdc/r6040.c
> @@ -470,6 +470,8 @@ static void r6040_down(struct net_device *dev)
>  	iowrite16(adrp[0], ioaddr + MID_0L);
>  	iowrite16(adrp[1], ioaddr + MID_0M);
>  	iowrite16(adrp[2], ioaddr + MID_0H);
> +
> +	phy_stop(lp->phydev);
>  }
> =20
>  static int r6040_close(struct net_device *dev)
> @@ -727,6 +729,8 @@ static int r6040_up(struct net_device *dev)
>  	/* Initialize all MAC registers */
>  	r6040_init_mac_regs(dev);
> =20
> +	phy_start(lp->phydev);
> +
>  	return 0;
>  }
> =20

You dont need to submit your patches twice (net and net-next)

If its a bug fix, base your patch against net tree

If its a new feature, against net-next
