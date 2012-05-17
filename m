From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Re: [RFC 13/13] USB: Disable hub-initiated LPM for comms devices.
Date: Thu, 17 May 2012 09:29:22 -0700
Message-ID: <20120517162922.GC4967@xanatos>
References: <cover.1337203535.git.sarah.a.sharp@linux.intel.com>
 <20120516224528.GA25936@xanatos>
 <20120516232019.GA960@kroah.com>
 <20120517045220.GA4772@xanatos>
 <20120517144951.GB27597@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>,
	linux-bluetooth@vger.kernel.org,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	libertas-dev@lists.infradead.org, users@rt2x00.serialmonkey.com
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:5258 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762114Ab2EQQ3l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 12:29:41 -0400
Content-Disposition: inline
In-Reply-To: <20120517144951.GB27597@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 17, 2012 at 07:49:51AM -0700, Greg Kroah-Hartman wrote:
> On Wed, May 16, 2012 at 09:52:20PM -0700, Sarah Sharp wrote:
> > On Wed, May 16, 2012 at 04:20:19PM -0700, Greg Kroah-Hartman wrote:
> > > On Wed, May 16, 2012 at 03:45:28PM -0700, Sarah Sharp wrote:
> > > > The Intel Windows folks are disabling hub-initiated LPM for all USB
> > > > communications devices under a xHCI USB 3.0 host.  In order to keep
> > > > the Linux behavior as close as possible to Windows, we need to do the
> > > > same in Linux.
> > > 
> > > How is the USB core on Windows determining that LPM should be turned off
> > > for these devices?  Surely they aren't modifying each individual driver
> > > like this is, right?  Any way we also can do this in the core?
> > 
> > No, I don't think they're modifying individual drivers.  Maybe they
> > placed a shim/filter driver below other drivers?
> 
> They can do this in their driver by just watching the device class type.
> 
> > Basically, I don't know the exact details of what the Windows folks are
> > doing.  The recommendation from the Intel Windows team was simply to
> > turn hub-initiated LPM off for "all communications devices".  Perhaps
> > the Windows USB core is looking for specific USB class codes?  Or maybe
> > it has some older API that lets the core know it's a communications
> > device?
> > 
> > I'm not really sure we can do it in the USB core with out basically
> > duplicating all the class/PID/VID matching in the communications driver.
> > I think just adding a flag might be the best way.  I'm open to
> > suggestions though.
> 
> You can detect something as "simple" as a class type, which I bet is all
> that Windows is going to be able to do as well.
> 
> > > Or, turn it around the other way, and only enable it if we know it's
> > > safe to do so, in each driver, but I guess that would be even messier.
> > 
> > Yeah, I think it would be messier.
> 
> Ok, this is probably the best solution for us as well, sorry for the
> noise.

No worries. :)

One of the problems with this patch is that several mailing lists
rejected it because of the large number of recipients in the Cc list,
even when just the mailing lists were on the Cc list.  Should I break it
up into a series of patches per driver?

Also, do I need to wait on acks from the other maintainers for this
change?  My instinct is no, since it shouldn't change the behavior of
their drivers with the USB devices that are out there today, but I don't
want to step on anyone's toes.

Sarah Sharp
