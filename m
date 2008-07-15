From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH 1/2] 8139too: Make PIO/MMIO a modparam
Date: Tue, 15 Jul 2008 18:36:26 -0400
Message-ID: <20080715223626.GA10532@redhat.com>
References: <20080429215626.GC2859@redhat.com> <48179B56.7000606@garzik.org> <20080429153240.7200e1a3.akpm@linux-foundation.org> <4818546C.4060703@garzik.org> <20080529150752.GB8247@redhat.com> <483EF385.3000103@garzik.org> <20080529184106.GB24408@redhat.com> <483EFD8F.2070407@garzik.org> <20080715184006.GA20772@redhat.com> <487D2236.9000903@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56714 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754550AbYGOWoX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2008 18:44:23 -0400
Content-Disposition: inline
In-Reply-To: <487D2236.9000903@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2008 at 06:18:30PM -0400, Jeff Garzik wrote:
 
 > > Make PIO/MMIO a runtime thing via a module parameter.
 > > This is needed to support devices that only work with PIO
 > > without penalising devices that work fine with MMIO in
 > > distro kernels.
 > > 
 > > Signed-off-by: Dave Jones <davej@redhat.com>
 > 
 > Looks great overall.
 > 
 > Minor nits:
 > 
 > * need module param text description

oops. will fix.
 
 > * [optional] if code not too ugly, change mod param description based on 
 > CONFIG_8139TOO_PIO to indicate the currently compiled default

Not sure of a non-icky way to do this other than ifdefs.
The best I could come up with is.

#ifdef CONFIG_8139TOO_PIO
MODULE_PARM_DESC(use_io, "PIO/MMIO switch.  0=MMIO 1=PIO default=PIO"); 
#else
MODULE_PARM_DESC(use_io, "PIO/MMIO switch.  0=MMIO 1=PIO default=MMIO"); 
#endif

palatable?

 > * [optional] would prefer CONFIG_8139TOO_PIO be handled at compile time, 
 > by changing the initialized value

This bit should be taken care of in rtl8139_init_module() at the bottom..

+       /* enable PIO instead of MMIO, if CONFIG_8139TOO_PIO is selected */
+#ifdef CONFIG_8139TOO_PIO
+       use_io = 1;
+#endif

 > * [extra project] would be highly useful for MMIO to fall back to PIO, 
 > and vice versa, should any resource be unavailable.  Sometimes, mainly 
 > with MMIO and broken/weird BIOSen, only the PIO PCI BARs will be filled 
 > in with useful info.

Sounds do-able. I'll add it to my rainy-day project list.

	Dave

-- 
http://www.codemonkey.org.uk
