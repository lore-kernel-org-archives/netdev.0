From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 10:26:55 -0400
Message-ID: <20090312142655.GA24995@hmsreliant.think-freely.org>
References: <1236738549-16703-1-git-send-email-yanok@emcraft.com> <20090310211841.388619ca@nehalam> <F884D8C3-E35B-4239-8D72-165EE528FCAC@prograde.net> <20090312.070554.96115441.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mboards@prograde.net, shemminger@vyatta.com, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	s.hauer@pengutronix.de, wd@denx.de, dzu@denx.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51245 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752710AbZCLO1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 10:27:31 -0400
Content-Disposition: inline
In-Reply-To: <20090312.070554.96115441.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2009 at 07:05:54AM -0700, David Miller wrote:
> From: Michael Cashwell <mboards@prograde.net>
> Date: Thu, 12 Mar 2009 09:41:38 -0400
> 
> > I'm confused by this. If I'm NFS-booting the board then how do I get
> > to those userland tools if I don't have a valid MAC address in place
> > to do the root mount?
> 
> Initial ramdisk.

+1, the simple fact of the matter is that, when building networkable devices,
the design requirements must include:

1) The ability to store unit-unique data, like MAC addresses, in persistent
storage, in a manner that can be read at arbitrary times from the OS.

2) The abiltiy to access that data from the OS under all relevant operating
conditions.

You have (1) covered, in that the bootloader passes the MAC on the command line
to the kernel which can then be read via /proc/cmdline easily.

If you can't accomplish (2) with NFS root built into the kernel, then quite
simply using built in NFS root isn't an option, and you need to burn some extra
storage to add an initramfs.  Its easy to do, and small.  Cost minimization is
important, but you can't remove what you need, and you need an initramfs.  You
can build one in just a few hundred kb, if you use busybox with a minimal
toolset (you'd probably need the sed, ifconfig, and ash applets).  I would make
a bet that even if you did need to spring for a bit of extra ram, the
incremental cost to that is less than the savings of using linux over something
that would required a per seat license, like VxWorks.

Neil



> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
