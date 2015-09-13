From: Petr Cvek <petr.cvek@tul.cz>
Subject: Re: [PATCH v2 2/3] net: irda: pxaficp_ir: convert to readl and writel
Date: Sun, 13 Sep 2015 03:34:46 +0200
Message-ID: <55F4D2B6.7020605@tul.cz>
References: <1442058324-9760-1-git-send-email-robert.jarzmik@free.fr>
 <1442058324-9760-2-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
To: Robert Jarzmik <robert.jarzmik@free.fr>,
	Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442058324-9760-2-git-send-email-robert.jarzmik@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dne 12.9.2015 v 13:45 Robert Jarzmik napsal(a):
> Convert the pxa IRDA driver to readl and writel primitives, and remove
> another set of direct registers access. This leaves only the DMA
> registers access, which will be dealt with dmaengine conversion.
> 
> Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
> ---
> Since v1: modified __REG macro to cope with STIER, ST* registers
> ---
>  drivers/net/irda/pxaficp_ir.c | 210 +++++++++++++++++++++++++-----------------
>  1 file changed, 126 insertions(+), 84 deletions(-)
> 
> diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/net/irda/pxaficp_ir.c
> index b1794998c68e..4a2b3f71e4a8 100644
> --- a/drivers/net/irda/pxaficp_ir.c
> +++ b/drivers/net/irda/pxaficp_ir.c
> @@ -29,15 +29,16 @@
>  
>  #include <mach/dma.h>
>  #include <linux/platform_data/irda-pxaficp.h>
> +#undef __REG
> +#define __REG(x) ((x) & 0xffff)
>  #include <mach/regs-uart.h>
What are future plans for the definitions in the mach/regs-uart.h ? Maybe it would be better to duplicate register definition in ficp source code (it seems that normal PXA UART driver does not use these ones). But random searches shows, that at least base address register:

	#define STUART          STRBR
	#define STRBR           __REG(0x40700000)  /* Receive Buffer Register (read only) */

is used in machine init source codes. I can look at it in the "near" future (if I don't forget :-D).

In other case patchset works, as it has been tested for SIR part.

Tested-by: Petr Cvek <petr.cvek@tul.cz>
