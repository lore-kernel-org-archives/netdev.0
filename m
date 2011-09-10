From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -next] drivers/net: Makefile, fix netconsole link order
Date: Fri, 9 Sep 2011 17:00:27 -0700
Message-ID: <20110909170027.c4bf6151.akpm@linux-foundation.org>
References: <1315298129.16061.24.camel@snb>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Lin Ming <ming.m.lin@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37179 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753249Ab1IJAAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2011 20:00:30 -0400
In-Reply-To: <1315298129.16061.24.camel@snb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 06 Sep 2011 16:35:29 +0800
Lin Ming <ming.m.lin@intel.com> wrote:

> Commit 88491d8(drivers/net: Kconfig & Makefile cleanup) causes a
> regression that netconsole does not work if netconsole and network
> device driver are build into kernel, because netconsole is linked before
> network device driver.
> 
> Fixes it by moving netconsole.o after network device driver.
> 
> Signed-off-by: Lin Ming <ming.m.lin@intel.com>
> ---
>  drivers/net/Makefile |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index fa877cd..ec15311 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -14,7 +14,6 @@ obj-$(CONFIG_MACVTAP) += macvtap.o
>  obj-$(CONFIG_MII) += mii.o
>  obj-$(CONFIG_MDIO) += mdio.o
>  obj-$(CONFIG_NET) += Space.o loopback.o
> -obj-$(CONFIG_NETCONSOLE) += netconsole.o
>  obj-$(CONFIG_PHYLIB) += phy/
>  obj-$(CONFIG_RIONET) += rionet.o
>  obj-$(CONFIG_TUN) += tun.o
> @@ -66,3 +65,9 @@ obj-$(CONFIG_USB_USBNET)        += usb/
>  obj-$(CONFIG_USB_ZD1201)        += usb/
>  obj-$(CONFIG_USB_IPHETH)        += usb/
>  obj-$(CONFIG_USB_CDC_PHONET)   += usb/
> +
> +#
> +# If netconsole and network device driver are build-in,
> +# netconsole must be linked after network device driver
> +#
> +obj-$(CONFIG_NETCONSOLE) += netconsole.o

It would be preferable to fix this with initcall ordering.  Perhaps by
switching init_netconsole() to subsys_initcall.
