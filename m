From: Donald Becker <becker@scyld.com>
Subject: Re: pci-skeleton duplex check
Date: Wed, 11 Dec 2002 21:42:44 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0212112108070.10674-100000@beohost.scyld.com>
References: <20021211132436.GA12529@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Roger Luethi <rl@hellgate.ch>
In-Reply-To: <20021211132436.GA12529@k3.hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 11 Dec 2002, Roger Luethi wrote:

> pci-skeleton (and some other net drivers) figure out the duplex setting
> like this (leaving duplex locks out here):
> 
> int duplex = (lpar & 0x0100) || (lpar & 0x01C0) == 0x0040;

I'm not certain what version of pci-skeleton.c you are looking at, but
the current version is
	int mii_reg5 = mdio_read(dev, np->phys[0], 5);
	int negotiated = mii_reg5 & np->advertising;
	int duplex = (negotiated & 0x0100) || (negotiated & 0x01C0) == 0x0040;

We are looking for the highest negotiated capability, according to the
rules described in
  http://scyld.com/expert/NWay.html

You did read the reference documentation, didn't you?
I put the documentation references at the top of the driver because you
may need to read them to understand what is going on.  Or was it so
unusual to have written priciples of operation that you skipped that
section?

I'll explain the cases:
 (negotiated & 0x0100)  100baseTx full duplex
or
 (negotiated & 0x01C0) == 0x0040  No capability above 10baseT full duplex

Note that the second check ignores 100baseT4, despite it have priority
over 10baseT-*.  That was intentional to work around, "a specific issue"
with a transceiver.

> If we get past the first condition, we already know bit 8 must be 0. Why do
> we check again in the second condition?

The is no extra cost to the extra bit, and it makes it clear we are
testing for 10baseT-FDX.
(The test was originally implemented as part of a complete set of
cases.  The test code needed while building a driver is more complex
than what you see in the concise final result.)


-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Scyld Beowulf cluster system
Annapolis MD 21403			410-990-9993
