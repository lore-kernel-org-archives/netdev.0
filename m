From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [GIT]: Networking
Date: Tue, 6 Jan 2009 09:11:35 +0100
Message-ID: <20090106081135.GA12695@uranus.ravnborg.org>
References: <20090105.204934.65827705.davem@davemloft.net> <3f9a31f40901052114t68cac881md439bf24b602f269@mail.gmail.com> <20090106055144.GA11695@uranus.ravnborg.org> <20090105.220742.176919041.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jaswinderlinux@gmail.com, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dwmw2@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752668AbZAFIKN@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090105.220742.176919041.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 05, 2009 at 10:07:42PM -0800, David Miller wrote:
> From: Sam Ravnborg <sam@ravnborg.org>
> Date: Tue, 6 Jan 2009 06:51:44 +0100
> 
> > We should avoid a central file and push this information
> > out to the Kconfig files that are at the driver site.
> > 
> > Then we can postprocess autoconf.h to get the filenames etc.
> 
> I'll take this opportunity to once again promote my idea wherein build
> information (and perhaps other bits like firmware info) for a driver
> is encoded into the source of the driver itself, and the build system
> just extracts that stuff into Makefiles and whatnot at build time. :-)

One of the pratical issues I have with this is when to read which files.

What we could do is something like:

- during *config scan all "wildcard enabled" directories
  and read the Kconfig info from the relevant .C files.
- record which .C files which included Kconfig and do
  an automatic "scan + oldconfig" when one of these files
  changes

When we add new Kconfig info to a file we would have
to manually do the *config to trigger a scan for the .C files


In the .C file we should restrict us to the first 100 lines or so
to have the Kconfig info to speedd up the 'parse' for this info.

Something like this:

/* Kconfig
config FOO
	tristate "A self contained driver"
	depends on USB
	source mydriver-debug.c if DEBUG
	modulename foobar
	help
	  This is a driver for ...
*/

The source file where this info is contained is implicit a source
of this module.
And if we can convince the firmware guys then the firmware info could
be included in the same section.


	Sam
