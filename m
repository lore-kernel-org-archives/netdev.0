From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: [fw@deneb.enyo.de: Route cache performance under stress]
Date: Sun, 06 Apr 2003 14:08:51 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <87n0j3ltf0.fsf@deneb.enyo.de>
References: <20030405165016.GA32361@outpost.ds9a.nl>
	<20030405134350.N68419@shell.cyberus.ca>
	<873ckwftal.fsf@deneb.enyo.de>
	<20030405180607.P68419@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <20030405180607.P68419@shell.cyberus.ca> (jamal's message of
 "Sat, 5 Apr 2003 18:48:42 -0500 (EST)")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal <hadi@cyberus.ca> writes:

> I meant whoever said that 400pps would cause a DOS. I didnt see the dst
> cache test being described in the source, so i assume it is someone else
> other than people who wrote the tool.

Ah, I see.  I'm sorry for the confusion.

> I skimmed through it and got their message. Yes, i understand the
> implications ;->

Good! 8-)

>> > Is this supposed to cure something?
>>
>> Garbage collection is much more aggressive and the chains attached to
>> the bucket are kept much shorter, so less CPU time is spent processing
>> them.
>
> You may find that aggressive gc is one of your problems infact.

I don't think so.  During a DoS attack with spoofed source addresses,
the dst cache quickly fills up, and the overwhelming majority of the
entries is useless (they won't be used again).  The slabinfo line
looks like this:

ip_dst_cache      116477 131080    192 6554 6554    1

There are only 8192 hash buckets on this system, and if we assume that
the entries are uniformly distributed over the buckets (which is not
necessarily true), the code in ip_route_input() has to look at 14 or
15 cache entries before the miss is detected.  I can hardly see how
this is efficient.

> I dont see the correlation of syn attacks and the dst cache in your
> description. Can you collect some profiles?

On the machine above, the dst cache has 2**17 entries.  Imagine what
happens if all these entries are chained to the same bucket, and the
chain has to be traversed for each packet.

> I know thats what the paper says - but this is exactly what i have
> problems with: In the little study we did, its not the collisions that
> kill us rather the fact we are being forced into the slow path the
> majority of times. Please collect the profiles and send me the tool as
> well.

Okay, I'm going to do this (if I can figure out how to read the
profiling data).

> Our data was collected on a real ISP which hosts a lot of web
> servers and was being constantly DOSed. I dont think you can get
> more real world than that.

Did you look at a router, or at a host?
