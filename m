From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6.0-test4][IPv6] ip6_flowlabel.c: timer cleanups
Date: Wed, 27 Aug 2003 23:25:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030827232514.0854fc06.davem@redhat.com>
References: <1061907882.1108.28.camel@lima.royalchallenge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Vinay K Nallamothu <vinay-rc@naturesoft.net>
In-Reply-To: <1061907882.1108.28.camel@lima.royalchallenge.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 26 Aug 2003 19:54:41 +0530
Vinay K Nallamothu <vinay-rc@naturesoft.net> wrote:

> @@ -104,10 +105,9 @@
>  			fl->opt = NULL;
>  			kfree(opt);
>  		}
> -		if (!del_timer(&ip6_fl_gc_timer) ||
> -		    (long)(ip6_fl_gc_timer.expires - ttd) > 0)
> -			ip6_fl_gc_timer.expires = ttd;
> -		add_timer(&ip6_fl_gc_timer);
> +		if (!timer_pending(&ip6_fl_gc_timer) ||
> +		    time_after(ip6_fl_gc_timer.expires, ttd))
> +			mod_timer(&ip6_fl_gc_timer, ttd);
>  	}
>  }
>  

This code is still racey.  This code needs to hold the
toplevel ip6_fl_lock during the GC timer manipulations
and tests.
