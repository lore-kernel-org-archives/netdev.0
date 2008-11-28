From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: oops/warning report for the week of November 26, 2008
Date: Fri, 28 Nov 2008 12:12:02 -0800
Message-ID: <20081128121202.133d2ff0@linux.intel.com>
References: <492DD792.6080302@linux.intel.com>
 <20081128111827.79b12739@osprey.hogchain.net>
 <20081128093217.3888fb46@linux.intel.com>
 <20081128195018.GA19538@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jay Cliburn <jcliburn@gmail.com>, NetDev <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:38922 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752620AbYK1UK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 15:10:58 -0500
In-Reply-To: <20081128195018.GA19538@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Nov 2008 20:50:18 +0100
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Arjan van de Ven <arjan@linux.intel.com> :
> [...]
> > For me, sis900 and r8169 stand out; if you look at the data in the
> > table above, both of these are an order of magnitude more frequent
> > than the rest of the pack.
> 
> via-rhine + via_rhine = 438: it does not look too good either.
> 
> Is there an (ideally automated) way to retrieve more information ?

this will need help from the driver and a bit of the core
infrastructure.

the code that generates the warning is in net/sched/sch_generic.c:

char drivername[64];
WARN_ONCE(1, KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit timed out\n", dev->name, netdev_drivername(dev, drivername, 64));
dev->tx_timeout(dev); 
 
> The r8169 driver handles three different chipsets and a plethora of
> phys. The "XID" line printed by the driver could hint at some specific
> PHY for instance.

anything you add to that WARN_ONCE will end up on kerneloops.org...
it could be as simple storing some information in the net dev... or having
a function pointer that can print some useful diagnostics information.


In addition, I'm trying to get a patch into .29 that prints, on x86, some basic
DMI information in every WARN_ON class message; but this won't give you the details
about the actual NIC, at most which motherboard is in use.


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
