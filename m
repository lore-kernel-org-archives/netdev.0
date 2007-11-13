From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 18:04:10 +0000
Message-ID: <20071113180410.GA1356@flint.arm.linux.org.uk>
References: <32209efe0711122242m3a5f081asf1c11a38b24db10c@mail.gmail.com> <20071113031553.3c7b5c16.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Natalie Protasevich <protasnb@gmail.com>,
	alsa-devel@alsa-project.org, netdev@vger.kernel.org,
	linux-pcmcia@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-ide@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	linux-input@atrey.karlin.mff.cuni.cz
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:39482 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754826AbXKMSFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 13:05:05 -0500
Content-Disposition: inline
In-Reply-To: <20071113031553.3c7b5c16.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 13, 2007 at 03:15:53AM -0800, Andrew Morton wrote:
> On Mon, 12 Nov 2007 22:42:32 -0800 "Natalie Protasevich" <protasnb@gmail.com> wrote:
> > PLATFORM===============================================================
> > 
> > xipImage is built so that uBoot cant run it (ARM)
> > http://bugzilla.kernel.org/show_bug.cgi?id=9356
> > Kernel: 2.6.21
> 
> Zero responses from developers

For christ sake Andrew.  Some of us are not employed to do kernel work
24h x 365days a year.  You might be, I'm not.

First thing, it's not a regression.  Second thing, it's *not* a bug.

uboot requires kernel images to be specially wrapped up in their crappy
formats before uboot will recognise it.  This means that if someone wants
to boot a binary image with uboot, they need to either:

1. work out the correct 'mkimage' command and run that program after
   the kernel build has completed.

2. sort out adding a new target to the kernel makefiles to run this
   uboot specific 'mkimage' command automatically.

And Alexandre (the original feature-missing reporter) has linked to a
message where a patch was proposed to do (2).  So obviously it's no
longer a problem for the reporter.

> > with CONFIG_NO_HZ and/or CONFIG_HPET_TIMER set kernel 2.6.23 doesn't
> > boot (ARM, Timer)
> > http://bugzilla.kernel.org/show_bug.cgi?id=9229
> > Kernel: 2.6.23
> 
> No response from developers

Bug was assigned to reporter, so I ignored it on the grounds that the
reporter was resolving it.  Plus, until recently I didn't have any
workable PXA systems to test stuff on.

In the end, a similar issue has been resolved anyway after a lot of
discussion on the ARM lists about how PXA should handle one-shot mode
with clockevents. It took absolutely ages to get agreement on what was
a simple patch.

commit 91bc51d8a10b00d8233dd5b6f07d7eb40828b87d
Author: Russell King <rmk@dyn-67.arm.linux.org.uk>
Date:   Thu Nov 8 23:35:46 2007 +0000

    [ARM] pxa: fix one-shot timer mode

    One-shot timer mode on PXA has various bugs which prevent kernels
    build with NO_HZ enabled booting.  They end up spinning on a
    permanently asserted timer interrupt because we don't properly
    clear it down - clearing the OIER bit does not stop the pending
    interrupt status.  Fix this in the set_mode handler as well.

    Moreover, the code which sets the next expiry point may race with
    the hardware, and we might not set the match register sufficiently
    in the future.  If we encounter that situation, return -ETIME so
    the generic time code retries.

    Acked-by: Thomas Gleixner <tglx@linutronix.de>
    Acked-by: Nicolas Pitre <nico@cam.org>
    Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Ergo, the bug can be closed provided the reporter re-tests a recent git
snapshot.  Sorry, no idea how the above commit relates to Linus' releases
and/or git snapshots.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:
