From: Greg KH <greg@kroah.com>
Subject: Re: [Ksummit-2010-discuss] [v2] Remaining BKL users, what to do
Date: Mon, 18 Oct 2010 19:24:13 -0700
Message-ID: <20101019022413.GB30307@kroah.com>
References: <201009161632.59210.arnd@arndb.de> <201010181742.06678.arnd@arndb.de> <20101018184346.GD27089@kroah.com> <AANLkTin2KPNNXvwcWphhM-5qexB14FS7M7ezkCCYCZ2H@mail.gmail.com> <20101019004004.GB28380@kroah.com> <AANLkTi=ffaihP5-yNYFKAbAbX+XbRgWRXXfCZd4J3KwQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, codalist@telemann.coda.cs.cmu.edu,
	ksummit-2010-discuss@lists.linux-foundation.org,
	autofs@linux.kernel.org, Jan Harkes <jaharkes@cs.cmu.edu>,
	Samuel Ortiz <samuel@sortiz.org>, Jan Kara <jack@suse.cz>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org, Anders Larsen <al@alarsen.net>,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	Bryan Schumaker <bjschuma@netapp.com>,
	Christoph Hellwig <hch@infradead.org>,
	Petr Vandrovec <vandrove@vc.cvut.cz>,
	Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>,
	linux-fsdevel@vger.kernel.org,
	Evgeniy Dushistov <dushistov@mail.ru>,
	Ingo Molnar <mingo@elte.hu>,
	Andrew Hendry <andrew.hendry@gmail.com>,
	linux-media@vger.kernel.org
To: Dave Airlie <airlied@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTi=ffaihP5-yNYFKAbAbX+XbRgWRXXfCZd4J3KwQ@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 19, 2010 at 10:57:43AM +1000, Dave Airlie wrote:
> On Tue, Oct 19, 2010 at 10:40 AM, Greg KH <greg@kroah.com> wrote:
> > On Tue, Oct 19, 2010 at 09:00:09AM +1000, Dave Airlie wrote:
> >> On Tue, Oct 19, 2010 at 4:43 AM, Greg KH <greg@kroah.com> wrote:
> >> > On Mon, Oct 18, 2010 at 05:42:06PM +0200, Arnd Bergmann wrote:
> >> >>
> >> >> Out of the remaining modules, I guess i810/i830, adfs, hpfs and ufs might end
> >> >> up not getting fixed at all, we can either mark them non-SMP or move them
> >> >> to drivers/staging once all the others are done.
> >> >
> >> > I recommend moving them to staging, and then retire them from there if
> >> > no one steps up to maintain them.
> >>
> >> I think this sets a bad precedent, these drivers work fine. Removing
> >> BKL from them is hard, and involves finding and booting hw that
> >> developers don't have much time/interest in at the moment. Anyone who
> >> has access to the i810 hw and has time to work out the locking has
> >> more important things to be doing with modern hw, however it doesn't
> >> mean we should just drop support for old drivers because they don't
> >> have active maintainers. Removing the BKL from the kernel is a great
> >> goal, but breaking userspace ABI by removing drivers isn't.
> >
> > Should we just restrict such drivers to only be able to build on UP
> > machines with preempt disabled so that the BKL could be safely removed
> > from them?
> >
> > Or what other idea do you have as to what could be done here?
> >
> > I do have access to this hardware, but its on an old single processor
> > laptop, so any work that it would take to help do this development,
> > really wouldn't be able to be tested to be valid at all.
> 
> There is only very rare case where the i830 driver might get used with
> SMP and really I think that case is in the don't care place, since if
> you have that hw you probably should be using i915 on it anyways.

So, there is no need for the i830 driver?  Can it just be removed
because i915 works instead?

> So it really only leaves the problem case of what do distros do if we
> mark things as BROKEN_ON_SMP, since no distro builds UP kernels and
> when you boot the SMP kernels on UP they don't run as SMP so not
> having the driver load on those is a problem. Maybe we just need some
> sort of warn on smp if a smp unfriendly driver is loaded and we
> transition to SMP mode. Though this sounds like either (a) something
> we do now and I don't about it, (b) work.

So you are saying that just because distros will never build such a
thing, we should keep it building for SMP mode?  Why not prevent it from
being built and if a distro really cares, then they will pony up the
development to fix the driver up?

In other words, if someone really cares, then they will do the work,
otherwise why worry?  Especially as it seems that no one here is going
to do it, right?

thanks,

greg k-h
