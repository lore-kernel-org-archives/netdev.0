From: Matthias Andree <matthias.andree@gmx.de>
Subject: Re: 2.6.8-rc2-mm1 breaks PPPoE for me (was: 2.6.8-rc2-mm1)
Date: Tue, 3 Aug 2004 02:03:54 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040803000354.GA5327@merlin.emma.line.org>
References: <20040728020444.4dca7e23.akpm@osdl.org> <20040731100947.GA7453@merlin.emma.line.org> <20040802142706.46100c6d.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthias Andree <matthias.andree@gmx.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040802142706.46100c6d.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 02 Aug 2004, Andrew Morton wrote:

> I'm a bit stumped by this - I'm not aware of any change which would have
> caused the pppoe device to start returning -ENOTTY.
> 
> Is this still happening?  Are you sure the relevant modules are loaded? 
> Could you capture an strace of pppd while it's happening?

It happens in 2.6.8-rc2-mm2, too.
The strace is inconclusive.

Setup description:
I am running pppd 2.4.1 (SuSE 8.2 RPM) with the PPPOE plugin tied to eth1:

PCI: Enabling device 0000:00:0b.0 (0004 -> 0005)
ACPI: PCI interrupt 0000:00:0b.0[A] -> GSI 19 (level, low) -> IRQ 19
0000:00:0b.0: 3Com PCI 3c905 Boomerang 100baseTx at 0xd400. Vers LK1.1.19
eth1: Dropping NETIF_F_SG since no checksum feature.

I am starting pppd via DJB's daemontools
(http://cr.yp.to/daemontools.html), with this run file:

#! /bin/sh
exec strace -ff -F -o /tmp/dump-pppd /usr/sbin/pppd call pppoe

Starting pppd from a bash (in an xterm, only thing I've tried) works, I
get a connection.  Writing such a pppd command into inittab yields
ENOENT rather than ENOTTY and fails as well.

The strace looks unhelpful to me, the only occurrence of ENOTTY is:

readlink("/proc/self/fd/0", "/dev/null", 511) = 9
ioctl(0, SNDCTL_TMR_TIMEBASE or TCGETS, 0xbffff700) = -1 ENOTTY (Inappropriate ioctl for device)

ltrace reveals this happens inside getlogin() - and pppd appears to fall
back to getpwuid.

I'd think this is unrelated for I have the same lines with a working
kernel as well.

Using rp-pppoe as pty (instead of the plugin) doesn't work either, the
PPP link is negotiated properly but my log is full of "martian address"
log entries as though it was receiving its own packets externally. How
strange. I wonder if this is an strace artifact...

No useful debugging information. I hope someone can reproduce this. :-(

-- 
Matthias Andree

Encrypted mail welcome: my GnuPG key ID is 0x052E7D95 (PGP/MIME preferred)
