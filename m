From: Nicolas Pitre <nico@fluxnic.net>
Subject: Re: [PATCH] net: smsc: remove build warning of duplicate
 definition
Date: Wed, 31 Aug 2016 13:40:04 -0400 (EDT)
Message-ID: <alpine.LFD.2.20.1608311337570.14769@knanqh.ubzr>
References: <1472664459-26169-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472664459-26169-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 31 Aug 2016, Sudip Mukherjee wrote:

> The build of m32r was giving warning:
> 
> In file included from drivers/net/ethernet/smsc/smc91x.c:92:0:
> drivers/net/ethernet/smsc/smc91x.h:448:0: warning: "SMC_inb" redefined
>  #define SMC_inb(ioaddr, reg)  ({ BUG(); 0; })
>  
> drivers/net/ethernet/smsc/smc91x.h:106:0:
> 	note: this is the location of the previous definition
>  #define SMC_inb(a, r)  inb(((u32)a) + (r))
>  
> drivers/net/ethernet/smsc/smc91x.h:449:0: warning: "SMC_outb" redefined
>  #define SMC_outb(x, ioaddr, reg) BUG()
>  
> drivers/net/ethernet/smsc/smc91x.h:108:0:
> 	note: this is the location of the previous definition
>  #define SMC_outb(v, a, r) outb(v, ((u32)a) + (r))
> 
> Signed-off-by: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>
> ---
> 
> m32r allmodconfig build of next-20160825 is at:
> https://travis-ci.org/sudipm-mukherjee/parport/jobs/154943795
> 
>  drivers/net/ethernet/smsc/smc91x.h | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
> index 1a55c79..0b0bb74 100644
> --- a/drivers/net/ethernet/smsc/smc91x.h
> +++ b/drivers/net/ethernet/smsc/smc91x.h
> @@ -445,7 +445,14 @@ smc_pxa_dma_insw(void __iomem *ioaddr, struct smc_local *lp, int reg, int dma,
>  #endif
>  
>  #if ! SMC_CAN_USE_8BIT
> +#ifdef SMC_inb
> +#undef SMC_inb
> +#endif
>  #define SMC_inb(ioaddr, reg)		({ BUG(); 0; })
> +
> +#ifdef SMC_outb
> +#undef SMC_outb
> +#endif

Please just do the undef without any conditional.



>  #define SMC_outb(x, ioaddr, reg)	BUG()
>  #define SMC_insb(a, r, p, l)		BUG()
>  #define SMC_outsb(a, r, p, l)		BUG()
> -- 
> 1.9.1
> 
> 
