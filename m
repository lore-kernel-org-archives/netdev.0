From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH] ks8851: Fix missing mutex_lock/unlock
Date: Thu, 12 Apr 2012 21:22:13 -0300
Message-ID: <20120412212213.746ec2e2@asterix.rh>
References: <1334272530-11119-1-git-send-email-mjr@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, sboyd@codeaurora.org, ben@simtec.co.uk,
	bhutchings@solarflare.com, netdev@vger.kernel.org
To: mjr@cs.wisc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63110 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756986Ab2DMAWh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 20:22:37 -0400
In-Reply-To: <1334272530-11119-1-git-send-email-mjr@cs.wisc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Apr 2012 18:15:30 -0500
mjr@cs.wisc.edu wrote:

> From: Matt Renzelmann <mjr@cs.wisc.edu>
> 
> All calls to ks8851_rdreg* and ks8851_wrreg* should be protected with
> the driver's lock mutex.  A spurious interrupt may otherwise cause a
> crash.  Thanks to Stephen Boyd, Flavio Leitner, and Ben Hutchings for
> feedback.
> 
> Signed-off-by: Matt Renzelmann <mjr@cs.wisc.edu>
> ---
> 
> This modified version incorporates Ben Hutchings' bugfix by removing
> the incorrect call to CIDER_REV_GET.
> 
>  drivers/net/ethernet/micrel/ks8851.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
> index c722aa6..e5dc075 100644
> --- a/drivers/net/ethernet/micrel/ks8851.c
> +++ b/drivers/net/ethernet/micrel/ks8851.c
> @@ -1418,6 +1418,7 @@ static int __devinit ks8851_probe(struct spi_device *spi)
>  	struct net_device *ndev;
>  	struct ks8851_net *ks;
>  	int ret;
> +	unsigned cider;


Basically what I have proposed, but I used 'unsigned int cider'.
Anyway, the driver uses just 'unsigned' everywhere.

Signed-off-by: Flavio Leitner <fbl@redhat.com>
