From: tsuna <tsunanet@gmail.com>
Subject: Re: [PATCH] tcp: Implement a two-level initial RTO as per draft RFC 2988bis-02.
Date: Wed, 18 May 2011 21:33:21 -0700
Message-ID: <BANLkTikQEq9+YkJHcTe3PWnRvh7AN=VVWA@mail.gmail.com>
References: <1305771744-83951-1-git-send-email-tsunanet@gmail.com>
 <20110518.223622.1525088601595365235.davem@davemloft.net> <BANLkTinEN_=jSCw4qR1PqtWaQ+07OMq7tg@mail.gmail.com>
 <20110519.001426.2119532755281545481.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, hagen@jauu.net,
	eric.dumazet@gmail.com, alexander.zimmermann@comsys.rwth-aachen.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110519.001426.2119532755281545481.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 18, 2011 at 9:14 PM, David Miller <davem@davemloft.net> wrote:
> The IETF draft has a requirement that we fallback to 3 seconds if the
> initial RTO is 1 second.
>
> Nothing in your facilities ensure this, or provide a way for the
> kernel to make sure this is the case.

Not sure to understand what you're saying.  If tcp_initial_rto = 1000
and tcp_initial_fallback_rto = 3000, then you get exactly the behavior
the draft describes.  The knobs simply allow you to either revert to
today's behavior or use other settings that would make more sense in
your environment (e.g. very high RTT).  Are you concerned about cases
where, say, tcp_initial_fallback_rto < tcp_initial_rto?

> And for other values of initial RTO, what fallback is appropriate?

Presumably if the user decides to tweak these knobs, they'll know
what's appropriate for their environment.  Or are you suggesting that
one value be derived from the other?  (e.g. tcp_initial_fallback_rto =
3 * tcp_initial_rto)

> As a result of all of this, I do not really think this is something
> the user should control at all.
>
> I really would rather see the initial RTO be static and be set to 1
> with fallback RTO of 3.

I can also provide a simple patch for this if you want to start from
there.  And then maybe we can discuss having a runtime knob some more
:-)

-- 
Benoit "tsuna" Sigoure
Software Engineer @ www.StumbleUpon.com
