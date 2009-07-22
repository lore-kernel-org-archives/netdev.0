From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] NET / skge: Enable WoL by default if supported
Date: Wed, 22 Jul 2009 09:59:53 -0700
Message-ID: <20090722095953.0806bea2@nehalam>
References: <200907221458.55616.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	pm list <linux-pm@lists.linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Michael Guntsche <mike@it-loops.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753841AbZGVRAE@vger.kernel.org>
In-Reply-To: <200907221458.55616.rjw@sisk.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 22 Jul 2009 14:58:55 +0200
"Rafael J. Wysocki" <rjw@sisk.pl> wrote:

> From: Rafael J. Wysocki <rjw@sisk.pl>
> 
> If skge hardware is capable of waking up the system from sleep,
> enable magic packet WoL during driver initialisation.
> 
> This makes WoL work without calling 'ethtool -s ethX wol g'
> for each adapter.
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> Tested-by: Michael Guntsche <mike@it-loops.com>
> ---
>  drivers/net/skge.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6/drivers/net/skge.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/skge.c
> +++ linux-2.6/drivers/net/skge.c
> @@ -3856,8 +3856,10 @@ static struct net_device *skge_devinit(s
>  	skge->speed = -1;
>  	skge->advertising = skge_supported_modes(hw);
>  
> -	if (device_may_wakeup(&hw->pdev->dev))
> +	if (device_can_wakeup(&hw->pdev->dev)) {
>  		skge->wol = wol_supported(hw) & WAKE_MAGIC;
> +		device_set_wakeup_enable(&hw->pdev->dev, skge->wol);
> +	}
>  
>  	hw->dev[port] = dev;
>  

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
-- 
