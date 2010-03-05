From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/2] device.h drivers/base/core.c Convert dev_<level>
 macros to functions
Date: Thu, 04 Mar 2010 18:46:11 -0800
Message-ID: <1267757171.12993.111.camel@Joe-Laptop.home>
References: <cover.1267682641.git.joe@perches.com>
	 <f2b24d484347c083fa87856a75c1d96102af9005.1267682641.git.joe@perches.com>
	 <20100304165609.20849b93.akpm@linux-foundation.org>
	 <20100304170030.f97c6630.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Nick Andrew <nick@nick-andrew.net>,
	linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1402 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754666Ab0CECqN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Mar 2010 21:46:13 -0500
In-Reply-To: <20100304170030.f97c6630.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dOn Thu, 2010-03-04 at 17:00 -0800, Andrew Morton wrote:
> On Thu, 4 Mar 2010 16:56:09 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Wed,  3 Mar 2010 22:27:23 -0800 Joe Perches <joe@perches.com> wrote:
> > > Save ~60k in a defconfig
> > > Use %pV and struct va_format
> > > Format arguments are verified before printk
> > Well that doesn't work very well.
> > 
> > drivers/net/pcmcia/pcnet_cs.c:117: error: 'dev_info' redeclared as different kind of symbol
> > include/linux/device.h:645: error: previous declaration of 'dev_info' was here
> > 
> > there are lots of other dev_info's which will fail plus perhaps
> > dev_err's, etc.
> > 
> btw, this may be kludgeable aroundable by doing
> 
> int _dev_info(const struct device *dev, const char *fmt, ...);
> 
> #define dev_info(...) _dev_info(...)
> 
> which will use the preprocessor's separation of `foo' from `foo()' to
> fix things up.
> 
> But it would be better to rename all those dev_info's to device_info or
> whatever, IMO.

Perhaps using the function name _dev_info() and adding
the macro above is an acceptable workaround until the
dev_info struct names or local variable names could be
renamed if necessary.

dev_err and dev_warn exist in source comments only and
don't seem to be a problem.

David Miller?  Do you have an opinion on the renaming
of dev_info local variables and structs?

