From: Ben Greear <greearb@candelatech.com>
Subject: Re: Linux router performance (3c59x) (fwd)
Date: Mon, 17 Mar 2003 22:30:47 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E76BD17.7060208@candelatech.com>
References: <Pine.LNX.4.51.0303172239390.30872@ns.istop.com> <3E76A508.30007@candelatech.com> <Pine.LNX.4.51.0303172356440.8302@ns.istop.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: ralph+d@istop.com
In-Reply-To: <Pine.LNX.4.51.0303172356440.8302@ns.istop.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ralph Doncaster wrote:
> On Mon, 17 Mar 2003, Ben Greear wrote:
> 
> 
>>Ralph Doncaster wrote:
> 
> [...]
> 
>>>Currently the box in question is running a 67% system load with ~40kpps.
>>>Here's the switch port stats that the 2 3c905cx cards are plugged into:
>>>
>>>  5 minute input rate 36143000 bits/sec, 8914 packets/sec
>>>  5 minute output rate 54338000 bits/sec, 10722 packets/sec
>>>-
>>>  5 minute input rate 50585000 bits/sec, 12445 packets/sec
>>>  5 minute output rate 34326000 bits/sec, 9596 packets/sec
>>
>>When using larger packets, NAPI doesn't have much effect.
> 
> 
> So I should just give up on Linux and go with FreeBSD?
> http://info.iet.unipi.it/~luigi/polling/

It would be interesting to see a performance comparison.


>>Have you tried routing with simple routing tables to see if that
>>speeds anything up?
>  
> No, but I did read through a bunch of the route-cache code and even with
> the dynamic hashtable size introduced in recent 2.4 revs, it looks very
> ineficient for core routing.  I'd expect a speedup with a small routing
> table, but then it would be useless as a core router in my network.

So, if making the routing table smaller 'fixes' things, then NAPI and your
NIC is not the problem.

>>Could also try an e100 or Tulip NIC.  Those usually work pretty
>>good...  Or, could use an e1000 GigE NIC...
> 
> 
> If I can get confirmation that under similar conditions the e1000 performs
> significantly better, then I'll go that route.

In my testing, I could get about 140kpps (64-byte packets) tx or
rx on a single port.  Bi-directional I got about 90kpps.  This
was a 1.8Ghz AMD processor with a tulip driver.

When using MTU sized packets, could fill 4 ports with tx+rx traffic
at 90+Mbps.

With e1000 on a 64/66 PCI bus, I could transmit around 860Mbps with 1500
byte packets (tx + rx on the same machine, but different ports of
a dual-port NIC), and could generate maybe 400kpps
with small packets (I don't remember the exact number here...)

This was using a slightly modified (and slower) pktgen module, which is standard in
the latest kernels.

So, sending/receiving packets at extreme rates is possible.  Routing with 100k entries
may not work nearly so well.

>>It's also possible that you are just reaching the limit of your
>>system.
> 
> 
> The NAPI docs imply 144kpps is easily attainable on lesser hardware than
> mine.  Also I can't see bandwidth being the issue as I'm moving
> <25Mbytes/sec over the PCI bus.  I should be able to do more than double
> that before I have to worry about PCI saturation.

So, test w/smaller routing tables so you can see if it's routing or the NIC
that is slowing you down.

> 
> -Ralph
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
