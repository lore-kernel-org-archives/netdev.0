From: Karsten Desler <kdesler@soohrt.org>
Subject: Re: _High_ CPU usage while routing (mostly) small UDP packets
Date: Wed, 8 Dec 2004 14:08:45 +0100
Message-ID: <20041208130845.GA5036@soohrt.org>
References: <20041206205305.GA11970@soohrt.org> <20041206134849.498bfc93.davem@davemloft.net> <20041206224107.GA8529@soohrt.org> <41B58A58.8010007@draigBrady.com> <20041207112139.GA3610@soohrt.org> <20041208053953.GC17946@alpha.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: P@draigBrady.com, "David S. Miller" <davem@davemloft.net>,
	netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261203AbULHNIw@vger.kernel.org>
To: Willy Tarreau <willy@w.ods.org>
Content-Disposition: inline
In-Reply-To: <20041208053953.GC17946@alpha.home.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Willy Tarreau wrote:
> On Tue, Dec 07, 2004 at 12:21:39PM +0100, Karsten Desler wrote:
>  
> > > I also notice that a lot of time is spent allocating
> > > and freeing the packet buffers (and possible hidden
> > > time due to cache misses due to allocating on one
> > > CPU and freeing on another?).
> > > How many [RT]xDescriptors do you have configured by the way?
> > 
> > 256. I increased them to 1024 shortly after the profiling run, but
> > didn't notice any change in the cpu usage (will try again with cyclesoak).
> 
> Have you checked the interrupts rate ? I had an e1000 eating many CPU cycles
> because it would generate 50000 interrupts/s. Passing the module
> InterruptThrottleRate=5000 definitely calmed it down, and more than doubled
> the data rate.

I was running mit ITR=3000, but as a test to see if NAPI works, I
disabled ITR on eth0 bringing the int/s rate up to 50k.
Is that normal? I always though NAPI was supposed to kick in way earlier.
Anyways, I'm going to try different ITR settings to see if they make any
difference.

Cheers,
 Karsten
