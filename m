From: Jeff Garzik <jeff@garzik.org>
Subject: Re: ISDN testing
Date: Mon, 21 Apr 2008 15:22:08 -0400
Message-ID: <480CE960.4050000@garzik.org>
References: <20080420223959.GA17998@havoc.gtf.org> <200804210205.38891.elendil@planet.nl> <480BF15D.2090100@garzik.org> <200804211536.57655.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	isdn4linux@listserv.isdn4linux.de
To: Frans Pop <elendil@planet.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36006 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757912AbYDUTWN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 15:22:13 -0400
In-Reply-To: <200804211536.57655.elendil@planet.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frans Pop wrote:
> On Monday 21 April 2008, Jeff Garzik wrote:
>> Frans Pop wrote:
>>> The cards I have are:
>>> - Teles 16.3 ISA -- worked way back when with Debian Woody
>>> - ITK ix1-micro 2.1 ISA
>>> - Eicon Diva 2.01 PCI
>> Honestly, a module-load test on real hardware can give us some useful
>> information, even if it's not connected to anything.
>>
>> My changes are primarily in the probe-the-hardware area, so successfully
>> making it past that new code would indeed be a useful data point.
>>
>> Check out the kernel found in 'isdn-pci' branch of
>> git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/misc-2.6.git
> 
> Turns out all 3 cards are supported by the same basic driver: hisax, so
> I can only test for the one driver. The Eicon Diva uses an additional
> module though: hisaxdiva.
> 
> I've put the last 2 cards in one machine and (after some fiddling with
> jumpers and interrupts and IO ports :-) both are detected perfectly with
> 2.6.24 when hisax is modprobed.
> 
> Advantage of using the two cards is that it covers both PCI and ISA.
> The PCI card gets configured automagically, while the ISA card requires
> module parameters for io/irq.
> 
> I've compiled a kernel based on your 'isdn-pci' branch, and it boots fine.
> 
> But when I tried to modprobe hisax, I got:
> # modprobe hisax
> FATAL: Module hisax not found.
> 
> Cause seems to be:
> # depmod -a
> WARNING: Module /lib/modules/2.6.25-isdn/kernel/drivers/isdn/hisax/hisaxdiva.ko 
> ignored, due to loop
> WARNING: Module /lib/modules/2.6.25-isdn/kernel/drivers/isdn/hisax/libhisax.ko 
> ignored, due to loop
> WARNING: Loop 
> detected: /lib/modules/2.6.25-isdn/kernel/drivers/isdn/hisax/hisax.ko needs 
> libhisax.ko which needs hisax.ko again!
> WARNING: Module /lib/modules/2.6.25-isdn/kernel/drivers/isdn/hisax/hisax.ko 
> ignored, due to loop

Yeah, that's what my patchset does -- splits the "hisax" driver into 
multiple smaller drivers.  Thus, "modprobe hisax" produces the results 
that you are seeing.

You'll need to determine which newly-created kernel module applies to 
your hardware.  Let me know if you need help with that.  The new drivers 
should be in /lib/modules/2.6.25-isdn/kernel/drivers/isdn/hisax/ 
provided that you enabled them in the kernel configuration.

	Jeff



