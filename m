From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: [TCP]: TCP_DEFER_ACCEPT causes leak sockets
Date: Thu, 19 Jun 2008 01:44:38 +0300
Message-ID: <200806190144.39270.denys@visp.net.lb>
References: <20080617083220.GA11393@elte.hu>
	<200806190041.52532.denys@visp.net.lb>
	<20080618220527.GA19155@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: vgusev@openvz.org, "Kok, Auke" <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rjw@sisk.pl, mcmanus@ducksong.com,
	ilpo.jarvinen@helsinki.fi, kuznet@ms2.inr.ac.ru,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>, xemul@openvz.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080618220527.GA19155@elte.hu>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thursday 19 June 2008 01:05, Ingo Molnar wrote:
> 
> ok, that looks much better! i have another box with e1000, ich7:
> 
> 64 bytes from titan (10.0.1.14): icmp_seq=5 ttl=64 time=0.345 ms
> 64 bytes from titan (10.0.1.14): icmp_seq=6 ttl=64 time=1.03 ms
> 64 bytes from titan (10.0.1.14): icmp_seq=7 ttl=64 time=0.383 ms
> 64 bytes from titan (10.0.1.14): icmp_seq=8 ttl=64 time=0.320 ms
> 64 bytes from titan (10.0.1.14): icmp_seq=9 ttl=64 time=0.996 ms
> 64 bytes from titan (10.0.1.14): icmp_seq=10 ttl=64 time=0.248 ms
Maybe there is some flow-control involved?
ethtool -S eth0 ?

This is Interrupt throttling i guess in e1000. In e1000 also parameters, but available only on insmod stage
parm:           TxIntDelay:Transmit Interrupt Delay (array of int)
parm:           TxAbsIntDelay:Transmit Absolute Interrupt Delay (array of int)
parm:           RxIntDelay:Receive Interrupt Delay (array of int)
parm:           RxAbsIntDelay:Receive Absolute Interrupt Delay (array of int)
parm:           InterruptThrottleRate:Interrupt Throttling Rate (array of int)


> well i tend not to tweak my drivers with such options because i want to 
> experience and test what 99.9% of our users will experience in the 
> field. The reality is that if it's not the default behavior, it's almost 
> as if it didnt exist at all.

Each coin have two sides. On one side - low latencies(difference 1ms, it is matter anywhere?)
, on another - performance.


> 
> but even with that tune on e1000e (on the t60, ich7) i still get rather 
> large numbers:
> 
> earth4:~/s> ping eu
> PING europe (10.0.1.15) 56(84) bytes of data.
> 64 bytes from europe (10.0.1.15): icmp_seq=1 ttl=64 time=0.250 ms
> 64 bytes from europe (10.0.1.15): icmp_seq=2 ttl=64 time=0.250 ms
> 64 bytes from europe (10.0.1.15): icmp_seq=3 ttl=64 time=0.225 ms
> 64 bytes from europe (10.0.1.15): icmp_seq=4 ttl=64 time=0.932 ms
> 64 bytes from europe (10.0.1.15): icmp_seq=5 ttl=64 time=0.251 ms
> 64 bytes from europe (10.0.1.15): icmp_seq=6 ttl=64 time=0.915 ms
> 64 bytes from europe (10.0.1.15): icmp_seq=7 ttl=64 time=0.250 ms
> 64 bytes from europe (10.0.1.15): icmp_seq=8 ttl=64 time=0.238 ms
> 64 bytes from europe (10.0.1.15): icmp_seq=9 ttl=64 time=0.390 ms
> 64 bytes from europe (10.0.1.15): icmp_seq=10 ttl=64 time=0.260 ms


Is all this hosts on same switch? Is the switch manageable or not?
For example i am having problems with packetloss on long fiber link between two cheap Linksys switches. 
Without flow-control  i cannot survive, and as result i have 1-2ms additional delay on load, and +-0.500ms jitter "inside" this switches (probably from switches).

There is many things matter. Maybe even processor sleep latencies involved? bus latency, PCI latency, whatever. 

Also on laptops is dynamic frequency running (Speedstep)
with 600 Mhz PentiumM (Speedstep - ondemand)
64 bytes from 127.0.0.1: icmp_seq=17 ttl=64 time=0.017 ms
full speed 1.7 Ghz
64 bytes from 127.0.0.1: icmp_seq=33 ttl=64 time=0.007 ms

on network also i see difference -0.030ms when i am running burnP6 (from CPUburn package).





-- 
------
Technical Manager
Virtual ISP S.A.L.
Lebanon

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
