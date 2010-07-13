From: Dan Carpenter <error27@gmail.com>
Subject: Re: [PATCH] eth16i: fix memory leak
Date: Tue, 13 Jul 2010 13:43:47 +0200
Message-ID: <20100713114347.GK5658@bicker>
References: <1279020138-9398-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org, Mika Kuoppala <miku@iki.fi>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tejun Heo <tj@kernel.org>, Jiri Pirko <jpirko@redhat.com>,
	netdev@vger.kernel.org
To: Kulikov Vasiliy <segooon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:41669 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752598Ab0GMLpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 07:45:41 -0400
Content-Disposition: inline
In-Reply-To: <1279020138-9398-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 13, 2010 at 03:22:18PM +0400, Kulikov Vasiliy wrote:
> Free allocated netdev if no probe is expected.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
> ---
>  drivers/net/eth16i.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/eth16i.c b/drivers/net/eth16i.c
> index 874973f..2bdd394 100644
> --- a/drivers/net/eth16i.c
> +++ b/drivers/net/eth16i.c
> @@ -1442,8 +1442,10 @@ int __init init_module(void)
>  		dev->if_port = eth16i_parse_mediatype(mediatype[this_dev]);
>  
>  		if(io[this_dev] == 0) {
> -			if(this_dev != 0) /* Only autoprobe 1st one */
> +			if (this_dev != 0) { /* Only autoprobe 1st one */
> +				free_netdev(def);
					    ^^^
				free_netdev(dev);

regards,
dan carpenter

>  				break;
> +			}
>  
>  			printk(KERN_NOTICE "eth16i.c: Presently autoprobing (not recommended) for a single card.\n");
>  		}
> -- 

