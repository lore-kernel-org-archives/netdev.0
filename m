From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] PHY fixed driver: rework release path and update phy_id
 notation
Date: Wed, 18 Jul 2007 18:35:54 -0400
Message-ID: <469E95CA.8000800@garzik.org>
References: <20070717000723.8144.19520.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Vitaly Bordug <vitb@kernel.crashing.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933702AbXGRWgW@vger.kernel.org>
In-Reply-To: <20070717000723.8144.19520.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vitaly Bordug wrote:
> device_bind_driver() error code returning has been fixed.  
> release() function has been written, so that to free resources 
> in correct way; the release path is now clean. 
>  
> Before the rework, it used to cause 
>  Device 'fixed@100:1' does not have a release() function, it is broken 
>  and must be fixed. 
>  BUG: at drivers/base/core.c:104 device_release() 
>   
>  Call Trace:   
>   [<ffffffff802ec380>] kobject_cleanup+0x53/0x7e 
>   [<ffffffff802ec3ab>] kobject_release+0x0/0x9 
>   [<ffffffff802ecf3f>] kref_put+0x74/0x81 
>   [<ffffffff8035493b>] fixed_mdio_register_device+0x230/0x265 
>   [<ffffffff80564d31>] fixed_init+0x1f/0x35 
>   [<ffffffff802071a4>] init+0x147/0x2fb 
>   [<ffffffff80223b6e>] schedule_tail+0x36/0x92 
>   [<ffffffff8020a678>] child_rip+0xa/0x12 
>   [<ffffffff80311714>] acpi_ds_init_one_object+0x0/0x83 
>   [<ffffffff8020705d>] init+0x0/0x2fb 
>   [<ffffffff8020a66e>] child_rip+0x0/0x12   
>  
>  
> Also changed the notation of the fixed phy definition on 
> mdio bus to the form of <speed>+<duplex> to make it able to be used by 
> gianfar and ucc_geth that define phy_id strictly as "%d:%d" and cleaned up 
> the whitespace issues.
>  
> Signed-off-by: Vitaly Bordug <vitb@kernel.crashing.org>
> 
> ---
> 
>  drivers/net/phy/Kconfig |   14 ++
>  drivers/net/phy/fixed.c |  310 ++++++++++++++++++++++++-----------------------
>  2 files changed, 169 insertions(+), 155 deletions(-)
> 
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index dd09011..432c210 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -76,4 +76,18 @@ config FIXED_MII_100_FDX
>  	bool "Emulation for 100M Fdx fixed PHY behavior"
>  	depends on FIXED_PHY
>  
> +config FIXED_MII_1000_FDX
> +	bool "Emulation for 1000M Fdx fixed PHY behavior"
> +	depends on FIXED_PHY
> +
> +config FIXED_MII_AMNT
> +        int "Number of emulated PHYs to allocate "
> +        depends on FIXED_PHY
> +        default "1"
> +        ---help---
> +        Sometimes it is required to have several independent emulated
> +        PHYs on the bus (in case of multi-eth but phy-less HW for instance).
> +        This control will have specified number allocated for each fixed
> +        PHY type enabled.

addition of new config options etc. should be in a separate patch from 
the fix, since they are separate logical changes
