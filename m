From: Jeff Mahoney <jeffm-IBi9RG/b67k@public.gmane.org>
Subject: Re: [PATCH] build some drivers only when compile-testing
Date: Wed, 22 May 2013 23:09:42 -0400
Message-ID: <519D8876.9050405@suse.com>
References: <1369214326-6558-1-git-send-email-jslaby@suse.cz> <20130523022327.GB6159@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>, jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Alexander Shishkin <alexander.shishkin-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Florian Tobias Schandinat <FlorianSchandinat-Mmb7MZpHnFY@public.gmane.org>,
	linux-geode-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	"Keller, Jacob E" <jacob.e.keller-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130523022327.GB6159-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 5/22/13 10:23 PM, Greg Kroah-Hartman wrote:
> On Wed, May 22, 2013 at 11:18:46AM +0200, Jiri Slaby wrote:
>> Some drivers can be built on more platforms than they run on. This
>> causes users and distributors packaging burden when they have to
>> manually deselect some drivers from their allmodconfigs. Or sometimes
>> it is even impossible to disable the drivers without patching the
>> kernel.
>>
>> Introduce a new config option COMPILE_TEST and make all those drivers
>> to depend on the platform they run on, or on the COMPILE_TEST option.
>> Now, when users/distributors choose COMPILE_TEST=n they will not have
>> the drivers in their allmodconfig setups, but developers still can
>> compile-test them with COMPILE_TEST=y.
> 
> I understand the urge, and it's getting hard for distros to handle these
> drivers that just don't work on other architectures, but it's really
> valuable to ensure that they build properly, for those of us that don't
> have many/any cross compilers set up.
> 
>> Now the drivers where we use this new option:
>> * PTP_1588_CLOCK_PCH: The PCH EG20T is only compatible with Intel Atom
>>   processors so it should depend on x86.
>> * FB_GEODE: Geode is 32-bit only so only enable it for X86_32.
>> * USB_CHIPIDEA_IMX: The OF_DEVICE dependency will be met on powerpc
>>   systems -- which do not actually support the hardware via that
>>   method.
> 
> This seems ripe to start to get really messy, really quickly.  Shouldn't
> "default configs" handle if this "should" be enabled for a platform or
> not, and let the rest of us just build them with no problems?

If every time a new Kconfig option is added, corresponding default
config updates come with it, sure. I just don't see that happening,
especially when it can be done much more clearly in the Kconfig while
the developer is writing the driver.

> What problems is this causing you?  Are you running out of space in
> kernel packages with drivers that will never be actually used?

Wasted build resources. Wasted disk space on /every/ system the kernel
package is installed on. We're all trying to pare down the kernel
packages to eliminate wasted space and doing it manually means a bunch
of research, sometimes with incorrect assumptions about the results,
needs to be done by someone not usually associated with that code. That
research gets repeated by people maintaining kernel packages for pretty
much every distro.

>> +config COMPILE_TEST
>> +	bool "Compile also drivers which will not load" if EXPERT
> 
> EXPERT is getting to be the "let's hide it here" option, isn't it...
> 
> I don't know, if no one else strongly objects, I can be convinced that
> this is needed, but so far, I don't see why it really is, or what this
> is going to help with.

I'm not convinced adding a || COMPILE_TEST option to every driver that
may be arch specific is the best way to go either. Perhaps adding a new
Kconfig verb called "archdepends on" or something that will evaluate as
true if COMPILE_TEST is enabled but will evaluate the conditional if
not. *waves hands*

-Jeff

-- 
Jeff Mahoney
SUSE Labs
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
