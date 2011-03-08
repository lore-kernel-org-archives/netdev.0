From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] cnic: fix double initalization of bnx2 based cards
Date: Tue, 08 Mar 2011 18:59:28 +0000
Message-ID: <1299610768.4957.1.camel@bwh-desktop>
References: <1299610588-22356-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Eddie Wai <waie@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:18904 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261Ab1CHS7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 13:59:32 -0500
In-Reply-To: <1299610588-22356-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-03-08 at 13:56 -0500, Neil Horman wrote:
> bnx2 cards can work with the cnic driver, but when the cnic driver detects a
> bnx2 card, is_cnic_dev erroneously calls the initalization routines for both
> bnx2 and bnx2x (the former being a regex subset of the later).

Since when does strcmp() do a regex match?

And why is a function named 'is_cnic_dev' doing initialisation, anyway?

Ben.

>   This causes
> initalization of bnx2 to unilaterally fail in the cnic driver, which, while not
> catastrophic, is definately not expected.  Fix this by choosing either the bnx2
> or bnx2x initalization path, not both
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Michael Chan <mchan@broadcom.com>
> CC: Dmitry Kravkov <dmitry@broadcom.com>
> CC: Eddie Wai <waie@broadcom.com>
> CC: Eilon Greenstein <eilong@broadcom.com>
> ---
>  drivers/net/cnic.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
> index 271a1f0..18b59ad 100644
> --- a/drivers/net/cnic.c
> +++ b/drivers/net/cnic.c
> @@ -5292,7 +5292,7 @@ static struct cnic_dev *is_cnic_dev(struct net_device *dev)
>  
>  		if (!strcmp(drvinfo.driver, "bnx2"))
>  			cdev = init_bnx2_cnic(dev);
> -		if (!strcmp(drvinfo.driver, "bnx2x"))
> +		else if (!strcmp(drvinfo.driver, "bnx2x"))
>  			cdev = init_bnx2x_cnic(dev);
>  		if (cdev) {
>  			write_lock(&cnic_dev_lock);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

