From: Willy Tarreau <willy@w.ods.org>
Subject: Re: _High_ CPU usage while routing (mostly) small UDP packets
Date: Wed, 8 Dec 2004 06:39:53 +0100
Message-ID: <20041208053953.GC17946@alpha.home.local>
References: <20041206205305.GA11970@soohrt.org> <20041206134849.498bfc93.davem@davemloft.net> <20041206224107.GA8529@soohrt.org> <41B58A58.8010007@draigBrady.com> <20041207112139.GA3610@soohrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: P@draigBrady.com, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Karsten Desler <kdesler@soohrt.org>
Content-Disposition: inline
In-Reply-To: <20041207112139.GA3610@soohrt.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Dec 07, 2004 at 12:21:39PM +0100, Karsten Desler wrote:
 
> > I also notice that a lot of time is spent allocating
> > and freeing the packet buffers (and possible hidden
> > time due to cache misses due to allocating on one
> > CPU and freeing on another?).
> > How many [RT]xDescriptors do you have configured by the way?
> 
> 256. I increased them to 1024 shortly after the profiling run, but
> didn't notice any change in the cpu usage (will try again with cyclesoak).

Have you checked the interrupts rate ? I had an e1000 eating many CPU cycles
because it would generate 50000 interrupts/s. Passing the module
InterruptThrottleRate=5000 definitely calmed it down, and more than doubled
the data rate.

Regards
Willy
