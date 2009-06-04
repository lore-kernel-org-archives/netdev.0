From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq@rere.qmqm.pl>
Subject: Re: [PATCH 1/3] forcedeth: remove device id macros
Date: Thu, 4 Jun 2009 13:46:42 +0200
Message-ID: <20090604114642.GA26217@rere.qmqm.pl>
References: <4A271DCD.3080903@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Manfred Spraul <manfred@colorfullife.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:59780 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752081AbZFDLxH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2009 07:53:07 -0400
Content-Disposition: inline
In-Reply-To: <4A271DCD.3080903@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wed, Jun 03, 2009 at 09:05:17PM -0400, Ayaz Abdulla wrote:
> This patch removes the device id macros and instead uses the constant=
s =20
> directly.
>
> The areas in which logic expressions where using the macros now inste=
ad =20
> use feature/workaround flags.
>
> No new functionality has been introduced in this patch, only clean up=
 of =20
> flags and macros.
>
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

> --- old/drivers/net/forcedeth.c	2009-06-03 20:38:59.000000000 -0400
> +++ new/drivers/net/forcedeth.c	2009-06-03 20:39:02.000000000 -0400
[...]
> @@ -6158,7 +6140,8 @@
>  	for (i =3D 0;i <=3D np->register_size/sizeof(u32); i++)
>  		writel(np->saved_config_space[i], base+i*sizeof(u32));
> =20
> -	pci_write_config_dword(pdev, NV_MSI_PRIV_OFFSET, NV_MSI_PRIV_VALUE)=
;
> +	if (np->driver_data & DEV_NEED_MSI_FIX)
> +		pci_write_config_dword(pdev, NV_MSI_PRIV_OFFSET, NV_MSI_PRIV_VALUE=
);
> =20
>  	/* restore phy state, including autoneg */
>  	phy_init(dev);

This fragment actually changes logic despite patch description.

> @@ -6207,160 +6190,160 @@
> =20
>  static struct pci_device_id pci_tbl[] =3D {
>  	{	/* nForce Ethernet Controller */
> -		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_1),
> +		PCI_DEVICE(0x10DE, 0x01C3),
>  		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
>  	},
[cut]

The PCI device ID constants have probably no real meaning, but why also
remove vendor ID constants?

Best Regards,
Micha=B3 Miros=B3aw
