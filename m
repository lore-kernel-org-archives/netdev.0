From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] bcm43xx_d80211: Fix major memory corruption bug
Date: Tue, 23 Jan 2007 11:06:52 +0100
Message-ID: <200701231106.52788.mb@bu3sch.de>
References: <20070121052740.7299.29574.stgit@dv.roinet.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:47300
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932932AbXAWKIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 05:08:11 -0500
To: Pavel Roskin <proski@gnu.org>
In-Reply-To: <20070121052740.7299.29574.stgit@dv.roinet.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 21 January 2007 06:27, Pavel Roskin wrote:
> Set phy->lo_control to NULL whenever it's freed.  Failure to do so leads
> to zeroing a block of memory that uses to hold *phy->lo_control, which
> caused random crashes down the road.
> 
> Signed-off-by: Pavel Roskin <proski@gnu.org>

Applied, thanks.

> ---
> 
>  drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
> index 3064322..62d4dc9 100644
> --- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
> +++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
> @@ -3048,6 +3048,7 @@ static void bcm43xx_wireless_core_exit(struct bcm43xx_wldev *dev)
>  	if (phy->dyn_tssi_tbl)
>  		kfree(phy->tssi2dbm);
>  	kfree(phy->lo_control);
> +	phy->lo_control = NULL;
>  	ssb_chipco_set_clockmode(chipco, SSB_CLKMODE_SLOW);
>  	bcm43xx_vstack_free(&dev->genstack);
>  	bcm43xx_set_status(dev, BCM43xx_STAT_UNINIT);
> @@ -3179,6 +3180,7 @@ err_kfree_tssitbl:
>  		kfree(phy->tssi2dbm);
>  err_kfree_lo_control:
>  	kfree(phy->lo_control);
> +	phy->lo_control = NULL;
>  err_slowclock:
>  	ssb_chipco_set_clockmode(chipco, SSB_CLKMODE_SLOW);
>  	bcm43xx_set_status(dev, BCM43xx_STAT_UNINIT);
> 
> 
> 

-- 
Greetings Michael.
