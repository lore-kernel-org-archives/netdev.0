From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance under stress
Date: Mon, 9 Jun 2003 00:36:44 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030609073644.GE20613@netnation.com>
References: <001501c32e4b$35d67d60$4a00000a@badass> <20030608.230332.48514434.davem@redhat.com> <20030609065211.GB20613@netnation.com> <20030608.235622.38700262.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xerox@foonet.net, fw@deneb.enyo.de, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030608.235622.38700262.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Sun, Jun 08, 2003 at 11:56:22PM -0700, David S. Miller wrote:

> We have to walk the entire destination hash chain _ANYWAYS_ to verify
> that a matching entry has not been put into the cache while we were
> procuring the new one.  During this walk we can also choose a
> candidate rtcache entry to free.

Ah, neat.  I should try reading this stuff. :)

> Something like the patch at the end of this email, doesn't compile
> it's just a work in progress.  The trick is picking TIMEOUT1 and
> TIMEOUT2 :)
> 
> Another point is that the default ip_rt_gc_min_interval is
> absolutely horrible for DoS like attacks.  When DoS traffic
> can fill the rtcache multiple times per second, using a GC
> interval of 5 seconds is the worst possible choice. :)

Yes, I've reduced the gc_min_interval to 1, and it has been that way for
some time.  BTW, you may be interested in this old email from Alexey:

http://www.tux.org/hypermail/linux-kernel/1999week05/1113.html

(This was back when the GC was limited so much that legitimate traffic
was overflowing the table.  DoS attacks must have been really effective
then. :))

Simon-

[        Simon Kirby        ][        Network Operations        ]
[     sim@netnation.com     ][   NetNation Communications Inc.  ]
[  Opinions expressed are not necessarily those of my employer. ]
