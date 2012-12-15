From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: netconsole fun
Date: Sat, 15 Dec 2012 09:13:58 -0500
Message-ID: <1355580838.2467.39.camel@thor>
References: <20121211143004.GA7481@neilslaptop.think-freely.org>
	 <1355239011.2694.24.camel@thor>
	 <20121211164526.GB7481@neilslaptop.think-freely.org>
	 <1355345957.2687.18.camel@thor>
	 <20121213123611.GA12269@hmsreliant.think-freely.org>
	 <1355410171.2605.17.camel@thor>
	 <20121213180815.GA14796@hmsreliant.think-freely.org>
	 <1355426821.2612.16.camel@thor>
	 <20121213211754.GC14796@hmsreliant.think-freely.org>
	 <1355437480.2612.33.camel@thor>
	 <20121214142018.GA24846@shamino.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout39.mail01.mtsvc.net ([216.70.64.83]:46595 "EHLO
	n12.mail01.mtsvc.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753193Ab2LOOOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2012 09:14:08 -0500
In-Reply-To: <20121214142018.GA24846@shamino.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-12-14 at 09:20 -0500, Neil Horman wrote:
> Ah!  I'm sorry, I didn't realize this was really about getting netconsole up
> early in the boot, rather than just getting it up robustly using the startup
> script.

Well, it's both but I should have been clearer here. Sorry about that.

> If thats the case, then I would recommend that you modify the initramfs
> to do something simmilar to the startup script (since thats where the netconsole
> module will get loaded anyway).  You can write a script there that will let you
> specify the destination ip address and figure out the output dev based on the
> routing tables.  If you're using dracut to build your initramfs, then this
> should be pretty straightforward.

When I get some more free time I'll experiment with this approach.

Just to clarify something from earlier in the discussion:

On Thu, 2012-12-13 at 13:08 -0500, Neil Horman wrote:
> On Thu, Dec 13, 2012 at 09:49:31AM -0500, Peter Hurley wrote:
....
> > There is an unforeseen consequence of the patch: it breaks device
> > renaming because the device will already be in use by netconsole. Which
> > is the whole problem with userspace device renaming to begin with...
> > 
> That is bad, but see above, the netconsole service can work around this for you,
> allowing you to never have to specify a particular device at all.

The breakage is a normal consequence of being able to load netconsole
before the udev rules that do device renaming. The same thing would
happen modifying initramfs.

Basically, once netconsole attaches to a device, that device cannot be
renamed. Unfortunately, the default udev behavior messes things up
further because it will try to do this:
  eth0->eth1
  eth1->eth0
which means neither device will be renamed.

Maybe the net core should just implement persistent device names ;)

Thanks again for all your time,
Peter Hurley
