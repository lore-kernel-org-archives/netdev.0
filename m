From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sky2: Hold RTNL while calling dev_close() [2nd try]
Date: Tue, 10 Jun 2008 18:40:55 -0400
Message-ID: <484F02F7.50905@pobox.com>
References: <20080506182654.GF2217@solarflare.com> <20080506183958.GI2217@solarflare.com> <20080506161720.6475e5d4@extreme> <20080506235937.GK2217@solarflare.com> <20080531155251.GM1743@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40408 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754050AbYFJWlG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 18:41:06 -0400
In-Reply-To: <20080531155251.GM1743@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> dev_close() must be called holding the RTNL.  Compile-tested only.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/sky2.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index f226bca..b9bdf88 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -4395,7 +4395,9 @@ static int sky2_resume(struct pci_dev *pdev)
>  			if (err) {
>  				printk(KERN_ERR PFX "%s: could not up: %d\n",
>  				       dev->name, err);
> +				rtnl_lock();
>  				dev_close(dev);
> +				rtnl_unlock();
>  				goto out;

applied


