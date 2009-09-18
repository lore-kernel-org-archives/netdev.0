From: Paul Moore <paul.moore@hp.com>
Subject: Re: tun: Return -EINVAL if neither IFF_TUN nor IFF_TAP is set.
Date: Fri, 18 Sep 2009 07:54:05 -0400
Message-ID: <200909180754.05817.paul.moore@hp.com>
References: <20090917073614.15217260031@msa105lp.auone-net.jp>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kusanagi Kouichi <slash@ma.neweb.ne.jp>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756978AbZIRLyG@vger.kernel.org>
In-Reply-To: <20090917073614.15217260031@msa105lp.auone-net.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 17 September 2009 03:36:13 am Kusanagi Kouichi wrote:
> After commit 2b980dbd77d229eb60588802162c9659726b11f4
> ("lsm: Add hooks to the TUN driver") tun_set_iff doesn't
> return -EINVAL though neither IFF_TUN nor IFF_TAP is set.
> 
> Signed-off-by: Kusanagi Kouichi <slash@ma.neweb.ne.jp>

Sorry about that, my mistake, thanks for finding and fixing this.

Reviewed-by: Paul Moore <paul.moore@hp.com>

> ---
>  drivers/net/tun.c |    4 +---
>  1 files changed, 1 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 3f5d288..e091756 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -946,8 +946,6 @@ static int tun_set_iff(struct net *net, struct file
>  *file, struct ifreq *ifr) char *name;
>  		unsigned long flags = 0;
> 
> -		err = -EINVAL;
> -
>  		if (!capable(CAP_NET_ADMIN))
>  			return -EPERM;
>  		err = security_tun_dev_create();
> @@ -964,7 +962,7 @@ static int tun_set_iff(struct net *net, struct file
>  *file, struct ifreq *ifr) flags |= TUN_TAP_DEV;
>  			name = "tap%d";
>  		} else
> -			goto failed;
> +			return -EINVAL;
> 
>  		if (*ifr->ifr_name)
>  			name = ifr->ifr_name;
> 

-- 
paul moore
linux @ hp
