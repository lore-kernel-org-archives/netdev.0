From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2/5] sis900 printk and stack usage audit
Date: Sat, 11 Dec 2004 14:09:10 -0500
Message-ID: <41BB45D6.2090608@pobox.com>
References: <20041208104721.GA31707@picchio.gall.it> <20041208110426.GC31707@picchio.gall.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Daniele Venzano <webvenza@libero.it>
In-Reply-To: <20041208110426.GC31707@picchio.gall.it>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Daniele Venzano wrote:
> @@ -455,10 +455,15 @@
>  	if (ret)
>  		goto err_unmap_rx;
>  		
> +	pci_read_config_byte(pci_dev, PCI_CLASS_REVISION, &revision);
> +
> +	if(sis900_debug > 0)
> +		printk(KERN_DEBUG "%s: detected revision %2.2x,"
> +				"trying to get MAC address...\n",
> +				net_dev->name, revision);
> +
>  	/* Get Mac address according to the chip revision */
> -	pci_read_config_byte(pci_dev, PCI_CLASS_REVISION, &revision);
>  	ret = 0;
> -

use netif_msg_* bitmap


> @@ -542,9 +549,14 @@
>  		for(i = 0; i < 2; i++)
>  			mii_status = mdio_read(net_dev, phy_addr, MII_STATUS);
>  
> -		if (mii_status == 0xffff || mii_status == 0x0000)
> +		if (mii_status == 0xffff || mii_status == 0x0000) {
>  			/* the mii is not accessible, try next one */
> +			if (sis900_debug > 0)
> +				printk(KERN_DEBUG "%s: MII at address %d"
> +						" not accessible\n",
> +						net_dev->name, phy_addr);
>  			continue;
> +		}
>  		

ditto


> @@ -568,14 +580,15 @@
>  
>  		for (i = 0; mii_chip_table[i].phy_id1; i++)
>  			if ((mii_phy->phy_id0 == mii_chip_table[i].phy_id0 ) &&
> -			    ((mii_phy->phy_id1 & 0xFFF0) == mii_chip_table[i].phy_id1)){
> +			    ((mii_phy->phy_id1 & 0xFFF0) == mii_chip_table[i].phy_id1))
> +			{

CodingStyle:  the brace following an 'if' does not exist on a line by 
itself.

	Jeff
