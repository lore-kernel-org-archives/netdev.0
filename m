From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/7] Topcliff GbE: Add The Main code
Date: Fri, 23 Apr 2010 17:27:23 +0200
Message-ID: <201004231727.23246.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: "NETDEV" <netdev@vger.kernel.org>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	"Wang, Qi" <qi.wang@intel.com>, "Intel OTC" <joel.clark@intel.com>,
	"Andrew" <andrew.chih.howe.khor@intel.com>
To: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:61668 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754299Ab0DWP12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 11:27:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 23 April 2010, Masayuki Ohtake wrote:
> From: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
> 
> This patch adds the Main code of GbE driver for Topcliff.
> The GbE driver needs all patch[1/7 to 7/7].
> 
> Signed-off-by: Masayuki Ohtake <masa-korg@dsn.okisemi.com>

I already commented on the "Topcliff PHUB: Add The Packet Hub driver"
submission. Many of my comments there apply here as well, but
there are a few more things that you may want to address in
future submissions:

> +static int
> +pch_gbe_probe(struct pci_dev *pdev, const struct pci_device_id *pci_id);
> +static void pch_gbe_remove(struct pci_dev *pdev);
> +static int pch_gbe_suspend(struct pci_dev *pdev, pm_message_t state);
> +static int pch_gbe_resume(struct pci_dev *pdev);

Ideally, static functions are ordered such that the caller is
last, so you can drop all of the forward declarations like these.

> +/*!
> + * @ingroup PCI driver Layer
> + * @struct  pch_gbe_pcidev_id
> + * @brief   PCI Device ID Table
> + * @remarks
> + *  This is an instance of pci_device_id structure defined in linux/pci.h,
> + *  and holds information of the PCI devices that are supported by this
> driver.
> + */
> +static const struct pci_device_id pch_gbe_pcidev_id[3] = {
> + {.vendor = PCI_VENDOR_ID_INTEL,
> +  .device = PCI_DEVICE_ID_INTEL_IOH1_GBE,
> +  .subvendor = PCI_ANY_ID,
> +  .subdevice = PCI_ANY_ID,
> +  .class = (PCI_CLASS_NETWORK_ETHERNET << 8),
> +  .class_mask = (0xFFFF00)
> +  },
> + /* required last entry */
> + {0}
> +};

Your array size above is three, but you only define two members.
Better may the array automatically sized. Also, it's clearer to
use the PCI_DEVICE_CLASS() helper macro, e.g.

static const struct pci_device_id pch_gbe_pcidev_id[] = {
	{ PCI_DEVICE(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_IOH1_GBE) },
	{ 0 },
};

	Arnd
