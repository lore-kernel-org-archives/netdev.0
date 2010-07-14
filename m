From: Luis Correia <luis.f.correia@gmail.com>
Subject: Re: [PATCH 01/11] Removing dead RT2800PCI_SOC
Date: Wed, 14 Jul 2010 13:46:34 +0100
Message-ID: <AANLkTinO32CIe0HBTXjP_bcAz0nMEw6wvcZwcob1fX3r@mail.gmail.com>
References: <cover.1279110894.git.siccegge@cs.fau.de> <29013fb6eab9e95e95d61df894797d2455dfa10c.1279110894.git.siccegge@cs.fau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ivo van Doorn <IvDoorn@gmail.com>,
	Gertjan van Wingerde <gwingerde@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Felix Fietkau <nbd@openwrt.org>,
	Helmut Schaa <helmut.schaa@googlemail.com>,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	vamos-dev@i4.informatik.uni-erlangen.de
To: Christoph Egger <siccegge@cs.fau.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <29013fb6eab9e95e95d61df894797d2455dfa10c.1279110894.git.siccegge@cs.fau.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 14, 2010 at 13:39, Christoph Egger <siccegge@cs.fau.de> wro=
te:
> While RT2800PCI_SOC exists in Kconfig, it depends on either
> RALINK_RT288X or RALINK_RT305X which are both not available in Kconfi=
g
> so all Code depending on that can't ever be selected and, if there's
> no plan to add these options, should be cleaned up
>
> Signed-off-by: Christoph Egger <siccegge@cs.fau.de>

NAK,

this is not dead code, it is needed for the Ralink System-on-Chip
Platform devices.

While I can't fix Kconfig errors and the current KConfig file may be
wrong, this code cannot and will not be deleted.

Luis Correia
rt2x00 project admin



> ---
> =A0drivers/net/wireless/rt2x00/Kconfig =A0 =A0 | =A0 =A05 ----
> =A0drivers/net/wireless/rt2x00/rt2800pci.c | =A0 39 -----------------=
--------------
> =A02 files changed, 0 insertions(+), 44 deletions(-)
>
> diff --git a/drivers/net/wireless/rt2x00/Kconfig b/drivers/net/wirele=
ss/rt2x00/Kconfig
> index eea1ef2..d59195a 100644
> --- a/drivers/net/wireless/rt2x00/Kconfig
> +++ b/drivers/net/wireless/rt2x00/Kconfig
> @@ -58,11 +58,6 @@ config RT2800PCI_PCI
> =A0 =A0 =A0 =A0depends on PCI
> =A0 =A0 =A0 =A0default y
>
> -config RT2800PCI_SOC
> - =A0 =A0 =A0 boolean
> - =A0 =A0 =A0 depends on RALINK_RT288X || RALINK_RT305X
> - =A0 =A0 =A0 default y
> -
> =A0config RT2800PCI
> =A0 =A0 =A0 =A0tristate "Ralink rt28xx/rt30xx/rt35xx (PCI/PCIe/PCMCIA=
) support (EXPERIMENTAL)"
> =A0 =A0 =A0 =A0depends on (RT2800PCI_PCI || RT2800PCI_SOC) && EXPERIM=
ENTAL
> diff --git a/drivers/net/wireless/rt2x00/rt2800pci.c b/drivers/net/wi=
reless/rt2x00/rt2800pci.c
> index b2f2327..1445038 100644
> --- a/drivers/net/wireless/rt2x00/rt2800pci.c
> +++ b/drivers/net/wireless/rt2x00/rt2800pci.c
> @@ -85,18 +85,9 @@ static void rt2800pci_mcu_status(struct rt2x00_dev=
 *rt2x00dev, const u8 token)
> =A0 =A0 =A0 =A0rt2800_register_write(rt2x00dev, H2M_MAILBOX_CID, ~0);
> =A0}
>
> -#ifdef CONFIG_RT2800PCI_SOC
> -static void rt2800pci_read_eeprom_soc(struct rt2x00_dev *rt2x00dev)
> -{
> - =A0 =A0 =A0 u32 *base_addr =3D (u32 *) KSEG1ADDR(0x1F040000); /* XX=
X for RT3052 */
> -
> - =A0 =A0 =A0 memcpy_fromio(rt2x00dev->eeprom, base_addr, EEPROM_SIZE=
);
> -}
> -#else
> =A0static inline void rt2800pci_read_eeprom_soc(struct rt2x00_dev *rt=
2x00dev)
> =A0{
> =A0}
> -#endif /* CONFIG_RT2800PCI_SOC */
>
> =A0#ifdef CONFIG_RT2800PCI_PCI
> =A0static void rt2800pci_eepromregister_read(struct eeprom_93cx6 *eep=
rom)
> @@ -1160,25 +1151,6 @@ MODULE_DEVICE_TABLE(pci, rt2800pci_device_tabl=
e);
> =A0#endif /* CONFIG_RT2800PCI_PCI */
> =A0MODULE_LICENSE("GPL");
>
> -#ifdef CONFIG_RT2800PCI_SOC
> -static int rt2800soc_probe(struct platform_device *pdev)
> -{
> - =A0 =A0 =A0 return rt2x00soc_probe(pdev, &rt2800pci_ops);
> -}
> -
> -static struct platform_driver rt2800soc_driver =3D {
> - =A0 =A0 =A0 .driver =A0 =A0 =A0 =A0 =3D {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =A0 =A0 =A0 =A0 =A0 =3D "rt2800_w=
mac",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .owner =A0 =A0 =A0 =A0 =A0=3D THIS_MODU=
LE,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mod_name =A0 =A0 =A0 =3D KBUILD_MODNAM=
E,
> - =A0 =A0 =A0 },
> - =A0 =A0 =A0 .probe =A0 =A0 =A0 =A0 =A0=3D rt2800soc_probe,
> - =A0 =A0 =A0 .remove =A0 =A0 =A0 =A0 =3D __devexit_p(rt2x00soc_remov=
e),
> - =A0 =A0 =A0 .suspend =A0 =A0 =A0 =A0=3D rt2x00soc_suspend,
> - =A0 =A0 =A0 .resume =A0 =A0 =A0 =A0 =3D rt2x00soc_resume,
> -};
> -#endif /* CONFIG_RT2800PCI_SOC */
> -
> =A0#ifdef CONFIG_RT2800PCI_PCI
> =A0static struct pci_driver rt2800pci_driver =3D {
> =A0 =A0 =A0 =A0.name =A0 =A0 =A0 =A0 =A0 =3D KBUILD_MODNAME,
> @@ -1194,17 +1166,9 @@ static int __init rt2800pci_init(void)
> =A0{
> =A0 =A0 =A0 =A0int ret =3D 0;
>
> -#ifdef CONFIG_RT2800PCI_SOC
> - =A0 =A0 =A0 ret =3D platform_driver_register(&rt2800soc_driver);
> - =A0 =A0 =A0 if (ret)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> -#endif
> =A0#ifdef CONFIG_RT2800PCI_PCI
> =A0 =A0 =A0 =A0ret =3D pci_register_driver(&rt2800pci_driver);
> =A0 =A0 =A0 =A0if (ret) {
> -#ifdef CONFIG_RT2800PCI_SOC
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 platform_driver_unregister(&rt2800soc_d=
river);
> -#endif
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ret;
> =A0 =A0 =A0 =A0}
> =A0#endif
> @@ -1217,9 +1181,6 @@ static void __exit rt2800pci_exit(void)
> =A0#ifdef CONFIG_RT2800PCI_PCI
> =A0 =A0 =A0 =A0pci_unregister_driver(&rt2800pci_driver);
> =A0#endif
> -#ifdef CONFIG_RT2800PCI_SOC
> - =A0 =A0 =A0 platform_driver_unregister(&rt2800soc_driver);
> -#endif
> =A0}
>
> =A0module_init(rt2800pci_init);
> --
> 1.7.0.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wirel=
ess" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
