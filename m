From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: netconsole fun
Date: Mon, 29 Apr 2013 13:28:45 -0400
Message-ID: <1367256525.3494.10.camel@thor.lan>
References: <20121211164526.GB7481@neilslaptop.think-freely.org>
	 <1355345957.2687.18.camel@thor>
	 <20121213123611.GA12269@hmsreliant.think-freely.org>
	 <1355410171.2605.17.camel@thor>
	 <20121213180815.GA14796@hmsreliant.think-freely.org>
	 <1355426821.2612.16.camel@thor>
	 <20121213211754.GC14796@hmsreliant.think-freely.org>
	 <1355437480.2612.33.camel@thor>
	 <20121214142018.GA24846@shamino.rdu.redhat.com>
	 <1355580838.2467.39.camel@thor>
	 <20121217142030.GB25322@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout01.c08.mtsvc.net ([205.186.168.189]:54814 "EHLO
	mailout01.c08.mtsvc.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757381Ab3D2R2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 13:28:55 -0400
In-Reply-To: <20121217142030.GB25322@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-12-17 at 09:20 -0500, Neil Horman wrote:
> On Sat, Dec 15, 2012 at 09:13:58AM -0500, Peter Hurley wrote:
> > On Fri, 2012-12-14 at 09:20 -0500, Neil Horman wrote:
> > > Ah!  I'm sorry, I didn't realize this was really about getting netconsole up
> > > early in the boot, rather than just getting it up robustly using the startup
> > > script.
> > 
> > Well, it's both but I should have been clearer here. Sorry about that.
> > 
> > > If thats the case, then I would recommend that you modify the initramfs
> > > to do something simmilar to the startup script (since thats where the netconsole
> > > module will get loaded anyway).  You can write a script there that will let you
> > > specify the destination ip address and figure out the output dev based on the
> > > routing tables.  If you're using dracut to build your initramfs, then this
> > > should be pretty straightforward.
> > 
> > When I get some more free time I'll experiment with this approach.
> > 
> > Just to clarify something from earlier in the discussion:
> > 
> > On Thu, 2012-12-13 at 13:08 -0500, Neil Horman wrote:
> > > On Thu, Dec 13, 2012 at 09:49:31AM -0500, Peter Hurley wrote:
> > ....
> > > > There is an unforeseen consequence of the patch: it breaks device
> > > > renaming because the device will already be in use by netconsole. Which
> > > > is the whole problem with userspace device renaming to begin with...
> > > > 
> > > That is bad, but see above, the netconsole service can work around this for you,
> > > allowing you to never have to specify a particular device at all.
> > 
> > The breakage is a normal consequence of being able to load netconsole
> > before the udev rules that do device renaming. The same thing would
> > happen modifying initramfs.
> > 
> > Basically, once netconsole attaches to a device, that device cannot be
> > renamed. Unfortunately, the default udev behavior messes things up
> > further because it will try to do this:
> >   eth0->eth1
> >   eth1->eth0
> > which means neither device will be renamed.
> > 
> > Maybe the net core should just implement persistent device names ;)
> > 
> Theres no good way for the kernel to do that, as persistent naming in this case
> is a matter of user policy, not kernel hardware management (i.e. do you want a
> network name to follow a mac address, a pci slot, or the network its connected
> to)?  You can use smbios to get some modicum of persistent device naming
> currently, but I don't recall if that requires udev rules to implement as well
> 
> You're best bet is to simply make your initramfs more robust.  I understand what
> you're saying regarding renaming after you've taken a reference on a device not
> being possible, but you can run udev within the initramfs, and do your renaming
> prior to your netconsole load.

Hi Neil,

I plan to re-submit 'netconsole: allow mac addr to specify local
interface device' which you originally objected to because you asserted
that the same effect could be obtained through udev scripts in the
initramfs.

When you shot down this patch, did you actually try what you suggested
in the initramfs or were you just hypothesizing that it would possible?

Regards,
Peter Hurley
