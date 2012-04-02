From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2: dont overwrite settings for PHY Quick link
Date: Mon, 2 Apr 2012 15:38:18 -0700
Message-ID: <20120402153818.40e34c2c@s6510.linuxnetplumber.net>
References: <20120330172859.GB2703@Neptun>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120330172859.GB2703@Neptun>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 30 Mar 2012 19:28:59 +0200
Lino Sanfilippo <LinoSanfilippo@gmx.de> wrote:

> This patch corrects a bug in function sky2_open() of the Marvell Yukon 2 driver
> in which the settings for PHY quick link are overwritten.
> 
> Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
> ---
>  This applies against 3.3
> 
>  drivers/net/ethernet/marvell/sky2.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
> index 760c2b1..d0132d8 100644
> --- a/drivers/net/ethernet/marvell/sky2.c
> +++ b/drivers/net/ethernet/marvell/sky2.c
> @@ -1756,13 +1756,14 @@ static int sky2_open(struct net_device *dev)
>  
>  	sky2_hw_up(sky2);
>  
> +	/* Enable interrupts from phy/mac for port */
> +	imask = sky2_read32(hw, B0_IMSK);
> +
>  	if (hw->chip_id == CHIP_ID_YUKON_OPT ||
>  	    hw->chip_id == CHIP_ID_YUKON_PRM ||
>  	    hw->chip_id == CHIP_ID_YUKON_OP_2)
>  		imask |= Y2_IS_PHY_QLNK;	/* enable PHY Quick Link */
>  
> -	/* Enable interrupts from phy/mac for port */
> -	imask = sky2_read32(hw, B0_IMSK);
>  	imask |= portirq_msk[port];
>  	sky2_write32(hw, B0_IMSK, imask);
>  	sky2_read32(hw, B0_IMSK);

Acked-by: Stephen Hemminger <shemminger@vyattta.com>

This should go to stable as well.  Surprised that gcc did not detect
the "or" of uninitialized value.
