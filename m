From: Donald Becker <becker@scyld.com>
Subject: Re: [ANNOUNCE] NAPI patches for 2.4.19-rc1
Date: Thu, 11 Jul 2002 10:33:34 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0207111020260.2498-100000@beohost.scyld.com>
References: <20020711134432.GA12722@orr.falooley.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Jason Lunz <lunz@falooley.org>
In-Reply-To: <20020711134432.GA12722@orr.falooley.org>
List-Id: netdev.vger.kernel.org

On Thu, 11 Jul 2002, Jason Lunz wrote:

> On Thu, Jul 11, 2002 at  9:39AM -0400, Jeff Garzik wrote:
> > Yes, MMIO will speed up pretty much any tulip card
> 
> Why isn't it the default? Because the clones don't handle it?

It's the default in my driver, with -DUSE_IO_OPS to override.
The driver did need additional write flushes with a few operations.  Don't
do this blindly, or you will end up with a driver that is much
slower than just using I/O operations (e.g. early 8139too drivers).

When I made the changes, I tested on a few dozen tulip cards.  Do not
change a driver unless you have access to all of the chips and chip
revisions, as well as boards with all of the transceiver options.

There are a few NICs that either don't work with MMIO, or have different
register semantics.  Early via-rhine chips and the rtl8139 are good
examples.  Don't assume that if it works for you, the change is
universally valid.


-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Second Generation Beowulf Clusters
Annapolis MD 21403			410-990-9993
