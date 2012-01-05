From: Gertjan van Wingerde <gwingerde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] drivers: net: Fix dependency for EEPROM_93CX6
Date: Thu, 5 Jan 2012 13:33:25 +0100
Message-ID: <CAL1gcdOrr41Br1Z-JCih6BGdxLmZ9ns+W-cVRxvd+guO2xC_zQ@mail.gmail.com>
References: <1325765663-7141-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	Fabio Estevam <fabio.estevam-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: Fabio Estevam <festevam-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1325765663-7141-1-git-send-email-festevam-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 5, 2012 at 1:14 PM, Fabio Estevam <festevam-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrot=
e:
> Fix the following build warning:
>
> warning: (KS8851 && AX88796_93CX6 && RTL8180 && RTL8187 && ADM8211 &&=
 RT2400PCI && RT2500PCI && RT61PCI && RT2800PCI && R8187SE) selects EEP=
ROM_93CX6 which has unmet direct dependencies (MISC_DEVICES)
>
> Signed-off-by: Fabio Estevam <fabio.estevam-KZfg59tc24xl57MIdRCFDg@public.gmane.org>

NAK, at least for the rt2x00 part, but probably for the other parts as =
well.
The rt2x00 drivers actually need the EEPROM_93CX6 driver to be
present, otherwise they won't work correctly. Therefore only selecting
the symbol when MISC_DEVICES has been enabled can lead to a
non-functional configuration for the rt2x00 devices.

A correct fix would be to also select MISC_DEVICES at all locations
where EEPROM_93CX6 is selected.

---
Gertjan.

> ---
> =A0drivers/net/ethernet/8390/Kconfig =A0 =A0| =A0 =A02 +-
> =A0drivers/net/ethernet/micrel/Kconfig =A0| =A0 =A03 +--
> =A0drivers/net/wireless/Kconfig =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A0drivers/net/wireless/rt2x00/Kconfig =A0| =A0 =A08 ++++----
> =A0drivers/net/wireless/rtl818x/Kconfig | =A0 =A04 ++--
> =A05 files changed, 9 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/net/ethernet/8390/Kconfig b/drivers/net/ethernet=
/8390/Kconfig
> index e04ade4..d967c74 100644
> --- a/drivers/net/ethernet/8390/Kconfig
> +++ b/drivers/net/ethernet/8390/Kconfig
> @@ -69,7 +69,7 @@ config AX88796
> =A0config AX88796_93CX6
> =A0 =A0 =A0 =A0bool "ASIX AX88796 external 93CX6 eeprom support"
> =A0 =A0 =A0 =A0depends on AX88796
> - =A0 =A0 =A0 select EEPROM_93CX6
> + =A0 =A0 =A0 select EEPROM_93CX6 if MISC_DEVICES
> =A0 =A0 =A0 =A0---help---
> =A0 =A0 =A0 =A0 =A0Select this if your platform comes with an externa=
l 93CX6 eeprom.
>
> diff --git a/drivers/net/ethernet/micrel/Kconfig b/drivers/net/ethern=
et/micrel/Kconfig
> index 1ea811c..bc99abf 100644
> --- a/drivers/net/ethernet/micrel/Kconfig
> +++ b/drivers/net/ethernet/micrel/Kconfig
> @@ -42,8 +42,7 @@ config KS8851
> =A0 =A0 =A0 =A0select NET_CORE
> =A0 =A0 =A0 =A0select MII
> =A0 =A0 =A0 =A0select CRC32
> - =A0 =A0 =A0 select MISC_DEVICES
> - =A0 =A0 =A0 select EEPROM_93CX6
> + =A0 =A0 =A0 select EEPROM_93CX6 if MISC_DEVICES
> =A0 =A0 =A0 =A0---help---
> =A0 =A0 =A0 =A0 =A0SPI driver for Micrel KS8851 SPI attached network =
chip.
>
> diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kcon=
fig
> index abd3b71..d15d3a9 100644
> --- a/drivers/net/wireless/Kconfig
> +++ b/drivers/net/wireless/Kconfig
> @@ -223,7 +223,7 @@ config ADM8211
> =A0 =A0 =A0 =A0tristate "ADMtek ADM8211 support"
> =A0 =A0 =A0 =A0depends on MAC80211 && PCI && EXPERIMENTAL
> =A0 =A0 =A0 =A0select CRC32
> - =A0 =A0 =A0 select EEPROM_93CX6
> + =A0 =A0 =A0 select EEPROM_93CX6 if MISC_DEVICES
> =A0 =A0 =A0 =A0---help---
> =A0 =A0 =A0 =A0 =A0This driver is for ADM8211A, ADM8211B, and ADM8211=
C based cards.
> =A0 =A0 =A0 =A0 =A0These are PCI/mini-PCI/Cardbus 802.11b chips found=
 in cards such as:
> diff --git a/drivers/net/wireless/rt2x00/Kconfig b/drivers/net/wirele=
ss/rt2x00/Kconfig
> index a0a7854..c7be1a9 100644
> --- a/drivers/net/wireless/rt2x00/Kconfig
> +++ b/drivers/net/wireless/rt2x00/Kconfig
> @@ -21,7 +21,7 @@ config RT2400PCI
> =A0 =A0 =A0 =A0tristate "Ralink rt2400 (PCI/PCMCIA) support"
> =A0 =A0 =A0 =A0depends on PCI
> =A0 =A0 =A0 =A0select RT2X00_LIB_PCI
> - =A0 =A0 =A0 select EEPROM_93CX6
> + =A0 =A0 =A0 select EEPROM_93CX6 if MISC_DEVICES
> =A0 =A0 =A0 =A0---help---
> =A0 =A0 =A0 =A0 =A0This adds support for rt2400 wireless chipset fami=
ly.
> =A0 =A0 =A0 =A0 =A0Supported chips: RT2460.
> @@ -32,7 +32,7 @@ config RT2500PCI
> =A0 =A0 =A0 =A0tristate "Ralink rt2500 (PCI/PCMCIA) support"
> =A0 =A0 =A0 =A0depends on PCI
> =A0 =A0 =A0 =A0select RT2X00_LIB_PCI
> - =A0 =A0 =A0 select EEPROM_93CX6
> + =A0 =A0 =A0 select EEPROM_93CX6 if MISC_DEVICES
> =A0 =A0 =A0 =A0---help---
> =A0 =A0 =A0 =A0 =A0This adds support for rt2500 wireless chipset fami=
ly.
> =A0 =A0 =A0 =A0 =A0Supported chips: RT2560.
> @@ -46,7 +46,7 @@ config RT61PCI
> =A0 =A0 =A0 =A0select RT2X00_LIB_FIRMWARE
> =A0 =A0 =A0 =A0select RT2X00_LIB_CRYPTO
> =A0 =A0 =A0 =A0select CRC_ITU_T
> - =A0 =A0 =A0 select EEPROM_93CX6
> + =A0 =A0 =A0 select EEPROM_93CX6 if MISC_DEVICES
> =A0 =A0 =A0 =A0---help---
> =A0 =A0 =A0 =A0 =A0This adds support for rt2501 wireless chipset fami=
ly.
> =A0 =A0 =A0 =A0 =A0Supported chips: RT2561, RT2561S & RT2661.
> @@ -62,7 +62,7 @@ config RT2800PCI
> =A0 =A0 =A0 =A0select RT2X00_LIB_FIRMWARE
> =A0 =A0 =A0 =A0select RT2X00_LIB_CRYPTO
> =A0 =A0 =A0 =A0select CRC_CCITT
> - =A0 =A0 =A0 select EEPROM_93CX6
> + =A0 =A0 =A0 select EEPROM_93CX6 if MISC_DEVICES
> =A0 =A0 =A0 =A0---help---
> =A0 =A0 =A0 =A0 =A0This adds support for rt27xx/rt28xx/rt30xx wireles=
s chipset family.
> =A0 =A0 =A0 =A0 =A0Supported chips: RT2760, RT2790, RT2860, RT2880, R=
T2890, RT3052,
> diff --git a/drivers/net/wireless/rtl818x/Kconfig b/drivers/net/wirel=
ess/rtl818x/Kconfig
> index 17d80fe..3e399b8 100644
> --- a/drivers/net/wireless/rtl818x/Kconfig
> +++ b/drivers/net/wireless/rtl818x/Kconfig
> @@ -4,7 +4,7 @@
> =A0config RTL8180
> =A0 =A0 =A0 =A0tristate "Realtek 8180/8185 PCI support"
> =A0 =A0 =A0 =A0depends on MAC80211 && PCI && EXPERIMENTAL
> - =A0 =A0 =A0 select EEPROM_93CX6
> + =A0 =A0 =A0 select EEPROM_93CX6 if MISC_DEVICES
> =A0 =A0 =A0 =A0---help---
> =A0 =A0 =A0 =A0 =A0This is a driver for RTL8180 and RTL8185 based car=
ds.
> =A0 =A0 =A0 =A0 =A0These are PCI based chips found in cards such as:
> @@ -60,7 +60,7 @@ config RTL8180
> =A0config RTL8187
> =A0 =A0 =A0 =A0tristate "Realtek 8187 and 8187B USB support"
> =A0 =A0 =A0 =A0depends on MAC80211 && USB
> - =A0 =A0 =A0 select EEPROM_93CX6
> + =A0 =A0 =A0 select EEPROM_93CX6 if MISC_DEVICES
> =A0 =A0 =A0 =A0---help---
> =A0 =A0 =A0 =A0 =A0This is a driver for RTL8187 and RTL8187B based ca=
rds.
> =A0 =A0 =A0 =A0 =A0These are USB based chips found in devices such as=
:
> --
> 1.7.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html



--=20
---
Gertjan
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
