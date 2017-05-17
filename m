From: walter harms <wharms@bfs.de>
Subject: Re: [PATCH] hdlcdrv: fix divide error bug if bitrate is 0
Date: Wed, 17 May 2017 14:59:39 +0200
Message-ID: <591C493B.6060908@bfs.de>
References: <20170517123549.22659-1-firogm@gmail.com>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: t.sailer@alumni.ethz.ch, davem@davemloft.net,
        gregkh@linuxfoundation.org, linux-hams@vger.kernel.org,
        netdev@vger.kernel.org, dvyukov@google.com,
        syzkaller@googlegroups.com
To: Firo Yang <firogm@gmail.com>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20170517123549.22659-1-firogm@gmail.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Am 17.05.2017 14:35, schrieb Firo Yang:
> The divisor s->par.bitrate will always be 0 until initialized by
> ndo_open() and hdlcdrv_open().
> 
> In order to fix this divide zero error, check whether the netdevice
> was opened by ndo_open() before performing divide.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Firo Yang <firogm@gmail.com>
> ---
>  drivers/net/hamradio/hdlcdrv.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
> index 8c3633c..3c783fd 100644
> --- a/drivers/net/hamradio/hdlcdrv.c
> +++ b/drivers/net/hamradio/hdlcdrv.c
> @@ -574,7 +574,7 @@ static int hdlcdrv_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>  		break;		
>  
>  	case HDLCDRVCTL_CALIBRATE:
> -		if(!capable(CAP_SYS_RAWIO))
> +		if (!capable(CAP_SYS_RAWIO) || !netif_running(dev))
>  			return -EPERM;
>  		if (bi.data.calibrate > INT_MAX / s->par.bitrate)
>  			return -EINVAL;

I would still check for s->par.bitrate > 0 later changes may affect the setting of it
and it is much more obvious.

Also perhaps !netif_running(dev) should better return ENODEV.


just my 2 cents,
re,
 wh

