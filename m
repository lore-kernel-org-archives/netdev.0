From: Dmitry Torokhov <dtor@insightbb.com>
Subject: Re: [PATCH] Merge the Sonics Silicon Backplane subsystem
Date: Sun, 29 Jul 2007 00:45:06 -0400
Message-ID: <200707290045.07990.dtor@insightbb.com>
References: <200707271857.24162.mb@bu3sch.de> <200707272143.59551.mb@bu3sch.de> <20070727131249.74330a3d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Gary Zambrano <zambrano@broadcom.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756191AbXG2Epb@vger.kernel.org>
In-Reply-To: <20070727131249.74330a3d.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 27 July 2007 16:12, Andrew Morton wrote:
> On Fri, 27 Jul 2007 21:43:59 +0200
> Michael Buesch <mb@bu3sch.de> wrote:
> 
> > > Sure, but why is the locking interruptible rather than plain old
> > > mutex_lock()?
> > 
> > Hm, well. We hold this mutex for several seconds, as writing takes
> > this long. So I simply thought it was worth allowing the waiter
> > to interrupt here. If you say that's not an issue, I'll be happy
> > to use mutex_lock() and reduce code complexity in this area.
> 
> So..  is that what the _interruptible() is for?  To allow an impatient user to ^c
> a read?
> 
> If so, that sounds reasonable.  It's worth a comment explaining these decisions
> to future readers, because it is hard to work out this sort of thinking just
> from the bare C code.

I think most of sysfs ->show() and ->store() implementations use
_interruptible() variant to allow user to interrupt and return early.

-- 
Dmitry
