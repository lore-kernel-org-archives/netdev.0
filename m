From: Roger Luethi <rl@hellgate.ch>
Subject: Re: [9/9][PATCH 2.6] Restructure reset code
Date: Wed, 2 Jun 2004 22:30:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040602203026.GB31791@k3.hellgate.ch>
References: <20040602115920.GA17634@k3.hellgate.ch> <40BE2DE0.4040102@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40BE2DE0.4040102@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 02 Jun 2004 15:43:28 -0400, Jeff Garzik wrote:
> Roger Luethi wrote:
> >Restructure code to make it easier to maintain.
> >
> >rhine_hw_init: resets chip, reloads eeprom
> >rhine_chip_reset: chip reset + what used to be wait_for_reset
> >rhine_reload_eeprom: reload eeprom, re-enable MMIO, disable 
> >EEPROM-controlled
> >	WOL
> >
> >Note: Chip reset clears a bunch of registers that should be reloaded
> >from EEPROM (which turns off MMIO). Deal with that later.
> 
> 
> Rejected, two reasons:
> 
> 1) dev->dev_addr[] should be loaded from eeprom only once, at probe 
> time, not once for each hw init.  [this value should be written to the 
> chip's MAC address registers upon each dev->open() call]

We are in violent agreement, you are describing what the driver
does with and without patch 9 (unless I seriously botched the
splitting). Incidentally, rhine_hw_init gets called only once, at probe
time (further calls are to rhine_chip_reset).

The remaining problem with the reset stuff is this: Years ago, soft
resets were added to via-rhine in the vain hope it would fix something,
but soft resets overwrite some registers that need to be reloaded
from somewhere (it's more than just the MAC address). The proper fix
for this is to remove unnecessary soft resets (i.e. all but the one at
probe time) and/or restore the registers affected by a soft reset. But
that would go beyond a simple clean-up patch.

> 2) Your "Note:" worries me...  why not deal with this now?  :)

Mainly because I don't have all the information needed to positively
determine the proper solution -- not yet. "Dealing with it" will likely
mean removing two soft reset calls and documenting registers that are
clobbered by soft reset (just in case), but that doesn't fit into a
clean-up patch anyway.

In summary, patch 9 is simply what all conceivable solutions have in
common -- code clean-up.

Thanks for the review.

Roger
