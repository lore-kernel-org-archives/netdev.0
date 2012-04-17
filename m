From: Josh Boyer <jwboyer@redhat.com>
Subject: Re: tg3 'No PHY devices' loading issue
Date: Tue, 17 Apr 2012 17:07:00 -0400
Message-ID: <20120417210700.GJ19507@zod.bos.redhat.com>
References: <20120417141856.GA19507@zod.bos.redhat.com>
 <20120417185007.GA3742@mcarlson.broadcom.com>
 <20120417191042.GB3932@decadent.org.uk>
 <20120417194029.GH19507@zod.bos.redhat.com>
 <20120417205955.GC3932@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120417205955.GC3932@decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 17, 2012 at 09:59:55PM +0100, Ben Hutchings wrote:
> On Tue, Apr 17, 2012 at 03:40:30PM -0400, Josh Boyer wrote:
> > On Tue, Apr 17, 2012 at 08:10:42PM +0100, Ben Hutchings wrote:
> > > On Tue, Apr 17, 2012 at 11:50:07AM -0700, Matt Carlson wrote:
> > > > On Tue, Apr 17, 2012 at 10:18:57AM -0400, Josh Boyer wrote:
> > > > > Hi Matt and Michael,
> > > > > 
> > > > > I'm seeing an odd issue with the tg3 driver on one of my development
> > > > > machines.  I've tried kernels 3.2.10, 3.3.0, 3.3.1, 3.3.2 and 3.4-rc3
> > > > > and they all seem to exhibit this issue now.  When the machine boots
> > > > > and the tg3 driver is loaded, it fails to find a PHY and then reports
> > > > > 'Problem fetching invariants of chip'.  If I do a rmmod/modprobe of
> > > > > tg3 after login, the probe seems to work fine and ethernet works as
> > > > > expected.  You can see this in the dmesg below:
> > > [...]
> > > > The 57788 uses the broadcom phylib module.  For some reason, it isn't
> > > > available the first module load attempt.  A while ago, code was added to
> > > > phylib to request modules from userspace if the particular phy support
> > > > code wasn't already loaded.  It looks like this mechanism isn't working
> > > > too well the first time through.
> > > [...]
> > > 
> > > At a guess, tg3 is in the initramfs but broadcom isn't.
> > 
> > Good guess.  At least on one of the initramfs' I checked.  I'll verify
> > the others, but it seems likely they match.  As I just said in my other
> > reply, I would have expected tg3 to have a module dep on it to get it
> > included in the initramfs built, but it seems that isn't the case.
>  
> tg3 doesn't use any symbols from broadcom, which is the only way
> depmod can find dependencies.
> 
> In initramfs-tools (used in Debian and its derivatives) we just copy
> all PHY drivers into the initramfs by default.  dracut should probably
> do the same, at least when phylib is in the initramfs (or built into
> the kernel).  (tg3 does use symbols from phylib.)

Heh.  Yep, that's basically what I just concluded as well in my other
reply.  I'll work with Harald and get that included or something similar
to it.

josh
