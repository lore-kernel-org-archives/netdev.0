From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH net-next 1/4] tulip: xircom_cb: Convert #ifdef DEBUG
	blocks and enter/leave uses
Date: Wed, 11 May 2011 21:36:13 -0600
Message-ID: <20110512033613.GA8885@parisc-linux.org>
References: <cover.1304733889.git.joe@perches.com> <aae1da5aca13af94b621ffe64634435c26c88465.1304733889.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <aae1da5aca13af94b621ffe64634435c26c88465.1304733889.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 06, 2011 at 07:08:42PM -0700, Joe Perches wrote:
> Change the blocks that are guarded by #if DEBUG to
> be #if defined DEBUG && DEBUG > 1 so that pr_debug
> can be used later.
> 
> Rename enter/leave macros to func_enter and func_exit.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Good cleanups. :)

Acked-by: Grant Grundler <grundler@parisc-linux.org>

thanks!
grant

> ---
>  drivers/net/tulip/xircom_cb.c |  152 ++++++++++++++++++++--------------------
>  1 files changed, 76 insertions(+), 76 deletions(-)
> 
> diff --git a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
> index 5a73752..4436865 100644
> --- a/drivers/net/tulip/xircom_cb.c
> +++ b/drivers/net/tulip/xircom_cb.c
> @@ -37,12 +37,12 @@
>  #include <asm/irq.h>
>  #endif
>  
> -#ifdef DEBUG
> -#define enter(x)   printk("Enter: %s, %s line %i\n",x,__FILE__,__LINE__)
> -#define leave(x)   printk("Leave: %s, %s line %i\n",x,__FILE__,__LINE__)
> +#if defined DEBUG && DEBUG > 1
> +#define func_enter(x)	pr_debug("Enter: %s\n", __func__)
> +#define func_exit(x)	pr_debug("Exit: %s\n", __func__)
>  #else
> -#define enter(x)   do {} while (0)
> -#define leave(x)   do {} while (0)
> +#define func_enter(x)	no_printk(KERN_DEBUG "Enter: %s\n", __func__)
> +#define func_exit(x)	no_printk(KERN_DEBUG "Exit: %s\n", __func__)
>  #endif
>  
>  
> @@ -161,7 +161,7 @@ static struct pci_driver xircom_ops = {
>  };
>  
>  
> -#ifdef DEBUG
> +#if defined DEBUG && DEBUG > 1
>  static void print_binary(unsigned int number)
>  {
>  	int i,i2;
> @@ -176,7 +176,7 @@ static void print_binary(unsigned int number)
>  		if ((i&3)==0)
>  			buffer[i2++]=' ';
>  	}
> -	printk("%s\n",buffer);
> +	pr_debug("%s\n",buffer);
>  }
>  #endif
>  
> @@ -205,7 +205,7 @@ static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_
>  	struct xircom_private *private;
>  	unsigned long flags;
>  	unsigned short tmp16;
> -	enter("xircom_probe");
> +	func_enter();
>  
>  	/* First do the PCI initialisation */
>  
> @@ -285,7 +285,7 @@ static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_
>  
>  	trigger_receive(private);
>  
> -	leave("xircom_probe");
> +	func_exit();
>  	return 0;
>  
>  reg_fail:
> @@ -310,7 +310,7 @@ static void __devexit xircom_remove(struct pci_dev *pdev)
>  	struct net_device *dev = pci_get_drvdata(pdev);
>  	struct xircom_private *card = netdev_priv(dev);
>  
> -	enter("xircom_remove");
> +	func_enter();
>  	pci_free_consistent(pdev,8192,card->rx_buffer,card->rx_dma_handle);
>  	pci_free_consistent(pdev,8192,card->tx_buffer,card->tx_dma_handle);
>  
> @@ -318,7 +318,7 @@ static void __devexit xircom_remove(struct pci_dev *pdev)
>  	unregister_netdev(dev);
>  	free_netdev(dev);
>  	pci_set_drvdata(pdev, NULL);
> -	leave("xircom_remove");
> +	func_exit();
>  }
>  
>  static irqreturn_t xircom_interrupt(int irq, void *dev_instance)
> @@ -328,17 +328,17 @@ static irqreturn_t xircom_interrupt(int irq, void *dev_instance)
>  	unsigned int status;
>  	int i;
>  
> -	enter("xircom_interrupt\n");
> +	func_enter();
>  
>  	spin_lock(&card->lock);
>  	status = inl(card->io_port+CSR5);
>  
> -#ifdef DEBUG
> +#if defined DEBUG && DEBUG > 1
>  	print_binary(status);
> -	printk("tx status 0x%08x 0x%08x\n",
> -	       card->tx_buffer[0], card->tx_buffer[4]);
> -	printk("rx status 0x%08x 0x%08x\n",
> -	       card->rx_buffer[0], card->rx_buffer[4]);
> +	pr_debug("tx status 0x%08x 0x%08x\n",
> +		 card->tx_buffer[0], card->tx_buffer[4]);
> +	pr_debug("rx status 0x%08x 0x%08x\n",
> +		 card->rx_buffer[0], card->rx_buffer[4]);
>  #endif
>  	/* Handle shared irq and hotplug */
>  	if (status == 0 || status == 0xffffffff) {
> @@ -371,7 +371,7 @@ static irqreturn_t xircom_interrupt(int irq, void *dev_instance)
>  
>  
>  	spin_unlock(&card->lock);
> -	leave("xircom_interrupt");
> +	func_exit();
>  	return IRQ_HANDLED;
>  }
>  
> @@ -382,7 +382,7 @@ static netdev_tx_t xircom_start_xmit(struct sk_buff *skb,
>  	unsigned long flags;
>  	int nextdescriptor;
>  	int desc;
> -	enter("xircom_start_xmit");
> +	func_enter();
>  
>  	card = netdev_priv(dev);
>  	spin_lock_irqsave(&card->lock,flags);
> @@ -424,7 +424,7 @@ static netdev_tx_t xircom_start_xmit(struct sk_buff *skb,
>  				netif_stop_queue(dev);
>  			}
>  			card->transmit_used = nextdescriptor;
> -			leave("xircom-start_xmit - sent");
> +			func_exit();
>  			spin_unlock_irqrestore(&card->lock,flags);
>  			return NETDEV_TX_OK;
>  	}
> @@ -446,18 +446,18 @@ static int xircom_open(struct net_device *dev)
>  {
>  	struct xircom_private *xp = netdev_priv(dev);
>  	int retval;
> -	enter("xircom_open");
> +	func_enter();
>  	pr_info("xircom cardbus adaptor found, registering as %s, using irq %i\n",
>  		dev->name, dev->irq);
>  	retval = request_irq(dev->irq, xircom_interrupt, IRQF_SHARED, dev->name, dev);
>  	if (retval) {
> -		leave("xircom_open - No IRQ");
> +		func_exit();
>  		return retval;
>  	}
>  
>  	xircom_up(xp);
>  	xp->open = 1;
> -	leave("xircom_open");
> +	func_exit();
>  	return 0;
>  }
>  
> @@ -466,7 +466,7 @@ static int xircom_close(struct net_device *dev)
>  	struct xircom_private *card;
>  	unsigned long flags;
>  
> -	enter("xircom_close");
> +	func_enter();
>  	card = netdev_priv(dev);
>  	netif_stop_queue(dev); /* we don't want new packets */
>  
> @@ -486,7 +486,7 @@ static int xircom_close(struct net_device *dev)
>  	card->open = 0;
>  	free_irq(dev->irq,dev);
>  
> -	leave("xircom_close");
> +	func_exit();
>  
>  	return 0;
>  
> @@ -507,7 +507,7 @@ static void initialize_card(struct xircom_private *card)
>  {
>  	unsigned int val;
>  	unsigned long flags;
> -	enter("initialize_card");
> +	func_enter();
>  
>  
>  	spin_lock_irqsave(&card->lock, flags);
> @@ -535,7 +535,7 @@ static void initialize_card(struct xircom_private *card)
>  
>  	spin_unlock_irqrestore(&card->lock, flags);
>  
> -	leave("initialize_card");
> +	func_exit();
>  }
>  
>  /*
> @@ -547,12 +547,12 @@ ignored; I chose zero.
>  static void trigger_transmit(struct xircom_private *card)
>  {
>  	unsigned int val;
> -	enter("trigger_transmit");
> +	func_enter();
>  
>  	val = 0;
>  	outl(val, card->io_port + CSR1);
>  
> -	leave("trigger_transmit");
> +	func_exit();
>  }
>  
>  /*
> @@ -565,12 +565,12 @@ ignored; I chose zero.
>  static void trigger_receive(struct xircom_private *card)
>  {
>  	unsigned int val;
> -	enter("trigger_receive");
> +	func_enter();
>  
>  	val = 0;
>  	outl(val, card->io_port + CSR2);
>  
> -	leave("trigger_receive");
> +	func_exit();
>  }
>  
>  /*
> @@ -581,7 +581,7 @@ static void setup_descriptors(struct xircom_private *card)
>  {
>  	u32 address;
>  	int i;
> -	enter("setup_descriptors");
> +	func_enter();
>  
>  
>  	BUG_ON(card->rx_buffer == NULL);
> @@ -637,7 +637,7 @@ static void setup_descriptors(struct xircom_private *card)
>  	address = card->tx_dma_handle;
>  	outl(address, card->io_port + CSR4);	/* xmit descr list address */
>  
> -	leave("setup_descriptors");
> +	func_exit();
>  }
>  
>  /*
> @@ -647,13 +647,13 @@ valid by setting the address in the card to 0x00.
>  static void remove_descriptors(struct xircom_private *card)
>  {
>  	unsigned int val;
> -	enter("remove_descriptors");
> +	func_enter();
>  
>  	val = 0;
>  	outl(val, card->io_port + CSR3);	/* Receive descriptor address */
>  	outl(val, card->io_port + CSR4);	/* Send descriptor address */
>  
> -	leave("remove_descriptors");
> +	func_exit();
>  }
>  
>  /*
> @@ -665,12 +665,12 @@ This function also clears the status-bit.
>  static int link_status_changed(struct xircom_private *card)
>  {
>  	unsigned int val;
> -	enter("link_status_changed");
> +	func_enter();
>  
>  	val = inl(card->io_port + CSR5);	/* Status register */
>  
>  	if ((val & (1 << 27)) == 0) {	/* no change */
> -		leave("link_status_changed - nochange");
> +		func_exit();
>  		return 0;
>  	}
>  
> @@ -679,7 +679,7 @@ static int link_status_changed(struct xircom_private *card)
>  	val = (1 << 27);
>  	outl(val, card->io_port + CSR5);
>  
> -	leave("link_status_changed - changed");
> +	func_exit();
>  	return 1;
>  }
>  
> @@ -691,16 +691,16 @@ in a non-stopped state.
>  static int transmit_active(struct xircom_private *card)
>  {
>  	unsigned int val;
> -	enter("transmit_active");
> +	func_enter();
>  
>  	val = inl(card->io_port + CSR5);	/* Status register */
>  
>  	if ((val & (7 << 20)) == 0) {	/* transmitter disabled */
> -		leave("transmit_active - inactive");
> +		func_exit();
>  		return 0;
>  	}
>  
> -	leave("transmit_active - active");
> +	func_exit();
>  	return 1;
>  }
>  
> @@ -711,17 +711,17 @@ in a non-stopped state.
>  static int receive_active(struct xircom_private *card)
>  {
>  	unsigned int val;
> -	enter("receive_active");
> +	func_enter();
>  
>  
>  	val = inl(card->io_port + CSR5);	/* Status register */
>  
>  	if ((val & (7 << 17)) == 0) {	/* receiver disabled */
> -		leave("receive_active - inactive");
> +		func_exit();
>  		return 0;
>  	}
>  
> -	leave("receive_active - active");
> +	func_exit();
>  	return 1;
>  }
>  
> @@ -739,7 +739,7 @@ static void activate_receiver(struct xircom_private *card)
>  {
>  	unsigned int val;
>  	int counter;
> -	enter("activate_receiver");
> +	func_enter();
>  
>  
>  	val = inl(card->io_port + CSR6);	/* Operation mode */
> @@ -781,7 +781,7 @@ static void activate_receiver(struct xircom_private *card)
>  			pr_err("Receiver failed to re-activate\n");
>  	}
>  
> -	leave("activate_receiver");
> +	func_exit();
>  }
>  
>  /*
> @@ -795,7 +795,7 @@ static void deactivate_receiver(struct xircom_private *card)
>  {
>  	unsigned int val;
>  	int counter;
> -	enter("deactivate_receiver");
> +	func_enter();
>  
>  	val = inl(card->io_port + CSR6);	/* Operation mode */
>  	val = val & ~2;				/* disable the receiver */
> @@ -813,7 +813,7 @@ static void deactivate_receiver(struct xircom_private *card)
>  	}
>  
>  
> -	leave("deactivate_receiver");
> +	func_exit();
>  }
>  
>  
> @@ -831,7 +831,7 @@ static void activate_transmitter(struct xircom_private *card)
>  {
>  	unsigned int val;
>  	int counter;
> -	enter("activate_transmitter");
> +	func_enter();
>  
>  
>  	val = inl(card->io_port + CSR6);	/* Operation mode */
> @@ -872,7 +872,7 @@ static void activate_transmitter(struct xircom_private *card)
>  			pr_err("Transmitter failed to re-activate\n");
>  	}
>  
> -	leave("activate_transmitter");
> +	func_exit();
>  }
>  
>  /*
> @@ -886,7 +886,7 @@ static void deactivate_transmitter(struct xircom_private *card)
>  {
>  	unsigned int val;
>  	int counter;
> -	enter("deactivate_transmitter");
> +	func_enter();
>  
>  	val = inl(card->io_port + CSR6);	/* Operation mode */
>  	val = val & ~2;		/* disable the transmitter */
> @@ -904,7 +904,7 @@ static void deactivate_transmitter(struct xircom_private *card)
>  	}
>  
>  
> -	leave("deactivate_transmitter");
> +	func_exit();
>  }
>  
>  
> @@ -916,13 +916,13 @@ must be called with the lock held and interrupts disabled.
>  static void enable_transmit_interrupt(struct xircom_private *card)
>  {
>  	unsigned int val;
> -	enter("enable_transmit_interrupt");
> +	func_enter();
>  
>  	val = inl(card->io_port + CSR7);	/* Interrupt enable register */
>  	val |= 1;				/* enable the transmit interrupt */
>  	outl(val, card->io_port + CSR7);
>  
> -	leave("enable_transmit_interrupt");
> +	func_exit();
>  }
>  
>  
> @@ -934,13 +934,13 @@ must be called with the lock held and interrupts disabled.
>  static void enable_receive_interrupt(struct xircom_private *card)
>  {
>  	unsigned int val;
> -	enter("enable_receive_interrupt");
> +	func_enter();
>  
>  	val = inl(card->io_port + CSR7);	/* Interrupt enable register */
>  	val = val | (1 << 6);			/* enable the receive interrupt */
>  	outl(val, card->io_port + CSR7);
>  
> -	leave("enable_receive_interrupt");
> +	func_exit();
>  }
>  
>  /*
> @@ -951,13 +951,13 @@ must be called with the lock held and interrupts disabled.
>  static void enable_link_interrupt(struct xircom_private *card)
>  {
>  	unsigned int val;
> -	enter("enable_link_interrupt");
> +	func_enter();
>  
>  	val = inl(card->io_port + CSR7);	/* Interrupt enable register */
>  	val = val | (1 << 27);			/* enable the link status chage interrupt */
>  	outl(val, card->io_port + CSR7);
>  
> -	leave("enable_link_interrupt");
> +	func_exit();
>  }
>  
>  
> @@ -970,12 +970,12 @@ must be called with the lock held and interrupts disabled.
>  static void disable_all_interrupts(struct xircom_private *card)
>  {
>  	unsigned int val;
> -	enter("enable_all_interrupts");
> +	func_enter();
>  
>  	val = 0;				/* disable all interrupts */
>  	outl(val, card->io_port + CSR7);
>  
> -	leave("disable_all_interrupts");
> +	func_exit();
>  }
>  
>  /*
> @@ -986,7 +986,7 @@ must be called with the lock held and interrupts disabled.
>  static void enable_common_interrupts(struct xircom_private *card)
>  {
>  	unsigned int val;
> -	enter("enable_link_interrupt");
> +	func_enter();
>  
>  	val = inl(card->io_port + CSR7);	/* Interrupt enable register */
>  	val |= (1<<16); /* Normal Interrupt Summary */
> @@ -999,7 +999,7 @@ static void enable_common_interrupts(struct xircom_private *card)
>  	val |= (1<<1);  /* Transmit Process Stopped */
>  	outl(val, card->io_port + CSR7);
>  
> -	leave("enable_link_interrupt");
> +	func_exit();
>  }
>  
>  /*
> @@ -1010,13 +1010,13 @@ must be called with the lock held and interrupts disabled.
>  static int enable_promisc(struct xircom_private *card)
>  {
>  	unsigned int val;
> -	enter("enable_promisc");
> +	func_enter();
>  
>  	val = inl(card->io_port + CSR6);
>  	val = val | (1 << 6);
>  	outl(val, card->io_port + CSR6);
>  
> -	leave("enable_promisc");
> +	func_exit();
>  	return 1;
>  }
>  
> @@ -1031,7 +1031,7 @@ Must be called in locked state with interrupts disabled
>  static int link_status(struct xircom_private *card)
>  {
>  	unsigned int val;
> -	enter("link_status");
> +	func_enter();
>  
>  	val = inb(card->io_port + CSR12);
>  
> @@ -1042,7 +1042,7 @@ static int link_status(struct xircom_private *card)
>  
>  	/* If we get here -> no link at all */
>  
> -	leave("link_status");
> +	func_exit();
>  	return 0;
>  }
>  
> @@ -1061,7 +1061,7 @@ static void read_mac_address(struct xircom_private *card)
>  	unsigned long flags;
>  	int i;
>  
> -	enter("read_mac_address");
> +	func_enter();
>  
>  	spin_lock_irqsave(&card->lock, flags);
>  
> @@ -1090,7 +1090,7 @@ static void read_mac_address(struct xircom_private *card)
>  	}
>  	spin_unlock_irqrestore(&card->lock, flags);
>  	pr_debug(" %pM\n", card->dev->dev_addr);
> -	leave("read_mac_address");
> +	func_exit();
>  }
>  
>  
> @@ -1103,7 +1103,7 @@ static void transceiver_voodoo(struct xircom_private *card)
>  {
>  	unsigned long flags;
>  
> -	enter("transceiver_voodoo");
> +	func_enter();
>  
>  	/* disable all powermanagement */
>  	pci_write_config_dword(card->pdev, PCI_POWERMGMT, 0x0000);
> @@ -1122,7 +1122,7 @@ static void transceiver_voodoo(struct xircom_private *card)
>          spin_unlock_irqrestore(&card->lock, flags);
>  
>  	netif_start_queue(card->dev);
> -	leave("transceiver_voodoo");
> +	func_exit();
>  }
>  
>  
> @@ -1131,7 +1131,7 @@ static void xircom_up(struct xircom_private *card)
>  	unsigned long flags;
>  	int i;
>  
> -	enter("xircom_up");
> +	func_enter();
>  
>  	/* disable all powermanagement */
>  	pci_write_config_dword(card->pdev, PCI_POWERMGMT, 0x0000);
> @@ -1156,7 +1156,7 @@ static void xircom_up(struct xircom_private *card)
>  	trigger_receive(card);
>  	trigger_transmit(card);
>  	netif_start_queue(card->dev);
> -	leave("xircom_up");
> +	func_exit();
>  }
>  
>  /* Bufferoffset is in BYTES */
> @@ -1164,7 +1164,7 @@ static void investigate_read_descriptor(struct net_device *dev,struct xircom_pri
>  {
>  		int status;
>  
> -		enter("investigate_read_descriptor");
> +		func_enter();
>  		status = le32_to_cpu(card->rx_buffer[4*descnr]);
>  
>  		if ((status > 0)) {	/* packet received */
> @@ -1198,7 +1198,7 @@ static void investigate_read_descriptor(struct net_device *dev,struct xircom_pri
>  			trigger_receive(card);
>  		}
>  
> -		leave("investigate_read_descriptor");
> +		func_exit();
>  
>  }
>  
> @@ -1208,7 +1208,7 @@ static void investigate_write_descriptor(struct net_device *dev, struct xircom_p
>  {
>  		int status;
>  
> -		enter("investigate_write_descriptor");
> +		func_enter();
>  
>  		status = le32_to_cpu(card->tx_buffer[4*descnr]);
>  #if 0
> @@ -1232,7 +1232,7 @@ static void investigate_write_descriptor(struct net_device *dev, struct xircom_p
>  			dev->stats.tx_packets++;
>  		}
>  
> -		leave("investigate_write_descriptor");
> +		func_exit();
>  
>  }
>  
> -- 
> 1.7.5.rc3.dirty
