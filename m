From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 4/9] [TULIP] Clean tulip.h so it can be used by winbond-840.c
Date: Wed, 09 Aug 2006 01:33:18 -0400
Message-ID: <44D9739E.905@garzik.org>
References: <20060807204418.GE401@athena.road.mcmartin.ca> <11549840122892-git-send-email-kyle@parisc-linux.org> <11549840321096-git-send-email-kyle@parisc-linux.org> <1154984032324-git-send-email-kyle@parisc-linux.org> <115498403384-git-send-email-kyle@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, grundler@parisc-linux.org,
	val_henson@linux.intel.com, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:63647 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965065AbWHIFdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 01:33:21 -0400
To: Kyle McMartin <kyle@parisc-linux.org>
In-Reply-To: <115498403384-git-send-email-kyle@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kyle McMartin wrote:
> From: Grant Grundler <grundler@parisc-linux.org>
> 
> Include "tulip.h" in winbond-840.c and clean up lots of redundant
> definitions.
> 
> Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
> Signed-off-by: Kyle McMartin <kyle@parisc-linux.org>
> ---
>  drivers/net/tulip/tulip.h       |   17 ++++++----
>  drivers/net/tulip/tulip_core.c  |    7 +---
>  drivers/net/tulip/winbond-840.c |   68 ++++++++++++++-------------------------
>  3 files changed, 37 insertions(+), 55 deletions(-)
> 
> diff --git a/drivers/net/tulip/tulip.h b/drivers/net/tulip/tulip.h
> index d79c7ae..951af5e 100644
> --- a/drivers/net/tulip/tulip.h
> +++ b/drivers/net/tulip/tulip.h
> @@ -30,11 +30,10 @@ #include <asm/irq.h>
>  /* undefine, or define to various debugging levels (>4 == obscene levels) */
>  #define TULIP_DEBUG 1
>  
> -/* undefine USE_IO_OPS for MMIO, define for PIO */
>  #ifdef CONFIG_TULIP_MMIO
> -# undef USE_IO_OPS
> +#define TULIP_BAR	1	/* CBMA */
>  #else
> -# define USE_IO_OPS 1
> +#define TULIP_BAR	0	/* CBIO */
>  #endif

OK except for two things:

1) should be split up into two patches:  modify tulip, and modify winbond

2) nobody (but parisc folks?) knows what CBMA and CBIO mean.  Just use 
"MMIO" and "PIO"

