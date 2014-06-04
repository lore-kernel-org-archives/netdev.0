From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: Re: [PATCH] sh_eth: fix SH7619/771x support
Date: Wed, 4 Jun 2014 09:34:56 +0900
Message-ID: <538E69B0.1030706@renesas.com>
References: <201406032342.27160.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor3.renesas.com ([210.160.252.173]:55788 "EHLO
	relmlie2.idc.renesas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751833AbaFDAfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 20:35:02 -0400
In-Reply-To: <201406032342.27160.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,

Thank you for the patch!

(2014/06/04 4:42), Sergei Shtylyov wrote:
> Commit 4a55530f38e4 (net: sh_eth: modify the definitions of register) managed
> to leave out the E-DMAC register entries in sh_eth_offset_fast_sh3_sh2[], thus
> totally breaking SH7619/771x support.  Add the missing entries using  the data
> from before that commit.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> ---
> The patch is against Dave Miller's 'net.git' repo.
> Although there have been no complaints during 3+ years of this being broken, I
> think it's probably worth queuing the patch for the stable trees...
> 
>  drivers/net/ethernet/renesas/sh_eth.c |   21 +++++++++++++++++++++
>  1 file changed, 21 insertions(+)
> 
> Index: net/drivers/net/ethernet/renesas/sh_eth.c
> ===================================================================
> --- net.orig/drivers/net/ethernet/renesas/sh_eth.c
> +++ net/drivers/net/ethernet/renesas/sh_eth.c
> @@ -307,6 +307,27 @@ static const u16 sh_eth_offset_fast_sh4[
>  };
>  
>  static const u16 sh_eth_offset_fast_sh3_sh2[SH_ETH_MAX_REGISTER_OFFSET] = {
> +	[EDMR]		= 0x0000,
> +	[EDTRR]		= 0x0004,
> +	[EDRRR]		= 0x0008,
> +	[TDLAR]		= 0x000c,
> +	[RDLAR]		= 0x0010,
> +	[EESR]		= 0x0014,
> +	[EESIPR]	= 0x0018,
> +	[TRSCER]	= 0x001c,
> +	[RMFCR]		= 0x0020,
> +	[TFTR]		= 0x0024,
> +	[FDR]		= 0x0028,
> +	[RMCR]		= 0x002c,
> +	[EDOCR]		= 0x0030,
> +	[FCFTR]		= 0x0034,
> +	[RPADIR]	= 0x0038,

I checked sh7710 and sh7619 datasheet, but they don't have RPADIR register.
Since I would like to check a datasheet you looked into, would you tell me about this?

Best regards,
Yoshihiro Shimoda

> +	[TRIMD]		= 0x003c,
> +	[RBWAR]		= 0x0040,
> +	[RDFAR]		= 0x0044,
> +	[TBRAR]		= 0x004c,
> +	[TDFAR]		= 0x0050,
> +
>  	[ECMR]		= 0x0160,
>  	[ECSR]		= 0x0164,
>  	[ECSIPR]	= 0x0168,
> 
