From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch 2.6.9-rc2] 3c59x: do not mask reset of aism logic at rmmod
Date: Thu, 30 Sep 2004 09:14:07 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040930091407.A10417@tuxdriver.com>
References: <20040928145455.C12480@tuxdriver.com> <Pine.LNX.4.44.0409291253510.1746-100000@training.scyld.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0409291253510.1746-100000@training.scyld.com>; from becker@scyld.com on Wed, Sep 29, 2004 at 01:16:01PM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 29, 2004 at 01:16:01PM -0400, Donald Becker wrote:

> This 3c59x.c code was changed in 2001 to mask the transceiver reset and
> shut the chip down cleanly.  This occurred in two steps, with a
> discussion on the vortex mailing list for each.
> 3c59x.c:v0.99Uc 12/5/2001
> 3c59x.c:v0.99T 7/16/2001
> The December change was noted as specifically for the 3c905B.

Don,

I'm having trouble finding the discussions you referenced.  I think I
found the discussion related to the v0.99T change in the vortex-bug
archives, but I never did find the discussion for the v0.99Uc in either
the vortex or vortex-bug archives (or any of the other lists that looked
to possibly be related).  Since you seem to have already found them,
would you mind sending me a more precise link?  Thanks!

Also, how can I look at the version history for the 3c59x.c that you
maintain?  Is it in CVS (or BK or something similar) where I may access
it?

> > module).  Changing vortex_remove_one() to allow the auto-initialize
> > state machine logic to be reset when the module is removed alleviates
> > this problem.
> 
> ...and creates a new problem: resetting the link causes operational
> problems on many networks.  The most obvious example is spanning tree
> detection delays on switches, where the switch does not pass traffic.

To be clear, were you looking at the version of the patch I posted on
the netdev list?  Or the version in Red Hat's Bugzilla?  In the bugzilla
patch, I had none of the bits masked, while in the netdev patch I left
the networkReset bit masked.

Does allowing the aismReset to occur cause the link to go down?  I guess
I presumed that was what the networkReset bit was there to prevent.

Even if the link does go down, is that really such a bit deal on an
rmmod?  I can see wanting to avoid it on a normal close, but an rmmod
would seem like a more rare event.

> The correct solution is to reset the transceiver (and thus cause
> re-autonegotiation) only if a problem is detected, not an unconditional
> or proactive reset.

The reset is already there, I was just letting it do more.  The cards
that have this problem just don't come back w/o this reset.

There is a TxReset that occurs on the transmit underrun condition.  Are
you suggesting that a TotalReset should occur instead?

John

P.S.  The current state of the reset at rmmod seems to have come in the
2.4.9 timeframe.  Prior to that, FWIW all but one card left the aismReset
bit unmasked just as in my patch.
-- 
John W. Linville
linville@tuxdriver.com
