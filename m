From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Subject:  [PATCH 2.6.20 004/005] dmfe: Add support for suspend/resume
Date: Sat, 17 Feb 2007 12:50:29 +0100
Message-ID: <20070217115029.GF9120@elf.ucw.cz>
References: <200702152253.53680.maximlevitsky@gmail.com> <200702152311.54407.maximlevitsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@kernel.org, linux-kernel@vger.kernel.org
To: Maxim <maximlevitsky@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965214AbXBQLuu@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200702152311.54407.maximlevitsky@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> @@ -2050,11 +2047,56 @@ static struct pci_device_id dmfe_pci_tbl
>  MODULE_DEVICE_TABLE(pci, dmfe_pci_tbl);
>  
>  
> +
> +static int dmfe_suspend(struct pci_dev *pci_dev, pm_message_t state)
> +{
> +	struct net_device *dev = pci_get_drvdata(pci_dev);
> +	struct dmfe_board_info *db = netdev_priv(dev);
> +
> +	/* Disable upper layer interface */
> +	netif_device_detach (dev);
> +
> +	/* Disable Tx/Rx */
> +	db->cr6_data &= ~(CR6_RXSC | CR6_TXSC);
> +	update_cr6(db->cr6_data, dev->base_addr);
> +
> +	/* Disable Interrupt */
> +	outl (0, dev->base_addr + DCR7);
> +	outl (inl (dev->base_addr + DCR5), dev->base_addr + DCR5);

Please no space between function and "(".

> +	/* Fre RX buffers */

Free?

> +	dmfe_free_rxbuffer (db);

> +	/* Power down device*/

" */"

> +	pci_set_power_state (pci_dev, pci_choose_state (pci_dev,state));

Let it be ", state", and delete spaces between function and "(".


> +static int dmfe_resume (struct pci_dev *pci_dev)

delete spaces between function and "(".

> +	pci_restore_state(pci_dev);
> +	pci_set_power_state(pci_dev ,PCI_D0);
> +

", "

Otherwise looks ok to me.

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
