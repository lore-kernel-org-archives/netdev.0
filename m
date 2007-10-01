From: "Denys" <nuclearcat@nuclearcat.com>
Subject: Re: 2.6.21 -> 2.6.22 & 2.6.23-rc8 performance regression
Date: Mon, 1 Oct 2007 11:07:34 +0300
Message-ID: <20071001080339.M21850@nuclearcat.com>
References: <200709301425.37564.nickpiggin@yahoo.com.au> <20070930223503.M8966@nuclearcat.com> <47008CB0.7010808@cosmosbay.com> <20071001.001259.28812610.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, dada1@cosmosbay.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754703AbXJAIIE@vger.kernel.org>
In-Reply-To: <20071001.001259.28812610.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Well, i can play a bit more on "live" servers. I have now hot-swap server with
full gentoo,  where i can rebuild any kernel you want, with any applied patch.
But it looks more like not overhead, load becoming high too "spiky", and it is
not just permantenly higher. Also it is not normal that all system becoming
unresposive (for example ping 127.0.0.1 becoming 300ms for period, when usage
softirq jumps to 100%).

On Mon, 01 Oct 2007 00:12:59 -0700 (PDT), David Miller wrote
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Mon, 01 Oct 2007 07:59:12 +0200
> 
> > No problem here on bigger servers, so I CC David Miller and netdev
> > on this one.  AFAIK do_gettimeofday() and ktime_get_real() should
> > use the same underlying hardware functions on PC and no performance
> > problem should happen here.
> 
> One thing that jumps out at me is that on 32-bit (and to a certain
> extent on 64-bit) there is a lot of stack accesses and missed
> optimizations because all of the work occurs, and gets expanded,
> inside of ktime_get_real().
> 
> The timespec_to_ktime() inside of there constructs the ktime_t return
> value on the stack, then returns that as an aggregate to the caller.
> 
> That cannot be without some cost.
> 
> ktime_get_real() is definitely a candidate for inlining especially in
> these kinds of cases where we'll happily get computations in local
> registers instead of all of this on-stack nonsense.  And in several
> cases (if the caller only needs the tv_sec value, for example)
> computations can be elided entirely.
> 
> It would be constructive to experiment and see if this is in fact 
> part of the problem.


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.
