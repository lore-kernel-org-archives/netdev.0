From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH net-next] time: jiffies_delta_to_clock_t() helper to the
 rescue
Date: Mon, 13 Aug 2012 17:52:44 +0200 (CEST)
Message-ID: <alpine.LFD.2.02.1208131749230.32033@ionos>
References: <1344496433.28967.443.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	hank <pyu@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344496433.28967.443.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 9 Aug 2012, Eric Dumazet wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Various /proc/net files sometimes report crazy timer values, expressed
> in clock_t units.
> 
> This happens when an expired timer delta (expires - jiffies) is passed
> to jiffies_to_clock_t().
>
> This function has an overflow in :
> 
> return div_u64((u64)x * TICK_NSEC, NSEC_PER_SEC / USER_HZ);
> 
> commit cbbc719fccdb8cb (time: Change jiffies_to_clock_t() argument type
> to unsigned long) only got around the problem.
> 
> As we cant output negative values in /proc/net/tcp without breaking
> various tools, I suggest adding a jiffies_delta_to_clock_t() wrapper
> that caps the negative delta to a 0 value.

That's correct for 64bit, but for 32bit you do the same for valid
timer values where expires < jiffies. So you might output 0 for valid
armed timers for quite a while around the point where jiffies are
close to the wrapping point.

Dunno if that's an issue, but it want's to be documented at least.

Thanks,

	tglx
