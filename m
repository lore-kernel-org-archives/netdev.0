From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: CLOCK_MONOTONIC datagram timestamps by the kernel
Date: Thu, 1 Mar 2007 10:53:48 -0800
Message-ID: <20070301105348.04c2fd82@freekitty>
References: <45E5570E.7050301@free.fr>
	<200702281555.10309.dada1@cosmosbay.com>
	<45E5A8AE.3030606@free.fr>
	<200703011230.50596.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: John find <linux.kernel@free.fr>, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <200703011230.50596.dada1@cosmosbay.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 1 Mar 2007 12:30:50 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> On Wednesday 28 February 2007 17:07, John wrote:
> 
> >
> > Consider an idle Linux 2.6.20-rt8 system, equipped with a single PCI-E
> > gigabit Ethernet NIC, running on a modern CPU (e.g. Core 2 Duo E6700).
> > All this system does is time stamp 1000 packets per second.
> >
> > Are you claiming that this platform *cannot* handle most packets within
> > less than 1 microsecond of their arrival?
> 
> Yes I claim it.
> 
> You expect too much of this platform, unless "most" means 10 % for 
> you ;)
> 
> If you replace "1 us" by "50 us", then yes, it probably can do it, if "most" 
> means 99%, (not 99.999 %)
> 
> Anyway, if you want to play, you can apply this patch on top of 
> linux-2.6.21-rc2  (nanosecond resolution infrastruture needs 2.6.21)
> I let you do the adjustments for rt kernel.
> 
> I compiled it on my i386 machine, and tested it with a patched libpcap/tcpdump
> 
> [PATCH] NET : introduce nanosecond time infrastructure and SIOCGSTAMPNS
> 
> It appears some machines are *really* fast and that micro second resolution is 
> a limiting factor.
> 
> This patch converts sk_buff timestamp to use new nanosecond infra (added in 
> 2.6.21), and introduces a new ioctl SIOCGSTAMPNS to let applications access 
> nanosecond resolution (ie a timespec instead of timeval)
> 
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>

You probably want to add a SO_TIMESTAMPNS setsockopt() value like existing SO_TIMESTAMP

Also use NSEC_PER_USEC rather than hardcoded 1000.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
