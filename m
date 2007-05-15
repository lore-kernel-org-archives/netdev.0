From: wendy xiong <wendyx@us.ibm.com>
Subject: Re: [patch 1/1] icom: Add new sub-device-id to support new adapter
Date: Tue, 15 May 2007 11:29:15 -0500
Message-ID: <1179246555.18147.128.camel@wendyx.austin.ibm.com>
References: <1178750192.18147.111.camel@wendyx.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:45675 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757343AbXEOQ3R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2007 12:29:17 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4FGTGfW005900
	for <netdev@vger.kernel.org>; Tue, 15 May 2007 12:29:17 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4FGTH8n502658
	for <netdev@vger.kernel.org>; Tue, 15 May 2007 12:29:17 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4FGTGFm029840
	for <netdev@vger.kernel.org>; Tue, 15 May 2007 12:29:16 -0400
In-Reply-To: <1178750192.18147.111.camel@wendyx.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

I have tested this with new adapter on our systems. I didn't get
comments since I sent out last Wednesday.

Could you help me with this patch?

Thank you very much!
Wendy

On Wed, 2007-05-09 at 17:36 -0500, wendy xiong wrote:
> This patch add new sub-device-id to support new adapter and changed the
> interrupt irq number for unsigned char to unsigned int.
> 
> Signed-off by: Wendy Xiong <wendyx@us.ibm.com>
> 
> 
> diff -Nuar linux-2.6.21-rc7.orig/drivers/serial/icom.c linux-2.6.21-rc7.new/drivers/serial/icom.c
> --- linux-2.6.21-rc7.orig/drivers/serial/icom.c 2008-01-10 23:53:59.000000000 -0600
> +++ linux-2.6.21-rc7.new/drivers/serial/icom.c  2008-01-10 23:58:30.000000000 -0600
> @@ -97,6 +97,13 @@
>               .subdevice = PCI_DEVICE_ID_IBM_ICOM_FOUR_PORT_MODEL,
>               .driver_data = ADAPTER_V2,
>          },
> +       {
> +             .vendor = PCI_VENDOR_ID_IBM,
> +             .device = PCI_DEVICE_ID_IBM_ICOM_DEV_ID_2,
> +             .subvendor = PCI_VENDOR_ID_IBM,
> +             .subdevice = PCI_DEVICE_ID_IBM_ICOM_V2_ONE_PORT_RVX_ONE_PORT_MDM_PCIE,
> +             .driver_data = ADAPTER_V2,
> +        },
>         {}
>  };
> 
> diff -Nuar linux-2.6.21-rc7.orig/drivers/serial/icom.h linux-2.6.21-rc7.new/drivers/serial/icom.h
> --- linux-2.6.21-rc7.orig/drivers/serial/icom.h 2008-01-10 23:53:59.000000000 -0600
> +++ linux-2.6.21-rc7.new/drivers/serial/icom.h  2008-01-10 23:55:42.000000000 -0600
> @@ -258,7 +258,7 @@
>  struct icom_adapter {
>         void __iomem * base_addr;
>         unsigned long base_addr_pci;
> -       unsigned char irq_number;
> +       unsigned int irq_number;
>         struct pci_dev *pci_dev;
>         struct icom_port port_info[4];
>         int index;
> diff -Nuar linux-2.6.21-rc7.orig/include/linux/pci_ids.h linux-2.6.21-rc7.new/include/linux/pci_ids.h
> --- linux-2.6.21-rc7.orig/include/linux/pci_ids.h       2008-01-10 23:54:13.000000000 -0600
> +++ linux-2.6.21-rc7.new/include/linux/pci_ids.h        2008-01-10 23:59:08.000000000 -0600
> @@ -471,6 +471,7 @@
>  #define PCI_DEVICE_ID_IBM_ICOM_DEV_ID_2        0x0219
>  #define PCI_DEVICE_ID_IBM_ICOM_V2_TWO_PORTS_RVX                0x021A
>  #define PCI_DEVICE_ID_IBM_ICOM_V2_ONE_PORT_RVX_ONE_PORT_MDM    0x0251
> +#define PCI_DEVICE_ID_IBM_ICOM_V2_ONE_PORT_RVX_ONE_PORT_MDM_PCIE       0x0361
>  #define PCI_DEVICE_ID_IBM_ICOM_FOUR_PORT_MODEL 0x252
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

