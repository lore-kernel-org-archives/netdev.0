From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH net-next 1/2] 6lowpan: introduce new net/6lowpan directory
Date: Fri, 11 Jul 2014 13:23:52 +0200
Message-ID: <8A1EF84C-3EDC-4540-B8F4-1FCBF4BF8D93@holtmann.org>
References: <1405067059-18782-1-git-send-email-alex.aring@gmail.com> <1405067059-18782-2-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, jukka.rissanen@linux.intel.com,
	linux-zigbee-devel@lists.sourceforge.net,
	linux-bluetooth@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:54770 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbaGKLXw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 07:23:52 -0400
In-Reply-To: <1405067059-18782-2-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexander,

> This patch moves generic code which is used by bluetooth and ieee802154
> 6lowpan to a new net/6lowpan directory. This directory contains generic
> 6LoWPAN code which is shared between bluetooth and ieee802154 MAC-Layer.
> 
> This is the IPHC - "IPv6 Header Compression" format at the moment. Which
> is described by RFC 6282 [0]. The BLTE 6LoWPAN draft describes that the
> IPHC is the same format like IEEE 802.15.4, see [1].
> 
> Futuremore we can put more code into this directory which is shared
> between BLTE and IEEE 802.15.4 6LoWPAN like RFC 6775 or the routing
> protocol RPL RFC 6550.
> 
> To avoid naming conflicts I renamed 6lowpan-y to ieee802154_6lowpan-y
> in net/ieee802154/Makefile.
> 
> [0] http://tools.ietf.org/html/rfc6282
> [1] http://tools.ietf.org/html/draft-ietf-6lowpan-btle-12#section-3.2
> [2] http://tools.ietf.org/html/rfc6775
> [3] http://tools.ietf.org/html/rfc6550
> 
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> ---
> net/6lowpan/Kconfig                               | 6 ++++++
> net/6lowpan/Makefile                              | 3 +++
> net/{ieee802154/6lowpan_iphc.c => 6lowpan/iphc.c} | 0
> net/Kconfig                                       | 1 +
> net/Makefile                                      | 3 ++-
> net/bluetooth/Kconfig                             | 3 +--
> net/ieee802154/Kconfig                            | 9 +--------
> net/ieee802154/Makefile                           | 5 ++---
> 8 files changed, 16 insertions(+), 14 deletions(-)
> create mode 100644 net/6lowpan/Kconfig
> create mode 100644 net/6lowpan/Makefile
> rename net/{ieee802154/6lowpan_iphc.c => 6lowpan/iphc.c} (100%)
> 
> diff --git a/net/6lowpan/Kconfig b/net/6lowpan/Kconfig
> new file mode 100644
> index 0000000..028a5c6
> --- /dev/null
> +++ b/net/6lowpan/Kconfig
> @@ -0,0 +1,6 @@
> +config 6LOWPAN
> +	bool "6LoWPAN Support"
> +	depends on IPV6
> +	---help---
> +	  This enables IPv6 over Low power Wireless Personal Area Network -
> +	  "6LoWPAN" which is supported by IEEE 802.15.4 or Bluetooth stacks.
> diff --git a/net/6lowpan/Makefile b/net/6lowpan/Makefile
> new file mode 100644
> index 0000000..415886b
> --- /dev/null
> +++ b/net/6lowpan/Makefile
> @@ -0,0 +1,3 @@
> +obj-$(CONFIG_6LOWPAN) := 6lowpan.o
> +
> +6lowpan-y := iphc.o
> diff --git a/net/ieee802154/6lowpan_iphc.c b/net/6lowpan/iphc.c
> similarity index 100%
> rename from net/ieee802154/6lowpan_iphc.c
> rename to net/6lowpan/iphc.c
> diff --git a/net/Kconfig b/net/Kconfig
> index d92afe4..4051fdf 100644
> --- a/net/Kconfig
> +++ b/net/Kconfig
> @@ -214,6 +214,7 @@ source "drivers/net/appletalk/Kconfig"
> source "net/x25/Kconfig"
> source "net/lapb/Kconfig"
> source "net/phonet/Kconfig"
> +source "net/6lowpan/Kconfig"
> source "net/ieee802154/Kconfig"
> source "net/mac802154/Kconfig"
> source "net/sched/Kconfig"
> diff --git a/net/Makefile b/net/Makefile
> index cbbbe6d..7ed1970 100644
> --- a/net/Makefile
> +++ b/net/Makefile
> @@ -57,7 +57,8 @@ obj-$(CONFIG_CAIF)		+= caif/
> ifneq ($(CONFIG_DCB),)
> obj-y				+= dcb/
> endif
> -obj-y				+= ieee802154/
> +obj-$(CONFIG_6LOWPAN)		+= 6lowpan/
> +obj-$(CONFIG_IEEE802154)	+= ieee802154/
> obj-$(CONFIG_MAC802154)		+= mac802154/
> 
> ifeq ($(CONFIG_NET),y)
> diff --git a/net/bluetooth/Kconfig b/net/bluetooth/Kconfig
> index 06ec144..a54777d 100644
> --- a/net/bluetooth/Kconfig
> +++ b/net/bluetooth/Kconfig
> @@ -6,7 +6,6 @@ menuconfig BT
> 	tristate "Bluetooth subsystem support"
> 	depends on NET && !S390
> 	depends on RFKILL || !RFKILL
> -	select 6LOWPAN_IPHC if BT_6LOWPAN
> 	select CRC16
> 	select CRYPTO
> 	select CRYPTO_BLKCIPHER
> @@ -42,7 +41,7 @@ menuconfig BT
> 
> config BT_6LOWPAN
> 	bool "Bluetooth 6LoWPAN support"
> -	depends on BT && IPV6
> +	depends on BT && 6LOWPAN
> 	help
> 	  IPv6 compression over Bluetooth.

this will conflict with our changes in wireless-next tree. We converted out 6LoWPAN support into a separate module.

Dave, can we take this through bluetooth-next and wireless-next trees?

Regards

Marcel
