From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [BK PATCH] [IPV6] Merge Specification Conformity Improvements
Date: Mon, 13 Sep 2004 15:55:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040913155506.4c99d4c8.davem@davemloft.net>
References: <20040913.231732.94153456.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, vnuorval@tcs.hut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040913.231732.94153456.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ok, here are comments :-)

1) wrt. net/core/neighbour.c changes to use time_after() and
   similar interfaces.  Here is why I didn't do that previously.

   I showed this to Alexey some time ago and he made me aware of
   some "black magic" in this area.  Here is what he told me:

   -------------------------------------------------------------
   BTW while I remember... Long time ago (when no such macros even existed)
   I definitely used some funny technique. Namely, when you definitely
   know that some timestamp is growing, now - ts_prev > timeo
   is always right thing and time_after(now, ts_prev+timeo) is not.

   Unfortunately, I do not remember where exactly. It is sick approach, of course,
   but it allowed not to switch to timeval to stamp long living objects.
   So, if you will notice such place, it would be better to make it to use
   timeval rather than to time_* macros.
   -------------------------------------------------------------

2) rt6_dflt_{pointer,lock}

   Maybe it would be better to export a function that operates
   on these objects rather than the objects themselves.  That
   way we could keep them and their implementation static to
   ip6_fib.c

These are minor issues though, and as I stated I pulled your changes
in already.

Thanks.
