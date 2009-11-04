From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH] trivial: remove duplicated MIN macro from tehuti.
Date: Wed, 04 Nov 2009 09:36:58 +0800
Message-ID: <4AF0DABA.3070103@cn.fujitsu.com>
References: <y> <1257194714-5218-1-git-send-email-tfransosi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.com, baum@tehutinetworks.net, andy@greyhouse.net,
	davem@davemloft.net, shemminger@vyatta.com,
	apkm@linux-fundation.org, ben@decadent.org.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Thiago Farina <tfransosi@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757871AbZKCBgS@vger.kernel.org>
In-Reply-To: <1257194714-5218-1-git-send-email-tfransosi@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thiago Farina wrote:
> Since the kernel api already has the macro "min",
> just use it instead of declaring another one.
> 
> Signed-off-by: Thiago Farina <tfransosi@gmail.com>
> ---
>  drivers/net/tehuti.c |    4 ++--
>  drivers/net/tehuti.h |    2 --
>  2 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
> index ec9dfb2..8d116a9 100644
> --- a/drivers/net/tehuti.c
> +++ b/drivers/net/tehuti.c
> @@ -1878,7 +1878,7 @@ static void bdx_tx_push_desc_safe(struct bdx_priv *priv, void *data, int size)
>  			udelay(50);	/* give hw a chance to clean fifo */
>  			continue;
>  		}
> -		avail = MIN(avail, size);
> +		avail = min(avail, size);
>  		DBG("about to push  %d bytes starting %p size %d\n", avail,
>  		    data, size);
>  		bdx_tx_push_desc(priv, data, avail);
> @@ -1889,7 +1889,7 @@ static void bdx_tx_push_desc_safe(struct bdx_priv *priv, void *data, int size)
>  }
>  
>  static const struct net_device_ops bdx_netdev_ops = {
> -	.ndo_open	 	= bdx_open,
> +	.ndo_open	        = bdx_open,

  Why are you change TAB to SPACES here?

>  	.ndo_stop		= bdx_close,
>  	.ndo_start_xmit		= bdx_tx_transmit,
>  	.ndo_validate_addr	= eth_validate_addr,
> diff --git a/drivers/net/tehuti.h b/drivers/net/tehuti.h
> index 4fc875e..1241419 100644
> --- a/drivers/net/tehuti.h
> +++ b/drivers/net/tehuti.h
> @@ -76,8 +76,6 @@
>  #define FIFO_SIZE  4096
>  #define FIFO_EXTRA_SPACE            1024
>  
> -#define MIN(x, y)  ((x) < (y) ? (x) : (y))
> -
>  #if BITS_PER_LONG == 64
>  #    define H32_64(x)  (u32) ((u64)(x) >> 32)
>  #    define L32_64(x)  (u32) ((u64)(x) & 0xffffffff)


-- 
Regards
Yang Hongyang
