From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [RFT] e100 driver on ARM
Date: Thu, 29 Mar 2007 10:10:41 -0400
Message-ID: <20070329141041.GA3510@csclub.uwaterloo.ca>
References: <44FC0261.6010807@garzik.org> <20060904123123.GB1285@xi.wantstofly.org> <460AF480.7050609@intel.com> <460B4BF2.1070803@roinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Jeff Garzik <jeff@garzik.org>,
	Netdev List <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Russell King <rmk+lkml@arm.linux.org.uk>
To: David Acker <dacker@roinet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:59190 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753626AbXC2OKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 10:10:47 -0400
Content-Disposition: inline
In-Reply-To: <460B4BF2.1070803@roinet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 29, 2007 at 01:17:38AM -0400, David Acker wrote:
> I have a pxa255 based system with PCI added to it.  The e100 would have 
> memory corruption in its receive buffers detected by slab debugging 
> unless I put in the patch to use the S-bit.
> 
> Here is a link to the patch posting:
> http://kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.20-rc3/2.6.20-rc3-mm1/broken-out/git-netdev-all.patch
> Search for e100.c.
> 
> http://www-gatago.com/linux/kernel/15457063.html - This discussion seems 
> to hit the issue.
> 
> There appears to be a race on the cache line where the EL bit and the 
> next packet info live. In my case the hardware appeared to write to a 
> free packet.  The S-bit seems to make the hardware stop and spin on the 
> bit, while the EL bit seems to let the hardware try to use that packet.
> 
> This race would occur less often when the receive buffer chain is always 
> refilled before the hardware can use them up.  On our 400 Mhz Xscale, we 
> can use up all 256 buffers if the PCI bus has another busy device on it. 
>  In our case it is an 802.11g miniPCI card and our software was routing 
> all ethernet packets to the wireless interface and vice versa while TCP 
> streams were running accross these connections.

Which PCI host controller are you using with the PXA255?  We tried using
a PXA255 based system with a PCI controller a couple of years ago and
have to change to a different cpu in the end due to the PCI controller
simply not being valid PCI.  The PXA255 wasn't designed for PCI, and I
get the impression that non of the PCI companion chips for it do a good
enough job to actually add it correctly.

--
Len Sorensen
