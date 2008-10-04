From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH 2/2] r8169: WoL fixes
Date: Sat, 4 Oct 2008 20:10:17 +0200
Message-ID: <200810042010.17948.rjw@sisk.pl>
References: <20081004180521.7aa7e232@neptune.home> <20081004180834.71c1bdf2@neptune.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Len Brown <lenb@kernel.org>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org
To: Bruno =?utf-8?q?Pr=C3=A9mont?= <bonbons@linux-vserver.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <20081004180834.71c1bdf2@neptune.home>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday, 4 of October 2008, Bruno Pr=C3=A9mont wrote:
> Since recent kernel (2.6.26 or 2.6.27) the PCI wakeup functions are
> influenced by generic device ability and configuration when enabling
> PCI-device triggered wake-up.
>=20
> This patch causes WoL setting to enable/disable device's wish to
> be permitted to wake-up the host when changing WoL options and
> also during device probing.
>=20
> Without this patch one has write 'enabled' to
>   /sys/bus/pci/devices/0000:02:08.0/power/wakeup
>=20
> Signed-off-by: Bruno Pr=C3=A9mont <bonbons@linux-vserver.org>

Acked-by: Rafael J. Wysocki <rjw@sisk.pl>

> ---
> --- linux-2.6.27-rc8-git6.orig/drivers/net/r8169.c	2008-10-04 12:31:4=
8.000000000 +0200
> +++ linux-2.6.27-rc8-git6/drivers/net/r8169.c	2008-10-04 16:51:48.000=
000000 +0200
> @@ -619,6 +619,7 @@ static int rtl8169_set_wol(struct net_de
>  		tp->features |=3D RTL_FEATURE_WOL;
>  	else
>  		tp->features &=3D ~RTL_FEATURE_WOL;
> +	device_set_wakeup_enable(&tp->pci_dev->dev, wol->wolopts);
> =20
>  	spin_unlock_irq(&tp->lock);
> =20
> @@ -1796,6 +1797,7 @@ rtl8169_init_one(struct pci_dev *pdev, c
>  	}
> =20
>  	rtl8169_init_phy(dev, tp);
> +	device_set_wakeup_enable(&pdev->dev, tp->features & RTL_FEATURE_WOL=
);
> =20
>  out:
>  	return rc;
>=20
>=20


--
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
