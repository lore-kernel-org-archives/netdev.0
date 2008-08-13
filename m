From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- experimental revert for 2.6.27 failed
Date: Wed, 13 Aug 2008 05:03:19 -0700 (PDT)
Message-ID: <108777.49875.qm@web82104.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>, Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82104.mail.mud.yahoo.com ([209.191.84.217]:36535 "HELO
	web82104.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752099AbYHMMDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 08:03:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> please try attached patch with 2.6.27-rc3

Thx for the patch... and for providing it as an attachment.  My email
situation is less than optimal, and I am stuck using my ISP's web 
interface for the present.

I used 'git apply --check <patchfilename>' first, and got no errors, so
I applied it, built, installed, and rebooted.

The kernel froze in the same way as the others.


BTW, I saw a new last line of output -- which may or may not be
relevant -- but I thought I should mention it since I had never seen 
it before:

With the patched 2.6.27-rc3 kernel, I thought I saw some different 
output during the boot.  The messages were from pnp_system_init(), and 
had to do with not being able to use iomem ranges.  I rebooted one of 
my 2.6.26 kernels (with HPET enabled so it would freeze) so I could
compare the messages, and found that I was wrong:  the messages were not
new, and are probably normal.

However, each time one of these 2.6.2[67] kernels locks up, the last 
line on the screen is the (now familiar) inet_init() message:

NET: Registered protocol family 2


When I booted the older 2.6.26 kernel, I saw something I haven't seen
before:

Clocksource tsc unstable (delta = 4398046170281 ns)


Now, I have experienced aggravating TSC messages at boot ever since I built
my first AMD dual-core machine last year.  I researched the issue, I found
that I could use "notsc" to suppress the messages.  I have GRUB
automatically add the "notsc" parameter for my everyday-usage kernels, but
I have intentionally NOT been using "notsc" for any of the freezing kernels
about which I have been reporting information here.  (I have tried "notsc"
before as an experiment, but it does not prevent freezing.)

Getting a TSC message when not using "notsc" is no surprise.  I only mention
it because this is the first time I have seen that message as the last 
output line during a freeze.

Beware:  this TSC output happened just now with an older 2.6.26 kernel, not
with the patched 2.6.27-rc3 kernel... so it has nothing to do with the new
patch.  That time "delta" is ridiculous:  4398 seconds.  Total time from
GRUB to freeze is < 3 seconds.  It reminds me of info I posted before about
the pci_bios_assign_resources() initcall falsely reporting a return in 
285000+ msecs.


Thanks,
Dave W.
