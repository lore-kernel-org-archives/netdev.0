From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] use mmiowb in tg3_poll
Date: Sun, 29 May 2005 01:12:10 +0200
Message-ID: <20050528231209.GA8456@xi.wantstofly.org>
References: <200410211628.06906.jbarnes@engr.sgi.com> <Pine.LNX.4.33.0410221345400.392-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jbarnes@engr.sgi.com, gnb@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akepner@sgi.com
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33.0410221345400.392-100000@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 22, 2004 at 01:51:01PM -0700, akepner@sgi.com wrote:

> Returning from tg3_poll() without flushing the PIO write which
> reenables interrupts can result in lower cpu utilization and higher
> throughput.

I'm quite curious what kind of MMIO read latency you see on your
Altix boxen.  This app is quite useful for determining those figures
on x86{,_64} machines:

	http://svn.gnumonks.org/trunk/mmio_test/mmio_test.c

I'm not sure if it'll run on Itanium out of the box (it currently
assumes PAGE_SIZE <= 4096, you'd probably need to tweak rdtscl(),
and if there's a weird phys:pci address correspondence you might
have to teach it about that as well), but it would be nice if you
could give an approximate indication of exactly how expensive an
MMIO read is on your platform.


cheers,
Lennert
