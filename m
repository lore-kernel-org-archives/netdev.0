From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Re: Help testing for USB ethernet/xHCI regression
Date: Wed, 29 Jan 2014 13:54:08 -0800
Message-ID: <20140129215408.GC5991@xanatos>
References: <22081260.RNay0J72dY@athas>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb@vger.kernel.org, Mark Lord <mlord@pobox.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, David Laight <David.Laight@ACULAB.COM>
To: renevant@internode.on.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:11098 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750942AbaA2VyK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jan 2014 16:54:10 -0500
Content-Disposition: inline
In-Reply-To: <22081260.RNay0J72dY@athas>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 29, 2014 at 04:21:00PM +1100, renevant@internode.on.net wrote:
> Hello,
> 
> I am someone who has been struggling to get an ax88179 net adapter working 
> reliably.
> 
> I have an integrated Asmedia 1042 xhci controller that is reportedly version 
> 0.96 on an ASUS M5A99FX PRO R2.0, BIOS 2201 motherboard based on the AMD 990FX 
> chipset. 
> 
> The big issue I am currently facing is that I cannot get the device to work at 
> all with 3.13 and current 3.14 mainline. This does not occur with 3.12.

With the working kernel, were you using vanilla 3.12, or a later 3.12
stable release, like 3.12.5?

> Current issue is when plugging in the ax88179 there is lag when bringing the 
> interface up and a bunch of kernel messages:

With which kernel?

> [   63.389440] ax88179_178a 2-1:1.0 eth0: register 'ax88179_178a' at 
> usb-0000:07:00.0-1, ASIX AX88179 USB 3.0 Gigabit Ethernet, 80:3f:5d:08:0c:65
> [   63.389500] usbcore: registered new interface driver ax88179_178a
> [   63.423942] systemd-udevd[560]: renamed network interface eth0 to enp7s0u1
> [   79.481028] IPv6: ADDRCONF(NETDEV_UP): enp7s0u1: link is not ready
> [   82.210721] ax88179_178a 2-1:1.0 enp7s0u1: ax88179 - Link status is: 1
> [   82.338947] ax88179_178a 2-1:1.0 enp7s0u1: ax88179 - Link status is: 1
> [   82.467148] ax88179_178a 2-1:1.0 enp7s0u1: kevent 4 may have been dropped
> [   82.470028] ax88179_178a 2-1:1.0 enp7s0u1: ax88179 - Link status is: 1
> [   82.595364] ax88179_178a 2-1:1.0 enp7s0u1: kevent 4 may have been dropped
> [   82.598312] ax88179_178a 2-1:1.0 enp7s0u1: ax88179 - Link status is: 1
> [   82.723580] ax88179_178a 2-1:1.0 enp7s0u1: kevent 4 may have been dropped
> [   82.726487] ax88179_178a 2-1:1.0 enp7s0u1: ax88179 - Link status is: 1
> [   82.851796] ax88179_178a 2-1:1.0 enp7s0u1: kevent 4 may have been dropped
> [   82.854642] ax88179_178a 2-1:1.0 enp7s0u1: ax88179 - Link status is: 1
> [snip]
> [   87.218379] ax88179_178a 2-1:1.0 enp7s0u1: Failed to write reg index 
> 0x0002: -110

Can you enable xHCI debugging as well, and send dmesg?  You'll need to
have CONFIG_USB_DEBUG turned on, and also run this command as root:

echo -n 'module xhci_hcd =p' > /sys/kernel/debug/dynamic_debug/control

> Any traffic sent to the nic isn't seen by Linux.
> 
> 
> I can confirm the following problems for me with 3.14:
>
> reverting the writeq patch made USB 3 work for me again.
> 
> http://marc.info/?t=139093294600002&r=1&w=2

So what was the issue that caused you to revert that patch?  The traffic
not going to the device, or the device not being enumerated at all?

> and
> 
> http://marc.info/?l=linux-usb&m=139092084714232&w=2
> 
> got rid of transiever errors 
> 
> 
> 
> 
> I cannot really test stability for the ax88179 until I can get it to work when 
> plugging it in as above. I've tried the frag reversion and it's made no 
> difference to this issue.

What about also reverting the writeq patch, on top of the other patches
I asked Mark to try?

Sarah Sharp
