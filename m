From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] build some drivers only when compile-testing
Date: Wed, 22 May 2013 19:23:27 -0700
Message-ID: <20130523022327.GB6159@kroah.com>
References: <1369214326-6558-1-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jirislaby@gmail.com, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jeff Mahoney <jeffm@suse.com>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	linux-usb@vger.kernel.org,
	Florian Tobias Schandinat <FlorianSchandinat@gmx.de>,
	linux-geode@lists.infradead.org, linux-fbdev@vger.kernel.org,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org, Ben Hutchings <ben@decadent.org.uk>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1369214326-6558-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 22, 2013 at 11:18:46AM +0200, Jiri Slaby wrote:
> Some drivers can be built on more platforms than they run on. This
> causes users and distributors packaging burden when they have to
> manually deselect some drivers from their allmodconfigs. Or sometimes
> it is even impossible to disable the drivers without patching the
> kernel.
> 
> Introduce a new config option COMPILE_TEST and make all those drivers
> to depend on the platform they run on, or on the COMPILE_TEST option.
> Now, when users/distributors choose COMPILE_TEST=n they will not have
> the drivers in their allmodconfig setups, but developers still can
> compile-test them with COMPILE_TEST=y.

I understand the urge, and it's getting hard for distros to handle these
drivers that just don't work on other architectures, but it's really
valuable to ensure that they build properly, for those of us that don't
have many/any cross compilers set up.

> Now the drivers where we use this new option:
> * PTP_1588_CLOCK_PCH: The PCH EG20T is only compatible with Intel Atom
>   processors so it should depend on x86.
> * FB_GEODE: Geode is 32-bit only so only enable it for X86_32.
> * USB_CHIPIDEA_IMX: The OF_DEVICE dependency will be met on powerpc
>   systems -- which do not actually support the hardware via that
>   method.

This seems ripe to start to get really messy, really quickly.  Shouldn't
"default configs" handle if this "should" be enabled for a platform or
not, and let the rest of us just build them with no problems?

What problems is this causing you?  Are you running out of space in
kernel packages with drivers that will never be actually used?

> +config COMPILE_TEST
> +	bool "Compile also drivers which will not load" if EXPERT

EXPERT is getting to be the "let's hide it here" option, isn't it...

I don't know, if no one else strongly objects, I can be convinced that
this is needed, but so far, I don't see why it really is, or what this
is going to help with.

thanks,

greg k-h
