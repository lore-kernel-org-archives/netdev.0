From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Ksummit-2010-discuss] [v2] Remaining BKL users, what to do
Date: Tue, 19 Oct 2010 15:26:01 +0200
Message-ID: <201010191526.01887.arnd@arndb.de>
References: <201009161632.59210.arnd@arndb.de> <AANLkTi=oAeuz8ZxcOMpf=3MVY=WMt0BwHiGCUxO7OAEV@mail.gmail.com> <201010190926.54635.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Theodore Kilgore <kilgota@banach.math.auburn.edu>,
	Steven Rostedt <rostedt@goodmis.org>, Greg KH <greg@kroah.com>,
	codalist@telemann.coda.cs.cmu.edu, autofs@linux.kernel.org,
	Samuel Ortiz <samuel@sortiz.org>, Jan Kara <jack@suse.cz>,
	Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>,
	Jan Harkes <jaharkes@cs.cmu.edu>, netdev@vger.kernel.org,
	Anders Larsen <al@alarsen.net>, linux-kernel@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	Bryan Schumaker <bjschuma@netapp.com>,
	Christoph Hellwig <hch@infradead.org>,
	ksummit-2010-discuss@lists.linux-foundation.org,
	Petr Vandrovec <vandrove@vc.cvut.cz>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	linux-fsdevel@vger.kernel.org,
	Evgeniy Dushistov <dushistov@mail.ru>,
	Ingo Molnar <mingo@elte.hu>,
	Andrew Hendry <andrew.hendry@gmail.com>,
	linux-media@vger.kernel.org
To: Dave Airlie <airlied@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201010190926.54635.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 19 October 2010, Arnd Bergmann wrote:
> On Tuesday 19 October 2010 06:52:32 Dave Airlie wrote:
> > > I might be able to find some hardware still lying around here that uses an
> > > i810. Not sure unless I go hunting it. But I get the impression that if
> > > the kernel is a single-CPU kernel there is not any problem anyway? Don't
> > > distros offer a non-smp kernel as an installation option in case the user
> > > needs it? So in reality how big a problem is this?
> > 
> > Not anymore, which is my old point of making a fuss. Nowadays in the
> > modern distro world, we supply a single kernel that can at runtime
> > decide if its running on SMP or UP and rewrite the text section
> > appropriately with locks etc. Its like magic, and something like
> > marking drivers as BROKEN_ON_SMP at compile time is really wrong when
> > what you want now is a runtime warning if someone tries to hotplug a
> > CPU with a known iffy driver loaded or if someone tries to load the
> > driver when we are already in SMP mode.
> 
> We could make the driver run-time non-SMP by adding
> 
> 	if (num_present_cpus() > 1) {
> 		pr_err("i810 no longer supports SMP\n");
> 		return -EINVAL;
> 	}
> 
> to the init function. That would cover the vast majority of the
> users of i810 hardware, I guess.

Some research showed that Intel never support i810/i815 SMP setups,
but there was indeed one company (http://www.acorpusa.com at the time,
now owned by a domain squatter) that made i815E based dual Pentium-III
boards like this one: http://cgi.ebay.com/280319795096

The first person that can send me an authentic log file showing the
use of X.org with DRM on a 2.6.35 kernel with two processors on that
mainboard dated today or earlier gets a free upgrade to an AGP graphics
card of comparable or better 3D performance from me. Please include
the story how why you are running this machine with a new kernel.

i830 is harder, apparently some i865G boards support Pentium 4 with HT
and even later dual-core processors.

	Arnd
