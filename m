From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 000/102] Convert drivers to explicit reset API
Date: Thu, 20 Jul 2017 08:56:42 +0200
Message-ID: <20170720065642.rk44kcjkzppg6uqr@flea>
References: <20170719152646.25903-1-p.zabel@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5377596179865870267=="
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, Prashant Gaikwad <pgaikwad-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>,
 Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>, Peter Chen <Peter.Chen-3arQi8VN3Tc@public.gmane.org>,
 Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
 Marc Dietrich <marvin24-Mmb7MZpHnFY@public.gmane.org>, Rakesh Iyer <riyer-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>,
 Peter Meerwald-Stadler <pmeerw-jW+XmwGofnusTnJN9+BGXg@public.gmane.org>, linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Wim Van Sebroeck <wim-IQzOog9fTRqzQB+pC5nmwQ@public.gmane.org>, Wolfram Sang <wsa-z923LK4zBo2bacvFa/9K2g@public.gmane.org>,
 Xinliang Liu <z.liuxinliang-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
 Chanwoo Choi <cw00.choi-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>, Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
 Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>, Michael Turquette <mturquette-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
 Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>, Ohad Ben-Cohen <ohad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>,
 linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
 Vincent Abriou <vincent.abriou-qxv4g6HH51o@public.gmane.org>, Bin Liu <b-liu-l0cyMroinI0@public.gmane.org>,
 Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, linux-usb-u79uwXL29TaqPxH82wqD4g@public.gmane.org
To: Philipp Zabel <p.zabel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20170719152646.25903-1-p.zabel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org


--===============5377596179865870267==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="r7njpeniu6ypk76n"
Content-Disposition: inline


--r7njpeniu6ypk76n
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 19, 2017 at 05:25:04PM +0200, Philipp Zabel wrote:
> The reset control API has two modes: exclusive access, where the driver
> expects to have full and immediate control over the state of the reset
> line, and shared (clock-like) access, where drivers only request reset
> deassertion while active, but don't care about the state of the reset line
> while inactive.
>=20
> Commit a53e35db70d1 ("reset: Ensure drivers are explicit when requesting
> reset lines") started to transition the reset control request API calls
> to explicitly state whether the driver needs exclusive or shared reset
> control behavior.
>=20
> This series converts all drivers that currently implicitly request
> exclusive reset controls to the corresponding explicit API call. It is,
> for the most part, generated from the following semantic patch:
>=20
> @@
> expression rstc, dev, id;
> @@
> -rstc =3D reset_control_get(dev, id);
> +rstc =3D reset_control_get_exclusive(dev, id);
> @@
> expression rstc, dev, id;
> @@
> -rstc =3D reset_control_get_optional(dev, id);
> +rstc =3D reset_control_get_optional_exclusive(dev, id);
> @@
> expression rstc, node, id;
> @@
> -rstc =3D of_reset_control_get(node, id);
> +rstc =3D of_reset_control_get_exclusive(node, id);
> @@
> expression rstc, node, index;
> @@
> -rstc =3D of_reset_control_get_by_index(node, index);
> +rstc =3D of_reset_control_get_exclusive_by_index(node, index);
> @@
> expression rstc, dev, id;
> @@
> -rstc =3D devm_reset_control_get(dev, id);
> +rstc =3D devm_reset_control_get_exclusive(dev, id);
> @@
> expression rstc, dev, id;
> @@
> -rstc =3D devm_reset_control_get_optional(dev, id);
> +rstc =3D devm_reset_control_get_optional_exclusive(dev, id);
> @@
> expression rstc, dev, index;
> @@
> -rstc =3D devm_reset_control_get_by_index(dev, index);
> +rstc =3D devm_reset_control_get_exclusive_by_index(dev, index);
>=20
> After all driver patches are applied, the temporary transition helpers
> can be removed.
>=20
> regards
> Philipp
>=20
> Philipp Zabel (102):
>   ARM: rockchip: explicitly request exclusive reset control
>   ARM: socfpga: explicitly request exclusive reset control
>   MIPS: pci-mt7620: explicitly request exclusive reset control
>   ahci: st: explicitly request exclusive reset control
>   ata: sata_gemini: explicitly request exclusive reset control
>   ata: ahci_tegra: explicitly request exclusive reset control
>   bus: sunxi-rsb: explicitly request exclusive reset control
>   bus: tegra-gmi: explicitly request exclusive reset control
>   clk: sunxi: explicitly request exclusive reset control
>   clk: tegra: explicitly request exclusive reset control
>   clocksource/drivers/timer-stm32: explicitly request exclusive reset
>     control
>   clocksource/drivers/sun5i: explicitly request exclusive reset control
>   crypto: rockchip: explicitly request exclusive reset control
>   crypto: sun4i-ss - request exclusive reset control
>   PM / devfreq: tegra: explicitly request exclusive reset control
>   dmaengine: stm32-dma: explicitly request exclusive reset control
>   dmaengine: sun6i: explicitly request exclusive reset control
>   dmaengine: tegra-apb: explicitly request exclusive reset control
>   drm: kirin: explicitly request exclusive reset control
>   drm/nouveau/tegra: explicitly request exclusive reset control
>   drm/rockchip: explicitly request exclusive reset control
>   drm/sti: explicitly request exclusive reset control
>   drm/stm: explicitly request exclusive reset control
>   drm/sun4i: explicitly request exclusive reset control
>   drm/tegra: explicitly request exclusive reset control
>   gpu: host1x: explicitly request exclusive reset control
>   i2c: mv64xxx: explicitly request exclusive reset control
>   i2c: stm32f4: explicitly request exclusive reset control
>   i2c: sun6i-pw2i: explicitly request exclusive reset control
>   i2c: tegra: explicitly request exclusive reset control
>   iio: adc: rockchip_saradc: explicitly request exclusive reset control
>   iio: dac: stm32-dac-core: explicitly request exclusive reset control
>   Input: tegra-kbc - request exclusive reset control
>   coda: explicitly request exclusive reset control
>   st-rc: explicitly request exclusive reset control
>   stm32-dcmi: explicitly request exclusive reset control
>   rc: sunxi-cir: explicitly request exclusive reset control
>   mmc: dw_mmc: explicitly request exclusive reset control
>   mmc: sdhci-st: explicitly request exclusive reset control
>   mmc: sunxi: explicitly request exclusive reset control
>   mmc: tegra: explicitly request exclusive reset control
>   mtd: nand: sunxi: explicitly request exclusive reset control
>   mtd: spi-nor: stm32-quadspi: explicitly request exclusive reset
>     control
>   net: dsa: mt7530: explicitly request exclusive reset control
>   net: ethernet: hisi_femac: explicitly request exclusive reset control
>   net: ethernet: hix5hd2_gmac: explicitly request exclusive reset
>     control
>   net: stmmac: explicitly request exclusive reset control
>   net: stmmac: dwc-qos: explicitly request exclusive reset control
>   ath10k: explicitly request exclusive reset control
>   nvmem: lpc18xx-eeprom: explicitly request exclusive reset control
>   PCI: dwc: pcie-qcom: explicitly request exclusive reset control
>   PCI: imx6: explicitly request exclusive reset control
>   PCI: tegra: explicitly request exclusive reset control
>   PCI: rockchip: explicitly request exclusive reset control
>   phy: berlin-usb: explicitly request exclusive reset control
>   PCI: mediatek: explicitly request exclusive reset control
>   phy: qcom-usb-hs: explicitly request exclusive reset control
>   phy: rockchip-pcie: explicitly request exclusive reset control
>   phy: rockchip-typec: explicitly request exclusive reset control
>   phy: rockchip-usb: explicitly request exclusive reset control
>   phy: sun4i-usb: explicitly request exclusive reset control
>   phy: sun9i-usb: explicitly request exclusive reset control
>   phy: tegra: explicitly request exclusive reset control
>   phy: qcom-qmp: explicitly request exclusive reset control
>   phy: qcom-qusb2: explicitly request exclusive reset control
>   pinctrl: stm32: explicitly request exclusive reset control
>   pinctrl: sunxi: explicitly request exclusive reset control
>   pinctrl: tegra: explicitly request exclusive reset control
>   pwm: hibvt: explicitly request exclusive reset control
>   pwm: tegra: explicitly request exclusive reset control
>   remoteproc/keystone: explicitly request exclusive reset control
>   remoteproc: qcom: explicitly request exclusive reset control
>   remoteproc: st: explicitly request exclusive reset control
>   soc: mediatek: PMIC wrap: explicitly request exclusive reset control
>   soc/tegra: pmc: explicitly request exclusive reset control
>   spi: stm32: explicitly request exclusive reset control
>   spi: sun6i: explicitly request exclusive reset control
>   spi: tegra20-slink: explicitly request exclusive reset control
>   spi: tegra114: explicitly request exclusive reset control
>   spi: tegra20-sflash: explicitly request exclusive reset control
>   staging: nvec: explicitly request exclusive reset control
>   thermal: rockchip: explicitly request exclusive reset control
>   thermal: tegra: explicitly request exclusive reset control
>   serial: 8250_dw: explicitly request exclusive reset control
>   serial: tegra: explicitly request exclusive reset control
>   usb: chipidea: msm: explicitly request exclusive reset control
>   usb: dwc2: explicitly request exclusive reset control
>   usb: host: ehci-tegra: explicitly request exclusive reset control
>   usb: host: xhci-tegra: explicitly request exclusive reset control
>   usb: musb: sunxi: explicitly request exclusive reset control
>   usb: phy: msm: explicitly request exclusive reset control
>   usb: phy: qcom-8x16-usb: explicitly request exclusive reset control
>   watchdog: asm9260: explicitly request exclusive reset control
>   watchdog: mt7621: explicitly request exclusive reset control
>   watchdog: rt2880: explicitly request exclusive reset control
>   watchdog: zx2967: explicitly request exclusive reset control
>   ASoC: img: explicitly request exclusive reset control
>   ASoC: stm32: explicitly request exclusive reset control
>   ASoC: sun4i: explicitly request exclusive reset control
>   ASoC: tegra: explicitly request exclusive reset control
>   Documentation: devres: add explicit exclusive/shared reset control
>     request calls
>   reset: finish transition to explicit exclusive reset control requests


For all sunxi patches:
Acked-by: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--r7njpeniu6ypk76n
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJZcFQqAAoJEBx+YmzsjxAgwxEQAKaA2PoiKgEsYRpaVjOFH5dP
l8MoHlOl2ACw1Bcvb1uos6F4QxR6DqX1vZCIEZcuPzwJsF4gmwQdA70BxFUP53Ec
zUPP2txp1pHYft+zBbzXIrTT5oWC6kJ8S1e9QowDdSZNvi59c0ux0ai7sbCZtXA9
x/h58qsTYOqiWZAld1uC2+PWte2edFvmp97pfooG7UZZOyhGQJa3EFxWFWENC80m
9NwFkjXZXrtCwsioXfaBbkkbSy+Gejogh7HpVw7bk6nHJqm/rpCS4aFfFsd/72Fz
H8vE4yhnY616G3JrMS8c0u7RKG0pEvfu47IU3IlAdK/WWDK99mC9sjhcc1fHT3st
r6T0abU9Bf2WFmgg+lYwHV1/KUDKO6+2U/I5Vybj/TehRMzqlyHkDr8isJ4XjZLh
Q32np3ChPOdDa5yl+RFL32ICpVKv2iEdfwOPBPCAFyfnlOIDvt8yxLyzaIcDxcL8
76GhA5g/gNmNr/XUUOY6HznbpyrBtsHYKzRRyk8j6RBowVQlG/7ZNhE7cMF1aYIk
LnXgccb7XvEWvuNT0/5XOg6I1LrnBs8Pu9ox0N8aMIaJvBMlLqP38ur2EcxwpfuK
PJxqTzLfErn0NwJrAgQtAMJwDt0gGcEgs46tHLh4SJalVyMH7BFtSDLKRN6Yx3OS
8tJMPtQfcXBSZ/fWFOkD
=0VL8
-----END PGP SIGNATURE-----

--r7njpeniu6ypk76n--


--===============5377596179865870267==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linux-mediatek mailing list
Linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
http://lists.infradead.org/mailman/listinfo/linux-mediatek

--===============5377596179865870267==--
