From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: [PATCH] skge driver (0.5)
Date: Tue, 25 Jan 2005 22:37:19 -0800
Message-ID: <1106721439.3458.449.camel@localhost.localdomain>
References: <20050119135217.38fe5f05@dxpl.pdx.osdl.net>
	 <20050125151507.414e7f4f@dxpl.pdx.osdl.net>
Reply-To: sfeldma@pobox.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050125151507.414e7f4f@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Nice looking driver Stephen.  :)  

Some minor comments.

> +#include <linux/config.h>
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/moduleparam.h>
> +#include <linux/netdevice.h>
> +#include <linux/etherdevice.h>
> +#include <linux/dma-mapping.h>
> +#include <linux/ethtool.h>
> +#include <linux/pci.h>
> +#include <linux/if_vlan.h>
> +#include <linux/ip.h>
> +#include <linux/udp.h>
> +#include <linux/tcp.h>
> +#include <linux/delay.h>
> +#include <linux/crc32.h>
> +#include <asm/irq.h>

Seems like dma-mapping.h, udp.h, tcp.h, irq.h don't need to be included
for a clean compile.  Ditch 'em?

> +
> +	memset(hw, 0, sizeof(*hw));
> +	hw->pdev = pdev;
> +	spin_lock_init(&hw->phy_lock);
> +	tasklet_init(&hw->ext_tasklet, skge_extirq, (unsigned long) hw);
> +
> +	hw->regs = ioremap_nocache(pci_resource_start(pdev, 0), 0x4000);
> +	if (!hw->regs) {
> +		printk(KERN_ERR "skge %s: cannot map device registers\n",

PFX instead of skge.  There are a couple of these with hardcoded "skge"
or none at all.

> +static int skge_resume(struct pci_dev *pdev)
> +{
> +	struct skge_hw *hw  = pci_get_drvdata(pdev);
> +	int i;
> +
> +	pci_set_power_state(pdev, PCI_D0);
> +	pci_restore_state(pdev);
> +
> +	skge_reset(hw);
> +
> +	for(i = 0; i < 2; i++) {
> +		struct net_device *dev = hw->dev[i];

Is a netif_device_attach needed to match the netif_device_detach in
suspend?

-scott
