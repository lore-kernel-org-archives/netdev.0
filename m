From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] can: CAN_MCP251X should depend on HAS_DMA
Date: Sun, 13 Dec 2009 21:47:04 +0100
Message-ID: <4B2552C8.4090105@grandegger.com>
References: <alpine.DEB.2.00.0912132008100.21225@ayla.of.borg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Christian Pellegrin <chripell@fsfe.org>,
	"David S. Miller" <davem@davemloft.net>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	netdev@vger.kernel.org,
	Linux Kernel Development <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754189AbZLMUr5@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.0912132008100.21225@ayla.of.borg>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Geert Uytterhoeven wrote:
> When building for Sun 3:
> 
> drivers/net/can/mcp251x.c:1074: undefined reference to `dma_free_coherent'
> drivers/net/can/mcp251x.c:976: undefined reference to `dma_alloc_coherent'
> drivers/net/can/mcp251x.c:1050: undefined reference to `dma_free_coherent'
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> ---
>  drivers/net/can/Kconfig |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index 8c485aa..05b7517 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -50,7 +50,7 @@ config CAN_TI_HECC
>  
>  config CAN_MCP251X
>  	tristate "Microchip MCP251x SPI CAN controllers"
> -	depends on CAN_DEV && SPI
> +	depends on CAN_DEV && SPI && HAS_DMA
>  	---help---
>  	  Driver for the Microchip MCP251x SPI CAN controllers.
>  

DMA can be selected with the module parameter "mcp251x_enable_dma" and
is *off* by default. Therefore the driver does in principle not depend
on HAS_DMA but I'm not sure if it's worth to handle it with #idef's.
Christian? Any thought?

Wolfgang.
