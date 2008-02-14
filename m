From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 2.6.25] igb: fix legacy mode irq issue
Date: Thu, 14 Feb 2008 09:24:06 -0800
Message-ID: <47B47936.505@intel.com>
References: <20080214031920.GI856@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Auke Kok <auke-jan.h.kok@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:15456 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752180AbYBNRZM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2008 12:25:12 -0500
In-Reply-To: <20080214031920.GI856@gospo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek wrote:
> I booted an igb kernel with the option pci=nomsi and instantly noticed
> that interrupts no longer worked on my igb device.  I took a look at the
> interrupt initialization and quickly discovered a comment stating:
> 
> "DO NOT USE EIAME or IAME in legacy mode"
> 
> It seemed a bit odd that bits to enable IAM were being set in legacy
> interrupt mode, so I dropped out the following parts and interrupts
> began working fine again.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

looks valid, I'll test and see, thanks Andy

Auke


> ---
> 
>  igb_main.c |    3 ---
>  1 files changed, 3 deletions(-)
> 
> diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
> index f3c144d..be5da09 100644
> --- a/drivers/net/igb/igb_main.c
> +++ b/drivers/net/igb/igb_main.c
> @@ -472,9 +471,6 @@ static int igb_request_irq(struct igb_adapter *adapter)
>  		goto request_done;
>  	}
>  
> -	/* enable IAM, auto-mask */
> -	wr32(E1000_IAM, IMS_ENABLE_MASK);
> -
>  request_done:
>  	return err;
>  }
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

