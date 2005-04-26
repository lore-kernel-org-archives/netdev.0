From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Question about QOS
Date: Tue, 26 Apr 2005 21:14:54 +0200
Message-ID: <20050426191454.GU577@postel.suug.ch>
References: <426E06F1.9000105@6wind.com> <20050426125955.GT577@postel.suug.ch> <426E56DC.7000108@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Nicolas DICHTEL <nicolas.dichtel@6wind.com>
Content-Disposition: inline
In-Reply-To: <426E56DC.7000108@6wind.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Nicolas DICHTEL <426E56DC.7000108@6wind.com> 2005-04-26 16:57
> You can have the same kind of problem with a ingress filter. I propose the
> following patch to fix the range to 0..bound
> 
> [SCHED] Fix range in psched_tod_diff() to 0..bound
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> 

> diff -Nru linux-2.6-a/include/net/pkt_sched.h linux-2.6-b/include/net/pkt_sched.h
> --- linux-2.6-a/include/net/pkt_sched.h	2005-04-26 15:45:07.074124664 +0200
> +++ linux-2.6-b/include/net/pkt_sched.h	2005-04-26 15:47:26.215971888 +0200
> @@ -140,7 +140,7 @@
>  	if (bound <= 1000000 || delta_sec > (0x7FFFFFFF/1000000)-1)
>  		return bound;
>  	delta = delta_sec * 1000000;
> -	if (delta > bound)
> +	if (delta > bound || delta < 0)
>  		delta = bound;
>  	return delta;
>  }

Yes I agree, it doesn't really matter what value we return and `bound'
is most likely to be correct. I think we should also fix the unlikely
but still possible case when tv1.tv_usec is slightly smaller than
tv2.tv_usec. I know it is very unlikely but do_gettimeofday really
is not that reliable and we have users which rely on a positive
delta. Can you extend your patch to return abs(delta) for case 0
in PSCHED_TDIFF_SAFE?
