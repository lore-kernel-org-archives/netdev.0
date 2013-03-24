From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] net: reduce net_rx_action() latency to 2 HZ
Date: Sun, 24 Mar 2013 02:02:17 +0100
Message-ID: <20130324010217.GO15527@1wt.eu>
References: <1362503713.15793.121.camel@edumazet-glaptop> <CAP=VYLrvXREA=HGnnUCi2N77yRdktQDop1PpzJkveXDihJ3DOw@mail.gmail.com> <1363879647.4431.8.camel@edumazet-glaptop> <514B429C.5070605@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, stable <stable@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Steven Rostedt <rostedt@goodmis.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <514B429C.5070605@windriver.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 21, 2013 at 01:25:48PM -0400, Paul Gortmaker wrote:
> On 13-03-21 11:27 AM, Eric Dumazet wrote:
> > On Thu, 2013-03-21 at 11:03 -0400, Paul Gortmaker wrote:
> >> [CC'ing stable & Willy - for the older releases not fed by
> >> http://patchwork.ozlabs.org/bundle/davem/stable/ ]
> >>
> >> On Tue, Mar 5, 2013 at 12:15 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >>> From: Eric Dumazet <edumazt@google.com>
> >>>
> >>> We should use time_after_eq() to get maximum latency of two ticks,
> >>> instead of three.
> >>>
> >>> Bug added in commit 24f8b2385 (net: increase receive packet quantum)
> >>
> >> I'm not sure what applications would notice the extra tick, but 24f8b takes
> >> us back to 2.6.29.  It cherry picks cleanly onto 2.6.34, so it probably also
> >> does the same for Willy's 2.6.32 longterm too.
> >>
> >> Commit is now mainline d114a3338747255518 - v3.9-rc3~36^2~34.
> > 
> > BQL (Bytes Queue Limit) relies on TX completion being run often, and
> > Qdisc being serviced often as well. If net_rx_action() hogs the cpu,
> > net_tx_action() is delayed and NIC can stall.
> > 
> > I wrote this patch because I was investigating a regression when a
> > Google application began using BQL enabled kernels.
> > 
> > About the latency in itself, following commit is way more interesting.
> > 
> > commit c10d73671ad30f5 (softirq: reduce latencies)
> > 
> > As without it, I could trigger more than 50ms latencies for the poor
> > user thread interrupted by softirq processing.
> 
> That is also reasonably portable back to 2.6.34.  And it is more
> interesting too -- it will be interesting in a preempt_rt context
> too, once RT moves ahead off the current 3.6 baseline, which still
> has the old count-limit of 10 vs the new 2ms time limit.
> 
> RT (3.4 and 3.6 based) currently has this patch from Steven:
> http://git.kernel.org/cgit/linux/kernel/git/paulg/3.6-rt-patches.git/tree/net-tx-action-avoid-livelock-on-rt.patch
> 
> Anyway, thanks for the heads up on this commit.

And thanks to you Paul for the heads up as well, I'll pick them from
your branch :-)

Cheers,
Willy
