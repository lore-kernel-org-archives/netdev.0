From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv3 linux-next] hrtimer: Add notifier when clock_was_set
 was called
Date: Thu, 12 Sep 2013 15:21:24 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1309121441420.4089@ionos.tec.linutronix.de>
References: <1375866296-15079-1-git-send-email-fan.du@windriver.com> <1375866296-15079-2-git-send-email-fan.du@windriver.com> <52021177.6020306@redhat.com> <520213F2.5090401@windriver.com> <520214C6.6000307@redhat.com> <520B4552.2000607@windriver.com>
 <alpine.DEB.2.02.1308181102230.4089@ionos.tec.linutronix.de> <5212CCCA.4090907@windriver.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Daniel Borkmann <dborkman@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Fan Du <fan.du@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5212CCCA.4090907@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 20 Aug 2013, Fan Du wrote:
> Thanks for your patience. Please let me take a few seconds try to
> explain this.

Sorry for the late reply.
 
> Current xfrm layers has *one* hrtimer to guard Ipsec keys timeout,
> The timeout could be measured in either of below two ways:
> 
>  (1) The timer is started once the keys is created, but this
>      key is not necessary actually used right now. In detail,
>      record the get_seconds() when this key is created.
> 
>  (2) Starting the timer when this key is actually used, e.g when
>      an IP packet need to be encrypted. In details, recored the
>      get_seconds() when this key is first used.
> 
> So in the hrtimer handler, the code get current get_seconds, and
> check against with what saved in (1)or(2), and notify the timeout
> up to user land.
> 
> So the pitfall is using one hrtimer for two timeout events,
> most importantly using get_seconds to check timeout, once system
> clock is changed by user intentionally, the key timeout could
> misbehave wildly.
> 
> A refractor has been proposed to get rid of depending on system wall
> clock by cleaning up the hrtimer handler. Unfortunately David frowned
> on it in (3), and suggest once system clock is changed, adjust the
> timeout of the key.
> 
> 
> (3): http://www.spinics.net/lists/netdev/msg245169.html

Thanks for the explanation so far.

What's still unclear to me is why these timeouts are bound to wall
time in the first place.

Is there any real reason why the key life time can't simply be
expressed in monotonic time, e.g. N seconds after creation or M
seconds after usage? Looking at the relevant RFCs I can't find any
requirement for binding the life time to wall time. 

A life time of 10 minutes does not change when the wall clock is
adjusted for whatever reasons. It's still 10 minutes and not some
random result of the wall clock adjustments. But I might be wrong as
usual :)

Thanks,

	tglx
