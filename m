From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance under stress
Date: Sun, 8 Jun 2003 23:47:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030609064719.GA20613@netnation.com>
References: <20030608234926.GA9453@netnation.com> <001001c32e19$81bc7ea0$4a00000a@badass>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Florian Weimer'" <fw@deneb.enyo.de>, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: CIT/Paul <xerox@foonet.net>
Content-Disposition: inline
In-Reply-To: <001001c32e19$81bc7ea0$4a00000a@badass>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jun 08, 2003 at 07:55:58PM -0400, CIT/Paul wrote:

> A denial of service attack going on, OR you just have millions of hosts
> going through the router (if you were an ISP).  Anything with seeminly
> Random source ips (something like juno-z.101f.c will generate worst case
> scenario for forwarding packets) will cause the cache to constantly
> Add new entries at pretty much the rate of the attack.. This can stifle
> just about any linux router with a measly 10 megabits/second of traffic
> unless
> The router is tuned up to a large degree (NAPI, certain nics, route
> cache timings, etc.) and even then it can still be destroyed no matter
> what
> The cpu is with less than 100,000 packets per second and in mosts cases
> less than 30k.. That's why it's just no acceptable for companies using
> it as a replacement for say a cisco 7200 VXR series (npe300,400 nsf-1,
> etc.) which can do 300K+ packet per second of routing (and yes it can
> even route juno-z.101f.c at 300kpps, I have tested it).   Linux has no
> problem doing 300kpps from a single source to a single destination
> provided you have NAPI or ITR or something limiting the interrupts.. The
> overhead is the route cache and the related systems that use it and also
> netfilter is very slow :/  One of these days they will fix it..... If

Whoa, wait a second.

You got a 7200 VXR to do 300kpps?  I would have liked to see that.
We couldn't get our 7206 VXR routers to do anything more than about 12
Mbit/second of small packets, which I believe is about 40,000 packets
per second.  This is with CEF disabled, because it ended up duplicating
packets and doing some other strange things with CEF enabled.

Also, I remember trying with a bucketload of netfilter rules and finding
that the performance difference was hardly noticeable.

Linux can route small packets with random src/dst at much faster than 10
Mbit/sec.  It depeends on the hardware as you say, but it shouldn't ever
be that slow on reasonable hardware.

I remember back even in 1998 with the 2.0 kernel (before the route cache
existed) on a Celeron 300A with eepro100 cards (eepro100 driver, no
interrupt coalescing, definitely no NAPI) was cable of routing at least
20 Mbit/second of SYN packets from random sources.  In fact, I remember
it happily choking some old 3Com switches we had at the time.

I recently saw 90 Mbit/second of additional traffic (small packets with
random sources) going through our routers (now single Athlon 1800MP (MP
for APIC), tg3, NAPI, BGP routing tables), and they didn't seem to care. 
It's definitely not yet perfect, but it's not bad.  The hashing fixes for
large routing tables which Dave M. recently posted has made the situation
much better -- it was very broken before.  What did your routing table
look like when you were doing tests?

I have fiddled with the route cache garbage collection parameters a bit,
but I haven't really been able to reduce the CPU usage by much at all. 
Really, though, shouldn't the route cache overhead be fairly small in
comparison to everything else involved in forwarding?

Simon-
