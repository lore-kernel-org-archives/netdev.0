From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 4/6 Linux-2.6.7-bk13] prism54 device list cleanup
Date: Wed, 30 Jun 2004 16:18:41 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40E32021.6040800@pobox.com>
References: <200406301941.19873.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Margit Schubert-While <margitsw@t-online.de>
In-Reply-To: <200406301941.19873.margitsw@t-online.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Margit Schubert-While wrote:
> 2004-06-28 Margit Schubert-While <margitsw@t-online.de>
> 
> * Clean up the device table
> 
> 
> ------------------------------------------------------------------------
> 
> diff -Naur linux-2.6.7-01/drivers/net/wireless/prism54/islpci_hotplug.c linux-2.6.7-02/drivers/net/wireless/prism54/islpci_hotplug.c
> --- linux-2.6.7-01/drivers/net/wireless/prism54/islpci_hotplug.c	2004-06-25 19:48:40.000000000 +0200
> +++ linux-2.6.7-02/drivers/net/wireless/prism54/islpci_hotplug.c	2004-06-25 20:14:46.000000000 +0200
> @@ -38,81 +38,111 @@
>  
>  /* In this order: vendor, device, subvendor, subdevice, class, class_mask,
>   * driver_data 
> - * Note: for driver_data we put the device's name 
>   * If you have an update for this please contact prism54-devel@prism54.org 
>   * The latest list can be found at http://prism54.org/supported_cards.php */
>  static const struct pci_device_id prism54_id_tbl[] = {
> +	/* 3COM 3CRWE154G72 Wireless LAN adapter */
>  	{
>  	 PCIVENDOR_3COM, PCIDEVICE_3COM6001,
>  	 PCIVENDOR_3COM, PCIDEVICE_3COM6001,
> -	 0, 0,
> -	 (unsigned long) "3COM 3CRWE154G72 Wireless LAN adapter"},
> +	 0, 0, 0
> +	},
> +
> +	/* D-Link Air Plus Xtreme G A1 - DWL-g650 A1 */
>  	{
>  	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
>  	 PCIVENDOR_DLINK, 0x3202UL, 
> -	 0, 0,
> -	 (unsigned long) "D-Link Air Plus Xtreme G A1 - DWL-g650 A1"},
> +	 0, 0, 0
> +	},


Patch is OK, but two comments:

1) use standard constants from include/linux/pci_ids.h, not your own

2) where possible, use PCI_ANY_ID for subvendor id and subdevice id. 
Experience shows that unless the subvendor/subdevice is absolutely 
required, it should not be specified.
