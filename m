From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] net: phy: balance disable/enable irq on change
Date: Sat, 18 Dec 2010 16:47:12 +0000
Message-ID: <1292690832.6533.39.camel@localhost>
References: <1292687723-31981-1-git-send-email-jhautbois@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, richard.cochran@omicron.at,
	shemminger@vyatta.com, tj@kernel.org, randy.dunlap@oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jean-Michel Hautbois <jhautbois@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1292687723-31981-1-git-send-email-jhautbois@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2010-12-18 at 16:55 +0100, Jean-Michel Hautbois wrote:
> When phy interface changes its status, it calls phy_change() function.
> This function calls the interrupt disabling functions for the driver registered, but if this driver doesn't implement it, there is no IRQ disabling. After doing the work, we call enable_irq and not the respective driver function. This fixes it, as it could lead to an unbalanced IRQ.
> 
> Signed-off-by: Jean-Michel Hautbois <jhautbois@gmail.com>
> ---
>  drivers/net/phy/phy.c |   12 ++++++++++--
>  1 files changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 7670aac..b28f2ac 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -89,7 +89,8 @@ static int phy_config_interrupt(struct phy_device *phydev, u32 interrupts)
>  	phydev->interrupts = interrupts;
>  	if (phydev->drv->config_intr)
>  		err = phydev->drv->config_intr(phydev);
> -
> +	else
> +		err = -ENOSYS;
[...]

ENOSYS means missing system call.  Perhaps EOPNOTSUPP is the appropriate
error code.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
