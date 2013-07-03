From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH RFC 2/3] Introduce huawei_cdc_ncm driver
Date: Wed, 03 Jul 2013 09:40:08 +0200
Message-ID: <87ehbgw0pz.fsf@nemi.mork.no>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso>
	<87wqp9xja5.fsf@nemi.mork.no>
	<alpine.LNX.2.02.1307021855270.19053@eeeadesso>
	<alpine.LNX.2.02.1307022202570.26010@eeeadesso>
	<alpine.LNX.2.02.1307022207060.26010@eeeadesso>
	<alpine.LNX.2.02.1307022210470.26010@eeeadesso>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:51715 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754228Ab3GCHkN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 03:40:13 -0400
In-Reply-To: <alpine.LNX.2.02.1307022210470.26010@eeeadesso> (Enrico Mioso's
	message of "Tue, 2 Jul 2013 22:13:29 +0200 (CEST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enrico Mioso <mrkiko.rs@gmail.com> writes:

> This patch, introduce the huawei_cdc_ncm driver, modifying the build=20
> infrastructure as needed.
>
> Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>
>
>
> diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
> index 287cc62..33cb175 100644
> --- a/drivers/net/usb/Kconfig
> +++ b/drivers/net/usb/Kconfig
> @@ -246,6 +246,18 @@ config USB_NET_CDC_NCM
>  	    * ST-Ericsson M343 HSPA Mobile Broadband Modem (reference desig=
n)
>  	    * Ericsson F5521gw Mobile Broadband Module
> =20
> +config USB_NET_HUAWEI_CDC_NCM
> +	tristate "Huawei-style CDC NCM support"
> +	depends on USB_USBNET
> +	default y
> +	select USB_WDM
> +	select USB_NET_CDC_NCM
> +	help
> +		This driver aims to support huawei-style NCM devices, that use ncm=
 as a=20
> +		transport for other protols.
> +		To compile this driver as a module, choose M here: the module will=
 be=20
> +		called huawei_cdc_ncm.
> +
>  config USB_NET_CDC_MBIM
>  	tristate "CDC MBIM support"
>  	depends on USB_USBNET
> diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
> index 9ab5c9d..12a0279 100644
> --- a/drivers/net/usb/Makefile
> +++ b/drivers/net/usb/Makefile
> @@ -31,6 +31,7 @@ obj-$(CONFIG_USB_IPHETH)	+=3D ipheth.o
>  obj-$(CONFIG_USB_SIERRA_NET)	+=3D sierra_net.o
>  obj-$(CONFIG_USB_NET_CX82310_ETH)	+=3D cx82310_eth.o
>  obj-$(CONFIG_USB_NET_CDC_NCM)	+=3D cdc_ncm.o
> +obj-$(CONFIG_USB_NET_HUAWEI_CDC_NCM)	+=3D huawei_cdc_ncm.o
>  obj-$(CONFIG_USB_VL600)		+=3D lg-vl600.o
>  obj-$(CONFIG_USB_NET_QMI_WWAN)	+=3D qmi_wwan.o
>  obj-$(CONFIG_USB_NET_CDC_MBIM)	+=3D cdc_mbim.o


This patch must come last or you break the build here.  Every single
point in the git history must build to ensure bisectability.


Bj=C3=B8rn
