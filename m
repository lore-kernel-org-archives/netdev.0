From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: netconsole fun
Date: Mon, 17 Dec 2012 09:20:30 -0500
Message-ID: <20121217142030.GB25322@hmsreliant.think-freely.org>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Peter Hurley <peter@hurleysoftware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36370 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752557Ab2LQOUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 09:20:37 -0500
Content-Disposition: inline
In-Reply-To: <1355580838.2467.39.camel@thor>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 15, 2012 at 09:13:58AM -0500, Peter Hurley wrote:
> On Fri, 2012-12-14 at 09:20 -0500, Neil Horman wrote:
> > Ah!  I'm sorry, I didn't realize this was really about getting netconsole up
> > early in the boot, rather than just getting it up robustly using the startup
> > script.
> 
> Well, it's both but I should have been clearer here. Sorry about that.
> 
> > If thats the case, then I would recommend that you modify the initramfs
> > to do something simmilar to the startup script (since thats where the netconsole
> > module will get loaded anyway).  You can write a script there that will let you
> > specify the destination ip address and figure out the output dev based on the
> > routing tables.  If you're using dracut to build your initramfs, then this
> > should be pretty straightforward.
> 
> When I get some more free time I'll experiment with this approach.
> 
> Just to clarify something from earlier in the discussion:
> 
> On Thu, 2012-12-13 at 13:08 -0500, Neil Horman wrote:
> > On Thu, Dec 13, 2012 at 09:49:31AM -0500, Peter Hurley wrote:
> ....
> > > There is an unforeseen consequence of the patch: it breaks device
> > > renaming because the device will already be in use by netconsole. Which
> > > is the whole problem with userspace device renaming to begin with...
> > > 
> > That is bad, but see above, the netconsole service can work around this for you,
> > allowing you to never have to specify a particular device at all.
> 
> The breakage is a normal consequence of being able to load netconsole
> before the udev rules that do device renaming. The same thing would
> happen modifying initramfs.
> 
> Basically, once netconsole attaches to a device, that device cannot be
> renamed. Unfortunately, the default udev behavior messes things up
> further because it will try to do this:
>   eth0->eth1
>   eth1->eth0
> which means neither device will be renamed.
> 
> Maybe the net core should just implement persistent device names ;)
> 
Theres no good way for the kernel to do that, as persistent naming in this case
is a matter of user policy, not kernel hardware management (i.e. do you want a
network name to follow a mac address, a pci slot, or the network its connected
to)?  You can use smbios to get some modicum of persistent device naming
currently, but I don't recall if that requires udev rules to implement as well

You're best bet is to simply make your initramfs more robust.  I understand what
you're saying regarding renaming after you've taken a reference on a device not
being possible, but you can run udev within the initramfs, and do your renaming
prior to your netconsole load.

Thanks
Neil

> Thanks again for all your time,
> Peter Hurley
> 
> 
