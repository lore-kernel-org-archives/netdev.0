From: Christer Weinigel <christer@weinigel.se>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 17:25:27 +0100
Message-ID: <49B93777.7030202@weinigel.se>
References: <49B82566.3070909@weinigel.se> <20090311171354.04c7a63d@nehalam>
	<49B8E6D4.2030702@weinigel.se>
	<20090312.055523.193191701.davem@davemloft.net>
	<49B91A7B.7050303@weinigel.se>
	<20090312151211.GB24995@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	s.hauer@pengutronix.de, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	wd@denx.de, dzu@denx.de
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk>
In-Reply-To: <20090312151211.GB24995@hmsreliant.think-freely.org>
List-Unsubscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=unsubscribe>
List-Archive: <http://lists.arm.linux.org.uk/lurker/list/linux-arm-kernel.html>
List-Post: <mailto:linux-arm-kernel@lists.arm.linux.org.uk>
List-Help: <mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=help>
List-Subscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.arm.linux.org.uk
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk
List-Id: netdev.vger.kernel.org

Neil Horman wrote:
> What exactly is so difficult about cpio-ing up an initramfs to do this work with
> sed and ifconfig? You make it sound like its an impossible barrier. Its really
> quite simple

In theory, nothing.  In practice, well, where do I find an example 
initrd that I can build on that has a DHCP client that hands over the 
NFS root information from the DHCP response to a tool that mounts the 
NFS root file system?  So far I haven't seen anything like that and the 
infrastructure to build initrds (such as klibc) is still hard to find 
and use.  Every time I've tried to build an initrd that can do DCHP+NFS 
root it has turned out to be too much trouble and I've had to drop it as 
deadlines come closer.

> You've convinced yourself that theres no other way to do this.  What exactly is
> your opposition to an initramfs? I just built busybox with ifconfig, sed and ash
> in a static binary.  The whole thing comes out at 800kb, and is compressed to
> 400kb.  You could probably save an extra hundred kb or so if you went with msh
> instead or something.  Are you quite sure that your NV storage for your kernel
> doesn't have an extra 400kb to spare for an initramfs?  I assume that it must,
> since eventually you'll need an initramfs anyway to run the production variant
> of the system your building (I imagine they won't all ship with an NFS server in
> tow :) ).

No, I'm quite aware that there are other ways of doing this, it's just 
that all the other ways are _much_ more work for me.  The harsh reality 
is that if I can get a board working using a hack in the driver in half 
an hour, I'll do that rather than fussing around with an initrd. 
Patching the driver is no big deal, it's quick and fairly painless for 
me, it would just be nice if the kernel had a generic way of doing this 
so that I don't have to.  The kernel requires no userspace, no C library 
and all I have to be able to do is to compile the kernel itself.

It's exactly the same reason why people are still using the in kernel 
DHCP client and NFS root code instead of writing and initrd for it, it's 
  much easier to use and why spend time on something that is much more 
complicated for no gain since the in kernel code is sufficient?

I much prefer to spend time on working on the device drivers that I'm 
paid to work on (and spend more time to try try to get those patches 
into the kernel) than to spend time on rewriting everything for an 
initrd.  And the final product usually won't even have ethernet, so from 
a product perspective it would be wasted time.  Anyway, getting the 
system to boot from NFS is usually the absolutely first thing I have to 
do.  Making a product out of it comes months later, and only if we're 
able to do a proof-of-concept demo on a couple of reference platforms at 
an early stage.

Regarding the flash space, if I have a 1.6MByte kernel image (the size 
of a  compressed Linux 2.6.24 kernel for a Samsung S3C24A0 platform I'm 
working on), those 400kBytes can make the difference between things 
fitting into the 2MByte flash partition the bootloader has reserved for 
the kernel or not.

So it mostly boils down to me being lazy and not wanting to spend a lot 
of time on building new infrastructure.  I'd like something which is a 
bit better than what we have now and can spend some time on it, but I 
don't want to spend a lot of time on it since patching the driver works 
just fine for my purposes.  Perfect is the enemy of good.

   /Christer


-------------------------------------------------------------------
List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php
