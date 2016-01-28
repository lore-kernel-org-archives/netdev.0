From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 0/4] net: add rx_unhandled stat counter
Date: Thu, 28 Jan 2016 06:42:42 -0800
Message-ID: <1453992162.7627.35.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1453489882-57948-1-git-send-email-jarod@redhat.com>
	 <1453926098-40181-1-git-send-email-jarod@redhat.com>
	 <1453928987.20722.29.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160128060215.GB59058@redhat.com> <20160128061808.GD59058@redhat.com>
	 <1453986002.7627.20.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160128143806.GE59058@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tom Herbert <tom@herbertland.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160128143806.GE59058@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-01-28 at 09:38 -0500, Jarod Wilson wrote:

> Something like this then:
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 82334c6..2ca3eab 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -7262,15 +7262,16 @@ void netdev_run_todo(void)
>  void netdev_stats_to_stats64(struct rtnl_link_stats64 *stats64,
>  			     const struct net_device_stats *netdev_stats)
>  {
> +	memset(stats64, 0, sizeof(*stats64));
>  #if BITS_PER_LONG == 64
> -	BUILD_BUG_ON(sizeof(*stats64) != sizeof(*netdev_stats));
> +	BUILD_BUG_ON(sizeof(*stats64) < sizeof(*netdev_stats));
>  	memcpy(stats64, netdev_stats, sizeof(*stats64));
>  #else
>  	size_t i, n = sizeof(*stats64) / sizeof(u64);
>  	const unsigned long *src = (const unsigned long *)netdev_stats;
>  	u64 *dst = (u64 *)stats64;
>  
> -	BUILD_BUG_ON(sizeof(*netdev_stats) / sizeof(unsigned long) !=
> +	BUILD_BUG_ON(sizeof(*netdev_stats) / sizeof(unsigned long) >
>  		     sizeof(*stats64) / sizeof(u64));
>  	for (i = 0; i < n; i++)
>  		dst[i] = src[i];
> 
> Compiles locally w/o that net_device_stats addition, seems sane to me.
> 

Sure, you also can set stats64->rx_unhandled to 0 here, just to be 100%
safe.

Thanks.
