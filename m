From: Subrata Modak <subrata@linux.vnet.ibm.com>
Subject: Re: [PATCH][BUILD FAILURE 03/04] Next June 04:PPC64 randconfig
	[drivers/net/lance.o]
Date: Mon, 15 Jun 2009 12:21:38 +0530
Message-ID: <1245048698.5239.9.camel@subratamodak.linux.ibm.com>
References: <20090611035046.22125.26641.sendpatchset@subratamodak.linux.ibm.com>
Reply-To: subrata@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	Linuxppc-dev <Linuxppc-dev@ozlabs.org>,
	Sachin P Sant <sachinp@linux.vnet.ibm.com>,
	Linux-Kernel <linux-kernel@vger.kernel.org>,
	Linux-Next <linux-next@vger.kernel.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Balbir Singh <balbir@linux.vnet.ibm.com>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090611035046.22125.26641.sendpatchset@subratamodak.linux.ibm.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thu, 2009-06-11 at 09:20 +0530, Subrata Modak wrote: 
> Hi Benjamin/Paul,
> 
> >On Thu, 2009-06-04 at 19:02 +0530, Subrata Modak wrote:
> >CC      drivers/net/lance.o
> > drivers/net/lance.c: In function 'lance_probe1':
> > drivers/net/lance.c:575: error: implicit declaration of function 'isa_virt_to_bus'
> > drivers/net/lance.c: In function 'lance_rx':
> > drivers/net/lance.c:1197: error: implicit declaration of function 'isa_bus_to_virt'
> > make[2]: *** [drivers/net/lance.o] Error 1
> > make[1]: *** [drivers/net] Error 2
> > make: *** [drivers] Error 2
> 
> Reference: http://lkml.org/lkml/2009/6/4/240,
> To fix the following build error:
> 
> drivers/net/lance.c: In function 'lance_probe1':
> drivers/net/lance.c:575: error: implicit declaration of function 'isa_virt_to_bus'
> drivers/net/lance.c: In function 'lance_rx':
> drivers/net/lance.c:1197: error: implicit declaration of function 'isa_bus_to_virt'
> make[2]: *** [drivers/net/lance.o] Error 1
> make[1]: *** [drivers/net] Error 2
> make: *** [drivers] Error 2
> 
> I would like to propose the following patch. The prototypes for the functions:
> 'isa_virt_to_bus' & 'isa_virt_to_bus' are existing for some archs like the
> mips, x86, parisc, arm & alpha, but, is missing for powerpc. Is it safe to
> introduce the following soultion for powerpc ? It fixes the build problem
> i reported earlier.
> 
> Signed-off-by: Subrata Modak <subrata@linux.vnet.ibm.com>
> ---

Benjamin,

I am not sure whether you liked the following patch to solve the above
problem. Do, you want me address some other issue(s)/fixes for this ?

Regards--
Subrata

> 
> --- linux-2.6.30-rc8/arch/powerpc/include/asm/io.h.orig	2009-06-10 21:56:49.000000000 -0500
> +++ linux-2.6.30-rc8/arch/powerpc/include/asm/io.h	2009-06-10 22:21:35.000000000 -0500
> @@ -680,6 +680,9 @@ extern void __iounmap_at(void *ea, unsig
>  #define mmio_outsw(addr, src, count)	writesw(addr, src, count)
>  #define mmio_outsl(addr, src, count)	writesl(addr, src, count)
> 
> +#define isa_virt_to_bus		virt_to_phys
> +#define isa_bus_to_virt		phys_to_virt
> +
>  /**
>   *	virt_to_phys	-	map virtual addresses to physical
>   *	@address: address to remap
> 
> ---
> Regards--
> Subrata
> 
