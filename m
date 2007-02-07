From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sky2: flow control off
Date: Tue, 06 Feb 2007 19:18:07 -0500
Message-ID: <45C91ABF.9030504@pobox.com>
References: <20070202153425.2d979fd4@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56660 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030289AbXBGASJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 19:18:09 -0500
In-Reply-To: <20070202153425.2d979fd4@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Turn flow control off for sky2. When flow control is on, the transmitter
> may get randomly stuck. Perhaps there is hardware problem, but until
> Marvell provides errata information for workaround, it should default to off.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> ---
>  drivers/net/sky2.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index 822dd0b..a31dea5 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -3263,7 +3263,7 @@ #endif
>  
>  	/* Auto speed and flow control */
>  	sky2->autoneg = AUTONEG_ENABLE;
> -	sky2->flow_mode = FC_BOTH;
> +	sky2->flow_mode = FC_NONE;

I ACK the patch... conditional on some -mm style testing and user ACKs.

Logic:  if there were no downsides to disabling flow control globally, 
the world's networks would have already done so.  Flow control can be 
quite helpful, so I while I understand the errata argument, I also want 
to understand the full effect of this tiny patch.

	Jeff



