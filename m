From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.25] igb: fix legacy mode irq issue
Date: Fri, 15 Feb 2008 10:54:34 -0500
Message-ID: <47B5B5BA.9020807@garzik.org>
References: <20080214031920.GI856@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Auke Kok <auke-jan.h.kok@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52975 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752178AbYBOPyg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2008 10:54:36 -0500
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

ACK from Auke?  (apologies if I missed it...)


