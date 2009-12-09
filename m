From: Nicolas Pitre <nico@fluxnic.net>
Subject: Re: [PATCH] smc91x: fix unused flags warnings on UP systems
Date: Wed, 09 Dec 2009 09:51:14 -0500 (EST)
Message-ID: <alpine.LFD.2.00.0912090950460.31174@xanadu.home>
References: <1260366004-27366-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753001AbZLIOvK@vger.kernel.org>
In-reply-to: <1260366004-27366-1-git-send-email-vapier@gentoo.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 9 Dec 2009, Mike Frysinger wrote:

> Local flags variables will be declared whenever these functions get used,
> but obviously on UP systems the flags parameter won't be touched.  So add
> some dummy ops that get optimized away anyways to satisfy gcc's warnings.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

Acked-by: Nicolas Pitre <nico@fluxnic.net>


> ---
>  drivers/net/smc91x.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
> index ae4983a..b0c92b6 100644
> --- a/drivers/net/smc91x.c
> +++ b/drivers/net/smc91x.c
> @@ -534,9 +534,9 @@ static inline void  smc_rcv(struct net_device *dev)
>  #define smc_special_lock(lock, flags)		spin_lock_irqsave(lock, flags)
>  #define smc_special_unlock(lock, flags) 	spin_unlock_irqrestore(lock, flags)
>  #else
> -#define smc_special_trylock(lock, flags)	(1)
> -#define smc_special_lock(lock, flags)   	do { } while (0)
> -#define smc_special_unlock(lock, flags)	do { } while (0)
> +#define smc_special_trylock(lock, flags)	(flags == flags)
> +#define smc_special_lock(lock, flags)   	do { flags = 0; } while (0)
> +#define smc_special_unlock(lock, flags)	do { flags = 0; } while (0)
>  #endif
>  
>  /*
> -- 
> 1.6.5.5
> 
