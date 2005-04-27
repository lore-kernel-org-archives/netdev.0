From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Question about QOS
Date: Wed, 27 Apr 2005 13:42:16 +0200
Message-ID: <20050427114216.GV577@postel.suug.ch>
References: <426E06F1.9000105@6wind.com> <20050426125955.GT577@postel.suug.ch> <426E56DC.7000108@6wind.com> <20050426191454.GU577@postel.suug.ch> <426F42F0.9020609@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-net-owner@vger.kernel.org>
To: Nicolas DICHTEL <nicolas.dichtel@6wind.com>
Content-Disposition: inline
In-Reply-To: <426F42F0.9020609@6wind.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Nicolas DICHTEL <426F42F0.9020609@6wind.com> 2005-04-27 09:44
> 
> >Yes I agree, it doesn't really matter what value we return and `bound'
> >is most likely to be correct. I think we should also fix the unlikely
> >but still possible case when tv1.tv_usec is slightly smaller than
> >tv2.tv_usec. I know it is very unlikely but do_gettimeofday really
> >is not that reliable and we have users which rely on a positive
> >delta. Can you extend your patch to return abs(delta) for case 0
> >in PSCHED_TDIFF_SAFE?
> >
> You're right. Here is the new patch.
> 
> [SCHED] Fix range in PSCHED_TDIFF_SAFE to 0..bound
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Signed-off-by: Thomas Graf <tgraf@suug.ch>


> diff -Nru linux-2.6-a/include/net/pkt_sched.h linux-2.6-b/include/net/pkt_sched.h
> --- linux-2.6-a/include/net/pkt_sched.h	2005-04-26 15:45:07.000000000 +0200
> +++ linux-2.6-b/include/net/pkt_sched.h	2005-04-27 09:36:23.421634576 +0200
> @@ -140,7 +140,7 @@
>  	if (bound <= 1000000 || delta_sec > (0x7FFFFFFF/1000000)-1)
>  		return bound;
>  	delta = delta_sec * 1000000;
> -	if (delta > bound)
> +	if (delta > bound || delta < 0)
>  		delta = bound;
>  	return delta;
>  }
> @@ -156,7 +156,8 @@
>  		   __delta += 1000000; \
>  	   case 1: \
>  		   __delta += 1000000; \
> -	   case 0: ; \
> +	   case 0: \
> +		   __delta = abs(__delta); \
>  	   } \
>  	   __delta; \
>  })

