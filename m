From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.28-git8: tg3 doesn't work due to firmware not loading
 (-git7 is ok)
Date: Tue, 13 Jan 2009 12:27:03 -0800 (PST)
Message-ID: <20090113.122703.157508326.davem@davemloft.net>
References: <1231676698.25018.147.camel@macbook.infradead.org>
	<20090111.133929.57600645.davem@davemloft.net>
	<20090113183948.GA21847@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, Valdis.Kletnieks@vt.edu,
	alessandro.suardi@gmail.com, jaswinderlinux@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39761
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752599AbZAMU1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 15:27:02 -0500
In-Reply-To: <20090113183948.GA21847@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Tue, 13 Jan 2009 10:39:48 -0800

> On Sun, Jan 11, 2009 at 01:39:29PM -0800, David Miller wrote:
> > From: David Woodhouse <dwmw2@infradead.org>
> > Date: Sun, 11 Jan 2009 12:24:58 +0000
> > 
> > > Other drivers will load the firmware later, at the time the device is
> > > brought up. This means that even if you build the driver into the kernel
> > > without its firmware, it can still request the firmware later, when you
> > > try to start _using_ it. And when the file system is available.
> > 
> > For example, for mounting an NFS root using that device.... Oh, will I
> > need an initramfs for that once you pull the firmware-in-kernel
> > option?
> > 
> > To me, device probe is in fact the place to fail firmware discovery
> > for networking devices.  Because such a failure can mean you can't
> > mount your root filesystem.
> 
> David, is this the direction you want to take the fix?  I'm sitting on
> a patch that elaborates on David Woodhouse's work which moves the
> request_firmware call to tg3_open().  Before I posted it for comment,
> I wanted to make sure the patch is moving in the right direction.

You can post it, sure.

But it doesn't actually fix the nfsroot case, that will still be
broken.
