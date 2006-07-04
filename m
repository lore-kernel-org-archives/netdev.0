From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: tiacx - don't use UTS_RELEASE
Date: Tue, 4 Jul 2006 11:51:05 +0200
Message-ID: <20060704095105.GB24298@mars.ravnborg.org>
References: <1152004080.3109.18.camel@laptopd505.fenrus.org> <20060704022537.97f703b4.akpm@osdl.org> <1152005247.3109.22.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:28378 "EHLO pasmtp.tele.dk")
	by vger.kernel.org with ESMTP id S932181AbWGDJvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2006 05:51:10 -0400
To: Arjan van de Ven <arjan@infradead.org>
Content-Disposition: inline
In-Reply-To: <1152005247.3109.22.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 04, 2006 at 11:27:27AM +0200, Arjan van de Ven wrote:
> On Tue, 2006-07-04 at 02:25 -0700, Andrew Morton wrote:
> > On Tue, 04 Jul 2006 11:07:59 +0200
> > Arjan van de Ven <arjan@infradead.org> wrote:
> > 
> > > patch below removes the use of UTS_RELEASE from the tiacx driver; there
> > > is absolutely no reason for a driver to print the kernel version or use
> > > the UTS_RELEASE field; in addition this field changes all the time so
> > > this causes spurious rebuilds..
> > 
> > http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/gregkh-04-usb/usb-storage-uname-in-pr-sc-unneeded-message.patch did it too.
> > 
> > UTS_RELEASE doesn't change much.  It's "2.6.17".
> 
> no but the header that it's in changes all the time iirc, at least it
> used to (one of those kbuild regenerated files)
Yesterday I pushed a change that splitted include/linux/version.h in two
parts.
Now include/linux/version.h only contains:
#define LINUX_VERSION_CODE 132625
#define KERNEL_VERSION(a,b,c) (((a) << 16) + ((b) << 8) + (c))

And the file wil only be regenerated when the file-content actually
changes.

And UTS_RELEASE has moved to include/linux/utsrelease.h which contains:
#define UTS_RELEASE "2.6.17-g05668381-dirty"

This is the file that will change often - at least for git users.
But with the patch only users of UTS_RELEASE will be rebuild which is
far less than users of version.h.

	Sam
