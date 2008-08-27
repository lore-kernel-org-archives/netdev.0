From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 4/4] LCS recovery dumps when cable reconnect
Date: Wed, 27 Aug 2008 05:19:32 -0400
Message-ID: <48B51C24.8050400@pobox.com>
References: <20080821151021.069615000@linux.vnet.ibm.com> <20080821151654.326848000@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	"Klaus-D. Wacker" <kdwacker@de.ibm.com>
To: Ursula Braun <ursula.braun@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45272 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753843AbYH0JTh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 05:19:37 -0400
In-Reply-To: <20080821151654.326848000@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ursula Braun wrote:
> From: Klaus-D. Wacker <kdwacker@de.ibm.com>
> 
> LCS recovery dumps in irq routine when CCW address in
> Subchannel Status Word (SCSW) is zero. This occurs
> when recovery is driven after cable reconnect.
> 
> Signed-off-by: Klaus-D. Wacker <kdwacker@de.ibm.com>
> Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
> ---
> 
>  drivers/s390/net/lcs.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff -urpN linux-2.6/drivers/s390/net/lcs.c linux-2.6-patched/drivers/s390/net/lcs.c
> --- linux-2.6/drivers/s390/net/lcs.c	2008-08-20 15:54:46.000000000 +0200
> +++ linux-2.6-patched/drivers/s390/net/lcs.c	2008-08-20 15:55:15.000000000 +0200
> @@ -1412,7 +1412,8 @@ lcs_irq(struct ccw_device *cdev, unsigne
>  	}
>  	/* How far in the ccw chain have we processed? */
>  	if ((channel->state != LCS_CH_STATE_INIT) &&
> -	    (irb->scsw.cmd.fctl & SCSW_FCTL_START_FUNC)) {
> +	    (irb->scsw.cmd.fctl & SCSW_FCTL_START_FUNC) &&
> +	    (irb->scsw.cmd.cpa != 0)) {
>  		index = (struct ccw1 *) __va((addr_t) irb->scsw.cmd.cpa)

applied 1-4


