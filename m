From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] net/r8169: Remove the firmware of RTL8111D
Date: Wed, 1 Dec 2010 09:07:32 +0100
Message-ID: <20101201080732.GA3234@electric-eye.fr.zoreil.com>
References: <1291180966-3124-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ben Hutchings <ben@decadent.org.uk>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1291180966-3124-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
> Remove the firmware of RTL8111D from the kernel.
> The binary file of firmware would be moved to linux-firmware repository.

The driver can not simply go along when request_firmware fails. Though Ben's
code did not take care of it, the driver should imho propagate some return
code. Ben ?

There is no change in rtl8168d_3_hw_phy_config : could you add a comment
so that people know it is different ?

Could you Cc: the linux-firmware patch as well ?

Minor nit: please keep the code free of capitalized hex data.

> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 7d33ef4..cad1ba8 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
[...]
> @@ -1383,6 +1384,28 @@ static void rtl_phy_write(void __iomem *ioaddr, const struct phy_reg *regs, int
>  	}
>  }
>  
> +static void rtl_phy_write_fw(void __iomem *ioaddr, const struct firmware *fw)
> +{
[...]
> +		default:
> +			printk(KERN_WARNING "%s: Unknown action\n",
> +				__FUNCTION__);

A bit old school. It gives no information about the device.
Use netif_{err/info} or such ?

Thanks.

-- 
Ueimor
