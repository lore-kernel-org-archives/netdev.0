From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 3/5] sis900 printk audit
Date: Sat, 22 Jan 2005 23:26:18 +0100
Message-ID: <20050122222618.GA24461@electric-eye.fr.zoreil.com>
References: <20050122214657.18649.66345@localhost.localdomain> <20050122214659.18649.83119@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, NetDev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Daniele Venzano <webvenza@libero.it>
Content-Disposition: inline
In-Reply-To: <20050122214659.18649.83119@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Daniele Venzano <webvenza@libero.it> :
[...]
> Index: sis900.c
> ===================================================================
> --- a/drivers/net/sis900.c	(revision 85)
> +++ b/drivers/net/sis900.c	(revision 86)
[...]
> @@ -275,7 +275,7 @@
>  	if (!isa_bridge)
>  		isa_bridge = pci_get_device(PCI_VENDOR_ID_SI, 0x0018, isa_bridge);
>  	if (!isa_bridge) {
> -		printk("%s: Can not find ISA bridge\n", net_dev->name);
> +		printk(KERN_WARNING "%s: Can not find ISA bridge\n", net_dev->name);
>  		return 0;
>  	}
>  	pci_read_config_byte(isa_bridge, 0x48, &reg);
> @@ -567,7 +567,7 @@
>  			continue;
>  		
>  		if ((mii_phy = kmalloc(sizeof(struct mii_phy), GFP_KERNEL)) == NULL) {
> -			printk(KERN_INFO "Cannot allocate mem for struct mii_phy\n");
> +			printk(KERN_WARNING "Cannot allocate mem for struct mii_phy\n");

-> printk(KERN_WARNING "%s: Cannot allocate mem for struct mii_phy\n", ...) ?

Btw it may make sense to use pci_name() instead of the name associated with
the struct net_device until it is known for sure that the net_device will not
be removed due to a failure of the probe() method. 

--
Ueimor
