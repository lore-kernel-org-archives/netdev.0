From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] fix netxen_pci_tbl[] breakage
Date: Fri, 27 Jun 2008 01:33:00 -0400
Message-ID: <48647B8C.6050007@pobox.com>
References: <20080623010450.GV28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dhananjay Phadke <dhananjay@netxen.com>, netdev@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56697 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753480AbYF0FdG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 01:33:06 -0400
In-Reply-To: <20080623010450.GV28946@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Al Viro wrote:
> 	PCI_DEVICE_CLASS sets .device and .vendor to PCI_ANY_DEV,
> which overrides the effect of preceding PCI_DEVICE() and makes
> all elements of netxen_pci_tbl[] identical.  Introduced in the
> commit dcd56fdbaeae1008044687b973c4a3e852e8a726.
> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> ---
> diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
> index 6797ed0..63cd67b 100644
> --- a/drivers/net/netxen/netxen_nic_main.c
> +++ b/drivers/net/netxen/netxen_nic_main.c
> @@ -71,14 +71,18 @@ static irqreturn_t netxen_intr(int irq, void *data);
>  static irqreturn_t netxen_msi_intr(int irq, void *data);
>  
>  /*  PCI Device ID Table  */
> +#define ENTRY(device) \
> +	{PCI_DEVICE(0x4040, (device)), \
> +	.class = PCI_CLASS_NETWORK_ETHERNET << 8, .class_mask = ~0}
> +
>  static struct pci_device_id netxen_pci_tbl[] __devinitdata = {
> -	{PCI_DEVICE(0x4040, 0x0001), PCI_DEVICE_CLASS(0x020000, ~0)},
> -	{PCI_DEVICE(0x4040, 0x0002), PCI_DEVICE_CLASS(0x020000, ~0)},
> -	{PCI_DEVICE(0x4040, 0x0003), PCI_DEVICE_CLASS(0x020000, ~0)},
> -	{PCI_DEVICE(0x4040, 0x0004), PCI_DEVICE_CLASS(0x020000, ~0)},
> -	{PCI_DEVICE(0x4040, 0x0005), PCI_DEVICE_CLASS(0x020000, ~0)},
> -	{PCI_DEVICE(0x4040, 0x0024), PCI_DEVICE_CLASS(0x020000, ~0)},
> -	{PCI_DEVICE(0x4040, 0x0025), PCI_DEVICE_CLASS(0x020000, ~0)},
> +	ENTRY(0x0001),
> +	ENTRY(0x0002),
> +	ENTRY(0x0003),
> +	ENTRY(0x0004),
> +	ENTRY(0x0005),
> +	ENTRY(0x0024),
> +	ENTRY(0x0025),
>  	{0,}
>  };

applied


