From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] kill massive wireless-related log spam
Date: Wed, 26 Oct 2005 17:04:14 +0200
Message-ID: <200510261704.15366.ak@suse.de>
References: <20051026042827.GA22836@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@osdl.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jketreno@linux.intel.com,
	Andrew Morton <akpm@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964780AbVJZPD1@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20051026042827.GA22836@havoc.gtf.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 26 October 2005 06:28, Jeff Garzik wrote:

> Change this to printing out the message once, per kernel boot.

It doesn't do that. It prints it once every 2^32 calls. Also
the ++ causes unnecessary dirty cache lines in normal operation.

-Andi
> 
> diff --git a/net/core/wireless.c b/net/core/wireless.c
> index d17f158..271ddb3 100644
> --- a/net/core/wireless.c
> +++ b/net/core/wireless.c
> @@ -455,10 +455,15 @@ static inline struct iw_statistics *get_
>  
>  	/* Old location, field to be removed in next WE */
>  	if(dev->get_wireless_stats) {
> -		printk(KERN_DEBUG "%s (WE) : Driver using old /proc/net/wireless support, please fix driver !\n",
> -		       dev->name);
> +		static int printed_message;
> +
> +		if (!printed_message++)
> +			printk(KERN_DEBUG "%s (WE) : Driver using old /proc/net/wireless support, please fix driver !\n",
> +				dev->name);
> +
>  		return dev->get_wireless_stats(dev);
>  	}
> +
