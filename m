From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] repairing rtcache killer
Date: Wed, 6 Aug 2003 22:06:45 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308061806.WAA01763@dub.inr.ac.ru>
References: <16177.14760.612648.582063@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, Robert.Olsson@data.slu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert.Olsson@data.slu.se (Robert Olsson)
In-Reply-To: <16177.14760.612648.582063@robur.slu.se> from "Robert Olsson" at Aug 06, 2003 07:23:52 PM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> +		if (in_hit < in_slow_tot) {
> +			/* Aggressive  */
> +			if(ip_rt_gc_elasticity2 > 1) 
> +				ip_rt_gc_elasticity2 >>= 1;
> +		}
> +		else 
> +			if(ip_rt_gc_elasticity2 < 2*ip_rt_gc_elasticity) {
> +				ip_rt_gc_elasticity2 <<= 1;
> +			}

It is the system with positive feedback. Reduction of chain length
results in increasing amount of misses and so on. Under normal load
it has the only stable state, zero chain length and will never leave it.

hits/misses is wrong feedback, unless you use it to increase chain length. :-)

Alexey
