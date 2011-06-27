From: "Hennerich, Michael" <Michael.Hennerich@analog.com>
Subject: RE: [RFC 55/72] bfin_mac: Move the Blackfin driver
Date: Mon, 27 Jun 2011 19:41:52 +0100
Message-ID: <544AC56F16B56944AEC3BD4E3D5917713EA0AEEA90@LIMKCMBX1.ad.analog.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1309010363-22750-56-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"uclinux-dist-devel@blackfin.uclinux.org"
	<uclinux-dist-devel@blackfin.uclinux.org>,
	"Frysinger, Michael" <Michael.Frysinger@analog.com>,
	"Zhang, Sonic" <Sonic.Zhang@analog.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:5700 "EHLO
	TX2EHSOBE007.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753424Ab1F0SmP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 14:42:15 -0400
In-Reply-To: <1309010363-22750-56-git-send-email-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote on 2011-06-25:
> Move the Blackfin driver into drivers/net/ethernet/blackfin/ and make
> the necessary Kconfig and Makefile changes.
>
> CC: Michael Hennerich <michael.hennerich@analog.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  MAINTAINERS                                    |    2 +-
>  drivers/net/Kconfig                            |   46 ----------------
>  - drivers/net/Makefile                           |    1 -
>  drivers/net/ethernet/Kconfig                   |    1 +
>  drivers/net/ethernet/Makefile                  |    1 +
>  drivers/net/ethernet/blackfin/Kconfig          |   65
>  ++++++++++++++++++++++++ drivers/net/ethernet/blackfin/Makefile
>  |    5 ++ drivers/net/{ => ethernet/blackfin}/bfin_mac.c |    0
>  drivers/net/{ => ethernet/blackfin}/bfin_mac.h |    0 9 files changed,
>  73 insertions(+), 48 deletions(-)  create mode 100644
>  drivers/net/ethernet/blackfin/Kconfig create mode 100644
>  drivers/net/ethernet/blackfin/Makefile rename drivers/net/{ =>
>  ethernet/blackfin}/bfin_mac.c (100%)  rename
> drivers/net/{ => ethernet/blackfin}/bfin_mac.h (100%)


Hi Jeff,

I'm no longer maintaining this driver, please use the MAINTAINERS L(ist): entry instead.
We'll update the MAINTAINERS entry shortly.

This patch looks good to me. I really don't have a preference blackfin/ sounds good
for the time being, but /adi might be more future proof.

I'll ACK this one and add the list, maybe someone else wants to comment, too.

Acked-by: Michael Hennerich <michael.hennerich@analog.com>

Greetings,
Michael

--
Analog Devices GmbH      Wilhelm-Wagenfeld-Str. 6      80807 Muenchen
Sitz der Gesellschaft: Muenchen; Registergericht: Muenchen HRB 40368; Geschaeftsfuehrer:Dr.Carsten Suckrow, Thomas Wessel, William A. Martin, Margaret Seif


>
> diff --git a/MAINTAINERS b/MAINTAINERS index 53e2d11..506d4d0 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -1426,7 +1426,7 @@ M:      Michael Hennerich
> <michael.hennerich@analog.com>
>  L:   uclinux-dist-devel@blackfin.uclinux.org
>  W:   http://blackfin.uclinux.org S:  Supported
> -F:   drivers/net/bfin_mac.*
> +F:   drivers/net/ethernet/blackfin/
>
>  BLACKFIN RTC DRIVER
>  M:   Mike Frysinger <vapier.adi@gmail.com>
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig index
> 29eca29..9709106 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -250,52 +250,6 @@ config SH_ETH
>         This driver supporting CPUs are:
>               - SH7710, SH7712, SH7763, SH7619, SH7724, and SH7757.
> -config BFIN_MAC -    tristate "Blackfin on-chip MAC support" -       depends on
> NET_ETHERNET && (BF516 || BF518 || BF526 || BF527 || BF536 || BF537)
> -     select CRC32 -  select MII -    select PHYLIB - select BFIN_MAC_USE_L1 if
> DMA_UNCACHED_NONE -   help -    This is the driver for Blackfin on-chip mac
> device. Say Y if you want it -          compiled into the kernel. This driver
> is also available as a module -         ( = code which can be inserted in and
> removed from the running kernel -       whenever you want). The module will
> be called bfin_mac. - -config BFIN_MAC_USE_L1 -       bool "Use L1 memory for
> rx/tx packets" -      depends on BFIN_MAC && (BF527 || BF537) -       default y
> -     help -    To get maximum network performance, you should use L1 memory
> as rx/tx buffers. -     Say N here if you want to reserve L1 memory for
> other uses. - -config BFIN_TX_DESC_NUM -      int "Number of transmit buffer
> packets" -    depends on BFIN_MAC -   range 6 10 if BFIN_MAC_USE_L1 - range
> 10 100 -      default "10" -  help -    Set the number of buffer packets used
> in driver. - -config BFIN_RX_DESC_NUM -       int "Number of receive buffer
> packets" -    depends on BFIN_MAC -   range 20 100 if BFIN_MAC_USE_L1 -       range
> 20 800 -      default "20" -  help -    Set the number of buffer packets used
> in driver. - -config BFIN_MAC_USE_HWSTAMP -   bool "Use IEEE 1588 hwstamp"
> -     depends on BFIN_MAC && BF518 -  default y -     help -    To support the
> IEEE 1588 Precision Time Protocol (PTP), select y here -
>  config NET_NETX
>       tristate "NetX Ethernet support"
>       select MII
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile index
> 4315328..5c189ab 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -62,7 +62,6 @@ obj-$(CONFIG_EQUALIZER) += eql.o
>  obj-$(CONFIG_TUN) += tun.o obj-$(CONFIG_VETH) += veth.o
>  obj-$(CONFIG_NET_NETX) += netx-eth.o -obj-$(CONFIG_BFIN_MAC) +=
>  bfin_mac.o obj-$(CONFIG_DM9000) += dm9000.o obj-$(CONFIG_ENC28J60) +=
>  enc28j60.o obj-$(CONFIG_ETHOC) += ethoc.o
> diff --git a/drivers/net/ethernet/Kconfig
> b/drivers/net/ethernet/Kconfig index ef622d2..fede911 100644
> --- a/drivers/net/ethernet/Kconfig
> +++ b/drivers/net/ethernet/Kconfig
> @@ -39,6 +39,7 @@ config ARIADNE
>
>  source "drivers/net/ethernet/arm/Kconfig" source
>  "drivers/net/ethernet/atheros/Kconfig" +source
>  "drivers/net/ethernet/blackfin/Kconfig" source
>  "drivers/net/ethernet/broadcom/Kconfig" source
>  "drivers/net/ethernet/brocade/Kconfig" source
>  "drivers/net/ethernet/chelsio/Kconfig"
> diff --git a/drivers/net/ethernet/Makefile
> b/drivers/net/ethernet/Makefile index 1ab5f1f..b8cc6ef 100644
> --- a/drivers/net/ethernet/Makefile
> +++ b/drivers/net/ethernet/Makefile
> @@ -10,6 +10,7 @@ obj-$(CONFIG_NET_VENDOR_APPLE) += apple/
>  obj-$(CONFIG_ARIADNE) += ariadne.o obj-$(CONFIG_NET_ARM) += arm/
>  obj-$(CONFIG_NET_VENDOR_ATHEROS) += atheros/ +obj-$(CONFIG_NET_BFIN) +=
>  blackfin/ obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
>  obj-$(CONFIG_NET_VENDOR_BROCADE) += brocade/
>  obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/ diff --git
 a/drivers/net/ethernet/blackfin/Kconfig
 b/drivers/net/ethernet/blackfin/Kconfig new file mode 100644 index
 0000000..a2c8a3b --- /dev/null +++
 b/drivers/net/ethernet/blackfin/Kconfig @@ -0,0 +1,65 @@ +# +# Blackfin
 device configuration +# + +config NET_BFIN +   bool "Blackfin devices"
 +      depends on BF516 || BF518 || BF526 || BF527 || BF536 || BF537
 +      ---help--- +      If you have a network (Ethernet) card belonging to this
 class, say Y. +          Make sure you know the name of your card. Read the
 Ethernet- HOWTO, +       available from
 <http://www.tldp.org/docs.html#howto>. + +       If unsure, say Y. + +   Note
 that the answer to this question doesn't directly affect the +   kernel:
 saying N will just cause the configurator to skip all +          the remaining
 Blackfin card questions. If you say Y, you will be +     asked for your
 specific card in the following questions. + +config BFIN_MAC + tristate
 "Blackfin on-chip MAC support" +       depends on NET_BFIN && (BF516 || BF518
 || BF526 || BF527 || \ +                BF536 || BF537) +      select CRC32 +  select MII
 +      select PHYLIB + select BFIN_MAC_USE_L1 if DMA_UNCACHED_NONE
 +      ---help--- +      This is the driver for Blackfin on-chip mac device. Say
 Y if you want +          it compiled into the kernel. This driver is also
 available as a +         module ( = code which can be inserted in and removed
 from the running +       kernel whenever you want). The module will be called
 bfin_mac. + +config BFIN_MAC_USE_L1 +  bool "Use L1 memory for rx/tx
 packets" +     depends on BFIN_MAC && (BF527 || BF537) +       default y
 +      ---help--- +      To get maximum network performance, you should use L1
 memory as rx/tx +        buffers. Say N here if you want to reserve L1 memory
 for other uses. + +config BFIN_TX_DESC_NUM +   int "Number of transmit
 buffer packets" +      depends on BFIN_MAC +   range 6 10 if BFIN_MAC_USE_L1
 +      range 10 100 +  default "10" +  ---help--- +      Set the number of buffer
 packets used in driver. + +config BFIN_RX_DESC_NUM +   int "Number of
 receive buffer packets" +      depends on BFIN_MAC +   range 20 100 if
 BFIN_MAC_USE_L1 +      range 20 800 +  default "20" +  ---help--- +      Set the
 number of buffer packets used in driver. + +config BFIN_MAC_USE_HWSTAMP
 +      bool "Use IEEE 1588 hwstamp" +  depends on BFIN_MAC && BF518 +  default y
 +      ---help--- +      To support the IEEE 1588 Precision Time Protocol (PTP),
 select y +here diff --git a/drivers/net/ethernet/blackfin/Makefile
 b/drivers/net/ethernet/blackfin/Makefile new file mode 100644 index
 0000000..b1fbe19 --- /dev/null +++
 b/drivers/net/ethernet/blackfin/Makefile @@ -0,0 +1,5 @@ +# +# Makefile
 for the Blackfin device drivers. +# + +obj-$(CONFIG_BFIN_MAC) +=
 bfin_mac.o diff --git a/drivers/net/bfin_mac.c
 b/drivers/net/ethernet/blackfin/bfin_mac.c similarity index 100% rename
 from drivers/net/bfin_mac.c rename to
 drivers/net/ethernet/blackfin/bfin_mac.c diff --git
 a/drivers/net/bfin_mac.h b/drivers/net/ethernet/blackfin/bfin_mac.h
 similarity index 100% rename from drivers/net/bfin_mac.h rename to
 drivers/net/ethernet/blackfin/bfin_mac.h

Greetings,
Michael

--
Analog Devices GmbH      Wilhelm-Wagenfeld-Str. 6      80807 Muenchen
Sitz der Gesellschaft: Muenchen; Registergericht: Muenchen HRB 40368; Geschaeftsfuehrer:Dr.Carsten Suckrow, Thomas Wessel, William A. Martin, Margaret Seif



