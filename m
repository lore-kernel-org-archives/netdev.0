From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] [updated] PHY fixed driver: rework release path and
	update phy_id notation
Date: Thu, 19 Jul 2007 23:23:37 -0700
Message-ID: <20070719232337.184942e0.akpm@linux-foundation.org>
References: <20070718233804.24451.22543.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Vitaly Bordug <vitb@kernel.crashing.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20070718233804.24451.22543.stgit@localhost.localdomain>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Jul 2007 03:38:04 +0400 Vitaly Bordug <vitb@kernel.crashing.org> wrote:

> 
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

Confused.  Does the above refer to the difference between this patch and
the previous version, or does it just describe this patch?  Hopefully the
latter, because the former isn't interesting, long-term.

If is _is_ a full standalone description of this patch then it's a bit hard
to follow ;)

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

Shouldn't these be runtime options (ie: module parameters)?

>
> ...
>
> + *  Private information hoder for mii_bus

tpyo.
