From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 3/4] sky2: Hold RTNL while calling dev_close()
Date: Tue, 6 May 2008 13:26:53 -0700
Message-ID: <20080506132653.43806b1b@extreme>
References: <20080506182654.GF2217@solarflare.com>
	<20080506183958.GI2217@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33205 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755600AbYEFU17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 16:27:59 -0400
In-Reply-To: <20080506183958.GI2217@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 6 May 2008 19:39:58 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> dev_close() must be called holding the RTNL.  Compile-tested only.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/sky2.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index f226bca..9b046dd 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -2952,7 +2952,9 @@ static void sky2_restart(struct work_struct *work)
>  			if (err) {
>  				printk(KERN_INFO PFX "%s: could not restart %d\n",
>  				       dev->name, err);
> +				rtnl_lock();
>  				dev_close(dev);
> +				rtnl_unlock();
>  			}
>  		}
>  	}
> 

Ack, but this is in a real corner case so no need to send it to stable.
