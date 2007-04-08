From: Pavel Machek <pavel@ucw.cz>
Subject: Re: mm snapshot broken-out-2007-04-07-03-27.tar.gz uploaded
Date: Sun, 8 Apr 2007 12:42:45 +0000
Message-ID: <20070408124244.GA4404@ucw.cz>
References: <200704071029.l37ATdKR032505@shell0.pdx.osdl.net> <4617F455.2050401@googlemail.com> <20070407131000.e3007eac.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gprs189-60.eurotel.cz ([160.218.189.60]:1070 "EHLO spitz.ucw.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751052AbXDHMm5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Apr 2007 08:42:57 -0400
Content-Disposition: inline
In-Reply-To: <20070407131000.e3007eac.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> > > The mm snapshot broken-out-2007-04-07-03-27.tar.gz has been uploaded to
> > > 
> > >    ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/mm/broken-out-2007-04-07-03-27.tar.gz
> > > 
> > > It contains the following patches against 2.6.21-rc6:
> > 
> > suspend-to-disk doesn't work when pktgen module is loaded.
> > 
> > Stopping kernel threads timed out after 20 seconds (2 tasks refusing to freeze):
> >  kpktgend_0
> >  kpktgend_1
> > Restarting tasks ... done.
> > swsusp: Basic memory bitmaps freed
> 
> This?
> 
> --- a/net/core/pktgen.c~pktgen-add-try_to_freeze
> +++ a/net/core/pktgen.c
> @@ -128,6 +128,7 @@
>  #include <linux/ioport.h>
>  #include <linux/interrupt.h>
>  #include <linux/capability.h>
> +#include <linux/freezer.h>
>  #include <linux/delay.h>
>  #include <linux/timer.h>
>  #include <linux/list.h>
> @@ -3325,6 +3326,8 @@ static int pktgen_thread_worker(void *ar
>  			t->control &= ~(T_REMDEV);
>  		}
>  
> +		try_to_freeze();
> +
>  		set_current_state(TASK_INTERRUPTIBLE);

I'd actually prefer freezing it while in INTERRUPTIBLE, but both
versions are probably okay.

							Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
