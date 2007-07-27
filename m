From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH] Merge the Sonics Silicon Backplane subsystem
Date: Fri, 27 Jul 2007 13:12:49 -0700
Message-ID: <20070727131249.74330a3d.akpm@linux-foundation.org>
References: <200707271857.24162.mb@bu3sch.de>
	<200707272130.48973.mb@bu3sch.de>
	<20070727123853.d16e875c.akpm@linux-foundation.org>
	<200707272143.59551.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200707272143.59551.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 27 Jul 2007 21:43:59 +0200
Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org> wrote:

> > Sure, but why is the locking interruptible rather than plain old
> > mutex_lock()?
> 
> Hm, well. We hold this mutex for several seconds, as writing takes
> this long. So I simply thought it was worth allowing the waiter
> to interrupt here. If you say that's not an issue, I'll be happy
> to use mutex_lock() and reduce code complexity in this area.

So..  is that what the _interruptible() is for?  To allow an impatient user to ^c
a read?

If so, that sounds reasonable.  It's worth a comment explaining these decisions
to future readers, because it is hard to work out this sort of thinking just
from the bare C code.
