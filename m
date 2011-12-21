From: Ryan Mallon <rmallon@gmail.com>
Subject: Re: [PATCH 4/4] microblaze: Remove NO_IRQ from architecture
Date: Thu, 22 Dec 2011 09:09:02 +1100
Message-ID: <4EF258FE.9030709@gmail.com>
References: <1324477932-19262-1-git-send-email-monstr@monstr.eu> <1324477932-19262-2-git-send-email-monstr@monstr.eu> <1324477932-19262-3-git-send-email-monstr@monstr.eu> <1324477932-19262-4-git-send-email-monstr@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	Grant Likely <grant.likely@secretlab.ca>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: Michal Simek <monstr@monstr.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1324477932-19262-4-git-send-email-monstr@monstr.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22/12/11 01:32, Michal Simek wrote:

> NO_IRQ shouldn't be used by any driver. All Microblaze
> drivers are fixed that's why NO_IRQ can be removed.


This only describes half of what the patch does. You should also state
that arch/microblaze/pci/pci-common.c has references to NO_IRQ removed.
Maybe it' worth splitting this patch in half so the final patch just
does the removal of the NO_IRQ definition, but maybe that is overkill?

Other than that, for the whole series:

Reviewed-by: Ryan Mallon <rmallon@gmail.com>

> 
> Signed-off-by: Michal Simek <monstr@monstr.eu>
> CC: Grant Likely <grant.likely@secretlab.ca>
> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> CC: Ryan Mallon <rmallon@gmail.com>
> ---
>  arch/microblaze/include/asm/irq.h |    2 --
>  arch/microblaze/pci/pci-common.c  |    4 ++--
>  2 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/microblaze/include/asm/irq.h b/arch/microblaze/include/asm/irq.h
> index b116a82..a175132 100644
> --- a/arch/microblaze/include/asm/irq.h
> +++ b/arch/microblaze/include/asm/irq.h
> @@ -27,8 +27,6 @@ typedef unsigned long irq_hw_number_t;
>  
>  extern unsigned int nr_irq;
>  
> -#define NO_IRQ 0
> -
>  struct pt_regs;
>  extern void do_IRQ(struct pt_regs *regs);
>  
> diff --git a/arch/microblaze/pci/pci-common.c b/arch/microblaze/pci/pci-common.c
> index db841c7..0d71b2e 100644
> --- a/arch/microblaze/pci/pci-common.c
> +++ b/arch/microblaze/pci/pci-common.c
> @@ -242,7 +242,7 @@ int pci_read_irq_line(struct pci_dev *pci_dev)
>  			 line, pin);
>  
>  		virq = irq_create_mapping(NULL, line);
> -		if (virq != NO_IRQ)
> +		if (virq)
>  			irq_set_irq_type(virq, IRQ_TYPE_LEVEL_LOW);
>  	} else {
>  		pr_debug(" Got one, spec %d cells (0x%08x 0x%08x...) on %s\n",
> @@ -253,7 +253,7 @@ int pci_read_irq_line(struct pci_dev *pci_dev)
>  		virq = irq_create_of_mapping(oirq.controller, oirq.specifier,
>  					     oirq.size);
>  	}
> -	if (virq == NO_IRQ) {
> +	if (!virq) {
>  		pr_debug(" Failed to map !\n");
>  		return -1;
>  	}
