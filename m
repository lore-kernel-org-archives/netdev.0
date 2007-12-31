From: Greg KH <greg@kroah.com>
Subject: Re: [usb regression] Re: [PATCH 2.6.24-rc3] Fix /proc/net breakage
Date: Mon, 31 Dec 2007 11:26:43 -0800
Message-ID: <20071231192643.GA25341@kroah.com>
References: <20071231052500.GB4187@kroah.com> <Pine.LNX.4.44L0.0712311237150.7182-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Mohr <andi@lisas.de>, Ingo Molnar <mingo@elte.hu>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Woodhouse <dwmw2@infradead.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Denis V. Lunev" <den@openvz.org>,
	USB list <linux-usb@vger.kernel.org>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:41297 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196AbXLaT2g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 14:28:36 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L0.0712311237150.7182-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 31, 2007 at 12:49:52PM -0500, Alan Stern wrote:
> On Sun, 30 Dec 2007, Greg KH wrote:
> 
> > > It looks like Greg misused the debugfs API -- which is ironic, because
> > > he wrote debugfs in the first place!  :-)
> > 
> > Oh crap, sorry, I did mess that up :(
> > 
> > > Let me know if this patch fixes the problem.  If it does, I'll submit 
> > > it to Greg with all the proper accoutrements.
> > 
> > This isn't going to work if CONFIG_DEBUGFS is not enabled either :(
> 
> Why not?  The debugging files won't be created, true, but the driver
> should work just fine regardless.  This is exactly the way uhci-hcd
> behaves, and it hasn't caused any problems.

Ok, you are right, it was late and after some wine and I shouldn't have
been responding to email :)

I'll rework this, and send out a patch tonight or tomorrow when I get a
chance (am on the road right now).  We should only care about NULL being
returned here, that's the only "real" error.

And in thinking about it some more, I should go audit all the debugfs
callers to make sure they are doing something sane too, it shouldn't be
this complex at all...

thanks,

greg k-h
