From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 03/12] phylib: add a driver method for the SIOCSHWTSTAMP
	ioctl.
Date: Tue, 15 Jun 2010 10:27:59 -0600
Message-ID: <AANLkTiml5FyHstY-0ZPHxFDvA349BZv3TeX9gXtURFFN@mail.gmail.com>
References: <cover.1276615626.git.richard.cochran@omicron.at>
	<77fe18d640e35dcbfad1e117a4321f935500d5ac.1276615626.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f204.google.com ([209.85.211.204]:40408 "EHLO
	mail-yw0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751015Ab0FOQ2U convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 12:28:20 -0400
Received: by ywh42 with SMTP id 42so4790369ywh.15
        for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 09:28:19 -0700 (PDT)
In-Reply-To: <77fe18d640e35dcbfad1e117a4321f935500d5ac.1276615626.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 15, 2010 at 10:08 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> This patch adds a phy driver method for configuring hardware time sta=
mping.
> Drivers may optionally implement this function.
>
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>

Adding an ioctl to the userspace ABI.  Make sure you cc: linux-kernel
on the next spin of this series.

g.

> ---
> =A0drivers/net/phy/phy.c | =A0 =A05 +++++
> =A0include/linux/phy.h =A0 | =A0 =A03 +++
> =A02 files changed, 8 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index bd88d81..5130db8 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -361,6 +361,11 @@ int phy_mii_ioctl(struct phy_device *phydev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>
> + =A0 =A0 =A0 case SIOCSHWTSTAMP:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (phydev->drv->hwtstamp)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return phydev->drv->hwt=
stamp(phydev, ifr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* fall through */
> +
> =A0 =A0 =A0 =A0default:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EOPNOTSUPP;
> =A0 =A0 =A0 =A0}
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index d63736a..a5e9df1 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -402,6 +402,9 @@ struct phy_driver {
> =A0 =A0 =A0 =A0/* Clears up any memory if needed */
> =A0 =A0 =A0 =A0void (*remove)(struct phy_device *phydev);
>
> + =A0 =A0 =A0 /* Handles SIOCSHWTSTAMP ioctl for hardware time stampi=
ng. */
> + =A0 =A0 =A0 int (*hwtstamp)(struct phy_device *phydev, struct ifreq=
 *ifr);
> +
> =A0 =A0 =A0 =A0struct device_driver driver;
> =A0};
> =A0#define to_phy_driver(d) container_of(d, struct phy_driver, driver=
)
> --
> 1.6.3.3
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
