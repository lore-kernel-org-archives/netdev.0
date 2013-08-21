From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] SH7619: fix Ether support
Date: Wed, 21 Aug 2013 18:20:54 +0400
Message-ID: <5214CCC6.8090206@cogentembedded.com>
References: <201308180213.23296.sergei.shtylyov@cogentembedded.com> <201308180215.43063.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lethal@linux-sh.org, linux-sh@vger.kernel.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201308180215.43063.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 18-08-2013 2:15, Sergei Shtylyov wrote:

> The 'sh_eth' driver's probe will crash as the platform code is hopelessly behind
> the platform data -- it passes PHY ID instead of 'struct sh_eth_plat_data *'.
> Strangely, both commit d88a3ea6fa4c (SH7619 add ethernet controler support) that
> added the platform code and commit 71557a37adb5 ([netdrvr] sh_eth: Add  SH7619
> support)  were done  in about  the same time, yet the latter one added 'struct
> sh_eth_plat_data' and the platform code didn't ever get updated...
>
> Add the proper platform data and fix off-by-one memory resource end error, while
> at it...

> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Cc: stable@vger.kernel.org

> ---
>   arch/sh/kernel/cpu/sh2/setup-sh7619.c |   12 ++++++++++--
>   1 file changed, 10 insertions(+), 2 deletions(-)

> Index: net/arch/sh/kernel/cpu/sh2/setup-sh7619.c
> ===================================================================
> --- net.orig/arch/sh/kernel/cpu/sh2/setup-sh7619.c
> +++ net/arch/sh/kernel/cpu/sh2/setup-sh7619.c
[...]
> @@ -110,10 +111,17 @@ static struct platform_device scif2_devi
>   	},
>   };
>
> +static struct sh_eth_plat_data eth_platform_data = {
> +	.phy		= 1,
> +	.edmac_endian	= EDMAC_LITTLE_ENDIAN,
> +	.register_type	= SH_ETH_REG_FAST_SH3_SH2,
> +	.phy_interace	= PHY_INTERFACE_MODE_MII,

    Grr, I forgot to compile test this patch as the kbuild test robot just 
told me... s/phy_interace/phy_interface/. I'll send a fix today.

WBR, Sergei

