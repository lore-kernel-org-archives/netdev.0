From: Ben Greear <greearb@candelatech.com>
Subject: Re: NAPI-ized tulip patch against 2.4.20-rc1
Date: Fri, 08 Nov 2002 09:40:10 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DCBF6FA.6040505@candelatech.com>
References: <Pine.GSO.4.30.0211080626160.14675-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Donald Becker <becker@scyld.com>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> 
> On Thu, 7 Nov 2002, Ben Greear wrote:
> 
> 
>>Any ideas for what to try next?  What about upping the skb-hotlist to
>>1024 or so?  Maybe also pre-load it with buffers to make it less likely we'll
>>run low?  (Rx-Drops means it could not allocate a buffer, right?)
>>
> 
> 
> You seem to be using that patch of yours where you route to yourself?

I'm using pktgen for this to take as much of the stack out of the question
as possible, and I'm using two machines for these latest tests.

> Well, since you are up for it:
> - try with two ports only; eth0->eth1 and vary then vary RX ring
> {32, 64,128,256,512,1024}
> - send at least 1 minute worth of data at wire rate

Unfortunately, it seems I need 15 or 30 minutes to make an accurate judgement.
For one reason or another, I drop bursts of packets every 2-5 minutes.

> a) small packets 64 bytes
> b) repeat with MTU sized packets

I'll try some of those variations today.  From more tweaking, it appears
that a good skb_hotlist is around 1k, a good ring size is 512 (1024 is not much
better, still dropping packets in small bursts), weight of 32 or 64 is good.

It also seems that the max_work_at_interrupt setting in the tulip driver
is irrelevant when using NAPI (weight trumps it)...  I increased it above weight,
it helped slightly I think.

Found some more bugs in my skb-recycle patch, I had forgotten to use it for
filling the ring.  If anyone is interested in an updated patch, let me know.
Otherwise, I'll save the bits :)

With settings like these, I ran 294 million pkts, dropped about 90k
(up to 150k on one interface).  Had about 30k dropped packets, don't
know where the other 60k went.

> 
> Repeat above with eth0->eth1, eth2->eth3
> 
> also try where machine is a router and you have a source/sink host

I'm trying to keep the stacks out of it for now...but can do that test
later...

> 
> cheers,
> jamal


Thanks for the suggestions!

Ben


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
