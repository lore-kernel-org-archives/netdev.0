From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 20:29:13 -0400
Message-ID: <20090313002913.GC13764@localhost.localdomain>
References: <49B82566.3070909@weinigel.se> <20090311171354.04c7a63d@nehalam> <49B8E6D4.2030702@weinigel.se> <20090312.055523.193191701.davem@davemloft.net> <49B91A7B.7050303@weinigel.se> <20090312151211.GB24995@hmsreliant.think-freely.org> <49B96F74.50804@dls.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christer Weinigel <christer@weinigel.se>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	s.hauer@pengutronix.de, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	wd@denx.de, dzu@denx.de
To: "Mike (mwester)" <mwester@dls.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37746 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262AbZCMA3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 20:29:37 -0400
Content-Disposition: inline
In-Reply-To: <49B96F74.50804@dls.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2009 at 03:24:20PM -0500, Mike (mwester) wrote:
> Neil Horman wrote:
> 
> > What exactly is so difficult about cpio-ing up an initramfs to do this work with
> > sed and ifconfig? You make it sound like its an impossible barrier. Its really
> > quite simple
> 
> Can you share your scripts and tools for creating an initramfs so
> easily?  I too run into this problem -- I've always used the
> kernel-provided mechanism to DHCP and do the nfs mount of the rootfs,
> but if the initramfs is the right way to do that, then I'll be happy to
> change.
> 
> It always looked rather daunting to me, and a lot of extra effort
> compared to letting the kernel do the job, but if it really is so easy,
> then I'll be happy to change my practices.
> 
> Thanks!
> Mike (mwester)
Sure, you'll find my mkduprd script in the kexec-tools package for fedora,
you're welcome to tear it up to suit your needs.

By way of precaution, I'll tell you that the script is much larger than it needs
to be, since its purpose is to copy a vmcore to several various locations.

In short summary, all you need to make an initramfs is:

1) create a rootfs directory tree somewhere, call it $INITRD_ROOT
2) populate the initrd with any applications you need for your purpose
3) create an executable file , called $INITRD_ROOT/init
4) $INITRD_ROOT/init should do whatever you want the initramfs to do, in
mkdumprd I make it a shell script that does various and sunry things, although
you could do something as simple as making it run /bin/sh to give you a shell
prompt.
5)cd $INITRD_ROOT; cpio --quiet -c -o /tmp/initramfs; gzip -9 /tmp/initramfs

thats it.
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
