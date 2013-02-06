From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH v2 1/4] ssb: get mac address from sprom struct for gige
 driver
Date: Wed, 6 Feb 2013 19:21:34 +0100
Message-ID: <20130206192134.4bbb4bbb@milhouse>
References: <1360170854-32029-1-git-send-email-hauke@hauke-m.de>
	<1360170854-32029-2-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/j4tQFxD=uzm66iWMX+1qL6z"; protocol="application/pgp-signature"
Cc: davem@davemloft.net, mcarlson@broadcom.com, mchan@broadcom.com,
	nsujir@broadcom.com, netdev@vger.kernel.org
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bues.ch ([80.190.117.144]:33275 "EHLO bues.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753399Ab3BFSYJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 13:24:09 -0500
In-Reply-To: <1360170854-32029-2-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/j4tQFxD=uzm66iWMX+1qL6z
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed,  6 Feb 2013 18:14:11 +0100
Hauke Mehrtens <hauke@hauke-m.de> wrote:

> The mac address is already stored in the sprom structure by the
> platform code of the SoC this Ethernet core is found on, it just has to
> be fetched from this structure instead of accessing the nvram here.
> This patch also adds a return value to indicate if a mac address could
> be fetched from the sprom structure.
>=20
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>

Acked-by: Michael Buesch <m@bues.ch>

> ---
>=20
> This patch could cause merge problems with the mips tree. This version,=20
> removing the usage of nvram_getenv and nvram_parse_macaddr, should be=20
> used.
>=20
>  include/linux/ssb/ssb_driver_gige.h |   19 +++++++------------
>  1 file changed, 7 insertions(+), 12 deletions(-)
>=20
> diff --git a/include/linux/ssb/ssb_driver_gige.h b/include/linux/ssb/ssb_=
driver_gige.h
> index 6b05dcd..912af3c 100644
> --- a/include/linux/ssb/ssb_driver_gige.h
> +++ b/include/linux/ssb/ssb_driver_gige.h
> @@ -97,21 +97,16 @@ static inline bool ssb_gige_must_flush_posted_writes(=
struct pci_dev *pdev)
>  	return 0;
>  }
> =20
> -#ifdef CONFIG_BCM47XX
> -#include <asm/mach-bcm47xx/nvram.h>
>  /* Get the device MAC address */
> -static inline void ssb_gige_get_macaddr(struct pci_dev *pdev, u8 *macadd=
r)
> -{
> -	char buf[20];
> -	if (nvram_getenv("et0macaddr", buf, sizeof(buf)) < 0)
> -		return;
> -	nvram_parse_macaddr(buf, macaddr);
> -}
> -#else
> -static inline void ssb_gige_get_macaddr(struct pci_dev *pdev, u8 *macadd=
r)
> +static inline int ssb_gige_get_macaddr(struct pci_dev *pdev, u8 *macaddr)
>  {
> +	struct ssb_gige *dev =3D pdev_to_ssb_gige(pdev);
> +	if (!dev)
> +		return -ENODEV;
> +
> +	memcpy(macaddr, dev->dev->bus->sprom.et0mac, 6);
> +	return 0;
>  }
> -#endif
> =20
>  extern int ssb_gige_pcibios_plat_dev_init(struct ssb_device *sdev,
>  					  struct pci_dev *pdev);



--=20
Greetings, Michael.

PGP: 908D8B0E

--Sig_/j4tQFxD=uzm66iWMX+1qL6z
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJREp8uAAoJEPUyvh2QjYsOA6EP/iYIb8W9rItsHW8E4MmmO4dZ
500JAgggQOLmQ76ARs+XHxFLkKCT1hiSWtnlDrCruBLCmLTei2svYzofCadDoajf
P/4B/lH1RVJD0/JVNzLtTnl8CD9k3J1rypyaFS6yT3ruvG++zH1ZNROLyLNTVPKb
NGQhK9s/mhY+HNmU+3WAI3/jjzYy3dwjs4rl0K6riA5t82pUeswKaikx4kaX2b5b
2ZMp30vldKR1gVUUJn7BfQcWEvEM2hU+C9ZH5wINOSp4/bPXOqaM6Qk+ZbDtrK1M
fNAur2euIzTD+DV8qGAEW6GWMpbg2sMj87911rHz/2yKUPEYex+ekgF5yA4N6RSp
40Cfn6I72GoOw4a8XvOUI2HVFVtrxz8M2/drnjBbd2pkfLorwgUV32hsD2AFkIpM
9UldVAn5y3wn8tdUGArTfaQpWs/tWSIUV+CG6Dx00quojyvV1EELzX0x+Mi0Kt12
6YsZL4pARAiUxpKb2ZlGvBNXwN4qdHyg4sZepPdMxh8pkkmUEClY8fLCPlT+0JTb
jReiCZylbulbsCxQmy/IX6CYGZ7FEEQkjHv9Z6lv7d5lS658CClyN2++9YjBtHfa
NH7u49UFhXBPVX9x32lM6obO/L03pnmSYDo0SEcg7aKTS8BovPW0PzXbcioDfpF0
TTSD2d1yYZ74CNOP44EX
=ZSKf
-----END PGP SIGNATURE-----

--Sig_/j4tQFxD=uzm66iWMX+1qL6z--
