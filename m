From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv3 linux-next] hrtimer: Add notifier when clock_was_set
 was called
Date: Fri, 13 Sep 2013 16:32:24 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1309131628250.4089@ionos.tec.linutronix.de>
References: <alpine.DEB.2.02.1309121441420.4089@ionos.tec.linutronix.de> <20130912134409.GB21212@gondor.apana.org.au> <alpine.DEB.2.02.1309121636010.4089@ionos.tec.linutronix.de> <20130912.133252.425268707009916773.davem@davemloft.net>
 <52327C92.5010009@windriver.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, herbert@gondor.hengli.com.au,
	steffen.klassert@secunet.com, dborkman@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	John Stultz <john.stultz@linaro.org>
To: Fan Du <fan.du@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52327C92.5010009@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 13 Sep 2013, Fan Du wrote:
> (2) What I have been bugging you around here for this long time is really the
> second
>     problem, I'm sorry I didn't make it clearly to you and others, which is
> below:
> 
>     Why using wall clock time to calculate soft/hard IPsec events when
> xfrm_state timer
>     out happens in its timeout handler? Because even if xfrm_state using
> CLOCK_BOOTTIME,
>     system wall clock time changing will surely disturb soft/hard IPsec
> events, which
>     you raised your concern about in (*a*).

No CLOCK_BOOTTIME is not affected by wall clock time changes. It's
basically CLOCK_MONOTONIC, it just keeps counting the suspend time as
well. So without a suspend/resume cycle CLOCK_MONOTONIC and
CLOCK_BOOTTIME are the same. After a suspend/resume cycle
CLOCK_BOOTTIME will be N seconds ahead of CLOCK_MONOTONIC, where N is
the number of seconds spent in suspend.

Thanks,

	tglx
