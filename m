From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] build some drivers only when compile-testing
Date: Tue, 18 Jun 2013 09:04:27 -0700
Message-ID: <20130618160427.GE28961@kroah.com>
References: <1369214326-6558-1-git-send-email-jslaby@suse.cz>
 <20130523022327.GB6159@kroah.com>
 <519D8876.9050405@suse.com>
 <51BF6BFF.7050705@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Mahoney <jeffm@suse.com>, jirislaby@gmail.com,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	linux-usb@vger.kernel.org,
	Florian Tobias Schandinat <FlorianSchandinat@gmx.de>,
	linux-geode@lists.infradead.org, linux-fbdev@vger.kernel.org,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org, Ben Hutchings <ben@decadent.org.uk>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	Michal Marek <mmarek@suse.cz>, tomi.valkeinen@ti.com
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51BF6BFF.7050705@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 17, 2013 at 10:05:19PM +0200, Jiri Slaby wrote:
> On 05/23/2013 05:09 AM, Jeff Mahoney wrote:
> > On 5/22/13 10:23 PM, Greg Kroah-Hartman wrote:
> >> On Wed, May 22, 2013 at 11:18:46AM +0200, Jiri Slaby wrote:
> >>> Some drivers can be built on more platforms than they run on. This
> >>> causes users and distributors packaging burden when they have to
> >>> manually deselect some drivers from their allmodconfigs. Or sometimes
> >>> it is even impossible to disable the drivers without patching the
> >>> kernel.
> >>>
> >>> Introduce a new config option COMPILE_TEST and make all those drivers
> >>> to depend on the platform they run on, or on the COMPILE_TEST option.
> >>> Now, when users/distributors choose COMPILE_TEST=n they will not have
> >>> the drivers in their allmodconfig setups, but developers still can
> >>> compile-test them with COMPILE_TEST=y.
> >>
> >> I understand the urge, and it's getting hard for distros to handle these
> >> drivers that just don't work on other architectures, but it's really
> >> valuable to ensure that they build properly, for those of us that don't
> >> have many/any cross compilers set up.
> 
> But this is exactly what COMPILE_TEST will give us when set to "y", or
> am I missing something?
> 
> >>> Now the drivers where we use this new option:
> >>> * PTP_1588_CLOCK_PCH: The PCH EG20T is only compatible with Intel Atom
> >>>   processors so it should depend on x86.
> >>> * FB_GEODE: Geode is 32-bit only so only enable it for X86_32.
> >>> * USB_CHIPIDEA_IMX: The OF_DEVICE dependency will be met on powerpc
> >>>   systems -- which do not actually support the hardware via that
> >>>   method.
> >>
> >> This seems ripe to start to get really messy, really quickly.  Shouldn't
> >> "default configs" handle if this "should" be enabled for a platform or
> >> not, and let the rest of us just build them with no problems?
> > 
> > If every time a new Kconfig option is added, corresponding default
> > config updates come with it, sure. I just don't see that happening,
> > especially when it can be done much more clearly in the Kconfig while
> > the developer is writing the driver.
> > 
> >> What problems is this causing you?  Are you running out of space in
> >> kernel packages with drivers that will never be actually used?
> > 
> > Wasted build resources. Wasted disk space on /every/ system the kernel
> > package is installed on. We're all trying to pare down the kernel
> > packages to eliminate wasted space and doing it manually means a bunch
> > of research, sometimes with incorrect assumptions about the results,
> > needs to be done by someone not usually associated with that code. That
> > research gets repeated by people maintaining kernel packages for pretty
> > much every distro.
> 
> I second all the above.
> 
> >>> +config COMPILE_TEST
> >>> +	bool "Compile also drivers which will not load" if EXPERT
> >>
> >> EXPERT is getting to be the "let's hide it here" option, isn't it...
> >>
> >> I don't know, if no one else strongly objects, I can be convinced that
> >> this is needed, but so far, I don't see why it really is, or what this
> >> is going to help with.
> > 
> > I'm not convinced adding a || COMPILE_TEST option to every driver that
> > may be arch specific is the best way to go either. Perhaps adding a new
> > Kconfig verb called "archdepends on" or something that will evaluate as
> > true if COMPILE_TEST is enabled but will evaluate the conditional if
> > not. *waves hands*
> 
> Sam Ravnborg (the kconfig ex-maintainer) once wrote that he doesn't want
> to extend the kconfig language for this purpose (which I support). That
> a config option is fine and sufficient in this case [1]. Except he
> called the config option "SHOW_ALL_DRIVERS". Adding the current
> maintainer to CCs ;).
> 
> [1] http://comments.gmane.org/gmane.linux.kbuild.devel/9829
> 
> The last point I inclined to the Greg's argument to remove the EXPERT
> dependency.
> 
> So currently I have what is attached... Comments?

Looks good to me, want me to queue it up through my char/misc driver
tree for 3.11?

thanks,

greg k-h
