From: Greg KH <gregkh@suse.de>
Subject: Re: Can we remove pci_find_device() yet?
Date: Mon, 11 Jan 2010 12:01:36 -0800
Message-ID: <20100111200136.GA29955@suse.de>
References: <20100108112236.462a3da2.sfr@canb.auug.org.au>
 <20100108044646.GC6611@suse.de>
 <4B4B802A.2010709@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:60778 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754082Ab0AKUGI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jan 2010 15:06:08 -0500
Content-Disposition: inline
In-Reply-To: <4B4B802A.2010709@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 11, 2010 at 08:46:50PM +0100, Tilman Schmidt wrote:
> Am 08.01.2010 05:46 schrieb Greg KH:
> > On Fri, Jan 08, 2010 at 11:22:36AM +1100, Stephen Rothwell wrote:
> >>
> >> This interface has been deprecated since November 2006, so can something
> >> be done about the last users (I think only some ISDN drivers)?
> 
> That would be the HiSax I4L drivers.
> 
> > Ick, the "new" isdn drivers are still not merged that replace those
> > older ones?  I thought that happened a while ago.
> 
> mISDN, which is the designated successor to HiSax, has indeed been
> merged in 2008.
> 
> Trouble is, mISDN's userspace interface is completely different from I4L.
> Removing HiSax would therefore break userspace compatibility for current
> users of HiSax supported devices. In order to switch to mISDN they'll
> have to replace all of their ISDN4Linux applications with equivalent
> mISDN ones, and I'm not even sure there is a replacement for everything.
> 
> Just an idea - as a stopgap measure, couldn't pci_find_device() be made
> a private function of the HiSax drivers? That way, the remainder of the
> kernel won't be polluted by it anymore, and the PCI_LEGACY config option
> can be dropped. Something like this quick and dirty hack:

Close, but if you do this, please name the function
hisax_find_pci_device() or something, and change the drivers to use it
instead.  Also put a big fat warning in the function that calling this
is unsafe for any PCI hotplug type machine.

thanks,

greg k-h
