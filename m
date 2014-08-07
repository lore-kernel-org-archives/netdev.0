From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] smsc: Undefine SMC_inb and SMC_outb before define
Date: Thu, 7 Aug 2014 13:55:57 +0100
Message-ID: <20140807125557.GL13703@arm.com>
References: <1407392942-22183-1-git-send-email-xerofoiify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nico@fluxnic.net>,
	"David S. Miller" <davem@davemloft.net>,
	Linus Walleij <linus.walleij@linaro.org>,
	Ben Boeckel <mathstuf@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Michael Opdenacker <michael.opdenacker@free-electrons.com>,
	"open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Nick Krause <xerofoiify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1407392942-22183-1-git-send-email-xerofoiify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 07, 2014 at 07:29:00AM +0100, Nick Krause wrote:
> Undefine SMC_inb and SMC_outb before redifing to prevent warning which follows
> 
> drivers/net/ethernet/smsc/smc91x.h:490:0: warning: "SMC_inb" redefined [enabled by default]
> drivers/net/ethernet/smsc/smc91x.h:199:0: note: this is the location of the previous definition
> drivers/net/ethernet/smsc/smc91x.h:491:0: warning: "SMC_outb" redefined [enabled by default]
> drivers/net/ethernet/smsc/smc91x.h:201:0: note: this is the location of the previous definition
> 
> Signed-off-by: Nick Krause <xerofoify@gmail.com>
> ---
>  drivers/net/ethernet/smsc/smc91x.h | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
> index 47dce91..d1c5441 100644
> --- a/drivers/net/ethernet/smsc/smc91x.h
> +++ b/drivers/net/ethernet/smsc/smc91x.h
> @@ -487,6 +487,8 @@ smc_pxa_dma_irq(int dma, void *dummy)
>  #endif
>  
>  #if ! SMC_CAN_USE_8BIT
> +#undef  SMC_inb
> +#undef  SMC_outb
>  #define SMC_inb(ioaddr, reg)		({ BUG(); 0; })
>  #define SMC_outb(x, ioaddr, reg)	BUG()
>  #define SMC_insb(a, r, p, l)		BUG()

Nak. The real issue here appears to be that the CONFIG_M32R code defines
SMC_CAN_USE_8BIT as 0 but then defines SMC_inb/SMC_outb anyway.

Will
