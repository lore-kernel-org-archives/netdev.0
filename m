From: jamal <hadi@cyberus.ca>
Subject: Re: [fw@deneb.enyo.de: Route cache performance under stress]
Date: Sun, 6 Apr 2003 11:14:50 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030406110728.G68419@shell.cyberus.ca>
References: <20030405165016.GA32361@outpost.ds9a.nl> <20030405134350.N68419@shell.cyberus.ca>
 <873ckwftal.fsf@deneb.enyo.de> <20030405180607.P68419@shell.cyberus.ca>
 <87n0j3ltf0.fsf@deneb.enyo.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Florian Weimer <fw@deneb.enyo.de>
In-Reply-To: <87n0j3ltf0.fsf@deneb.enyo.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Sun, 6 Apr 2003, Florian Weimer wrote:

> > You may find that aggressive gc is one of your problems infact.
>
> I don't think so.  During a DoS attack with spoofed source addresses,
> the dst cache quickly fills up, and the overwhelming majority of the
> entries is useless (they won't be used again).  The slabinfo line
> looks like this:
>
> ip_dst_cache      116477 131080    192 6554 6554    1
>
> There are only 8192 hash buckets on this system, and if we assume that
> the entries are uniformly distributed over the buckets (which is not
> necessarily true), the code in ip_route_input() has to look at 14 or
> 15 cache entries before the miss is detected.  I can hardly see how
> this is efficient.
>

Do:
cat /proc/net/rt_cache_stat
Should give us a lot more info.

> > I dont see the correlation of syn attacks and the dst cache in your
> > description. Can you collect some profiles?
>
> On the machine above, the dst cache has 2**17 entries.  Imagine what
> happens if all these entries are chained to the same bucket, and the
> chain has to be traversed for each packet.

Yes, in that (worse case) scenario, you have two effects one of walking a
lot of elements before finding you have a cache miss and then being forced
into a slow path after all that pain. The cache miss is not as
expensive compared to the slow path execution. Youd have to walk a lot
entries to get the same effect as being forced one time into slow path.
Again, this is my qualm with the papers general pov.

> > Our data was collected on a real ISP which hosts a lot of web
> > servers and was being constantly DOSed. I dont think you can get
> > more real world than that.
>
> Did you look at a router, or at a host?

As a router, but the hash compute shouldnt matter.

cheers,
jamal
