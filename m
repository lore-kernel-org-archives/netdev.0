From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/3] defxx: Correct DEFEA's ESIC port I/O accesses
Date: Thu, 25 Sep 2014 10:38:24 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1749D806@AcuExch.aculab.com>
References: <alpine.LFD.2.11.1409242337420.6148@eddie.linux-mips.org>
 <alpine.LFD.2.11.1409251028070.6148@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: "'Maciej W. Rozycki'" <macro@linux-mips.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:40804 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752109AbaIYKjx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 06:39:53 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 16875-06 for <netdev@vger.kernel.org>;
 Thu, 25 Sep 2014 11:39:43 +0100 (BST)
In-Reply-To: <alpine.LFD.2.11.1409251028070.6148@eddie.linux-mips.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej W. Rozycki
> Reverse the order of arguments to `outb', data to write comes first.

How long has this actually been wrong?
It is just worth deleting the driver?

	David

> 
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
> ---
>  Brown paperbag time.  Dave, please apply.
> 
>   Maciej
> 
> linux-defea-esic-outb.patch
> Index: linux-20140924-dolch/drivers/net/fddi/defxx.c
> ===================================================================
> --- linux-20140924-dolch.orig/drivers/net/fddi/defxx.c
> +++ linux-20140924-dolch/drivers/net/fddi/defxx.c
> @@ -719,28 +719,28 @@ static void dfx_bus_init(struct net_devi
> 
>  		/* Set the decode range of the board.  */
>  		val = ((bp->base.port >> 12) << PI_IO_CMP_V_SLOT);
> -		outb(base_addr + PI_ESIC_K_IO_ADD_CMP_0_1, val);
> -		outb(base_addr + PI_ESIC_K_IO_ADD_CMP_0_0, 0);
> -		outb(base_addr + PI_ESIC_K_IO_ADD_CMP_1_1, val);
> -		outb(base_addr + PI_ESIC_K_IO_ADD_CMP_1_0, 0);
> +		outb(val, base_addr + PI_ESIC_K_IO_ADD_CMP_0_1);
> +		outb(0, base_addr + PI_ESIC_K_IO_ADD_CMP_0_0);
> +		outb(val, base_addr + PI_ESIC_K_IO_ADD_CMP_1_1);
> +		outb(0, base_addr + PI_ESIC_K_IO_ADD_CMP_1_0);
>  		val = PI_ESIC_K_CSR_IO_LEN - 1;
> -		outb(base_addr + PI_ESIC_K_IO_ADD_MASK_0_1, (val >> 8) & 0xff);
> -		outb(base_addr + PI_ESIC_K_IO_ADD_MASK_0_0, val & 0xff);
> -		outb(base_addr + PI_ESIC_K_IO_ADD_MASK_1_1, (val >> 8) & 0xff);
> -		outb(base_addr + PI_ESIC_K_IO_ADD_MASK_1_0, val & 0xff);
> +		outb(val, base_addr + PI_ESIC_K_IO_ADD_MASK_0_1);
> +		outb(0, base_addr + PI_ESIC_K_IO_ADD_MASK_0_0);
> +		outb(val, base_addr + PI_ESIC_K_IO_ADD_MASK_1_1);
> +		outb(0, base_addr + PI_ESIC_K_IO_ADD_MASK_1_0);
> 
>  		/* Enable the decoders.  */
>  		val = PI_FUNCTION_CNTRL_M_IOCS1 | PI_FUNCTION_CNTRL_M_IOCS0;
>  		if (dfx_use_mmio)
>  			val |= PI_FUNCTION_CNTRL_M_MEMCS0;
> -		outb(base_addr + PI_ESIC_K_FUNCTION_CNTRL, val);
> +		outb(val, base_addr + PI_ESIC_K_FUNCTION_CNTRL);
> 
>  		/*
>  		 * Enable access to the rest of the module
>  		 * (including PDQ and packet memory).
>  		 */
>  		val = PI_SLOT_CNTRL_M_ENB;
> -		outb(base_addr + PI_ESIC_K_SLOT_CNTRL, val);
> +		outb(val, base_addr + PI_ESIC_K_SLOT_CNTRL);
> 
>  		/*
>  		 * Map PDQ registers into memory or port space.  This is
> @@ -751,12 +751,12 @@ static void dfx_bus_init(struct net_devi
>  			val |= PI_BURST_HOLDOFF_V_MEM_MAP;
>  		else
>  			val &= ~PI_BURST_HOLDOFF_V_MEM_MAP;
> -		outb(base_addr + PI_DEFEA_K_BURST_HOLDOFF, val);
> +		outb(val, base_addr + PI_DEFEA_K_BURST_HOLDOFF);
> 
>  		/* Enable interrupts at EISA bus interface chip (ESIC) */
>  		val = inb(base_addr + PI_ESIC_K_IO_CONFIG_STAT_0);
>  		val |= PI_CONFIG_STAT_0_M_INT_ENB;
> -		outb(base_addr + PI_ESIC_K_IO_CONFIG_STAT_0, val);
> +		outb(val, base_addr + PI_ESIC_K_IO_CONFIG_STAT_0);
>  	}
>  	if (dfx_bus_pci) {
>  		struct pci_dev *pdev = to_pci_dev(bdev);
> @@ -825,7 +825,7 @@ static void dfx_bus_uninit(struct net_de
>  		/* Disable interrupts at EISA bus interface chip (ESIC) */
>  		val = inb(base_addr + PI_ESIC_K_IO_CONFIG_STAT_0);
>  		val &= ~PI_CONFIG_STAT_0_M_INT_ENB;
> -		outb(base_addr + PI_ESIC_K_IO_CONFIG_STAT_0, val);
> +		outb(val, base_addr + PI_ESIC_K_IO_CONFIG_STAT_0);
>  	}
>  	if (dfx_bus_pci) {
>  		/* Disable interrupts at PCI bus interface chip (PFI) */
> @@ -1917,7 +1917,7 @@ static irqreturn_t dfx_interrupt(int irq
> 
>  		/* Disable interrupts at the ESIC */
>  		status &= ~PI_CONFIG_STAT_0_M_INT_ENB;
> -		outb(base_addr + PI_ESIC_K_IO_CONFIG_STAT_0, status);
> +		outb(status, base_addr + PI_ESIC_K_IO_CONFIG_STAT_0);
> 
>  		/* Call interrupt service routine for this adapter */
>  		dfx_int_common(dev);
> @@ -1925,7 +1925,7 @@ static irqreturn_t dfx_interrupt(int irq
>  		/* Reenable interrupts at the ESIC */
>  		status = inb(base_addr + PI_ESIC_K_IO_CONFIG_STAT_0);
>  		status |= PI_CONFIG_STAT_0_M_INT_ENB;
> -		outb(base_addr + PI_ESIC_K_IO_CONFIG_STAT_0, status);
> +		outb(status, base_addr + PI_ESIC_K_IO_CONFIG_STAT_0);
> 
>  		spin_unlock(&bp->lock);
>  	}
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
