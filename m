From: Shaw Vrana <shaw@vranix.com>
Subject: Re: [PATCH 11/22] e1000: Fire a link even interrupt instead of a watchdog at init.
Date: Mon, 11 Dec 2006 14:48:17 -0800
Message-ID: <20061211224817.GA3390@gmail.com>
References: <20061208230209.30109.49157.stgit@gitlost.site> <20061208230309.30109.51216.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.227]:40926 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937700AbWLKWsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 17:48:23 -0500
Received: by wr-out-0506.google.com with SMTP id i7so1826433wra
        for <netdev@vger.kernel.org>; Mon, 11 Dec 2006 14:48:23 -0800 (PST)
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Content-Disposition: inline
In-Reply-To: <20061208230309.30109.51216.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 08, 2006 at 03:03:09PM -0800, Kok, Auke wrote:
> 
> Instead of calling a watchdog event we let our interrupt handler
> cascade a link event. This allows us to spot link up immediately
> after _up() without racing against a new watchdog.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000/e1000_main.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index 0ebd8e2..c5c764f 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -558,7 +558,8 @@ e1000_up(struct e1000_adapter *adapter)
>  
>  	clear_bit(__E1000_DOWN, &adapter->flags);
>  
> -	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
> +	/* fire a link change interrupt to start the watchdog */
> +	E1000_WRITE_REG(&adapter->hw, ICS, E1000_ICS_LSC);
>  	return 0;
>  }

Hi Auke,

Could you explain the race, how it would be triggered, and what it might
look like if it were to occur?

Thanks,
Shaw
