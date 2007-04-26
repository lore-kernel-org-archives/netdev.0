From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [RFT] e100 driver on ARM
Date: Thu, 26 Apr 2007 15:50:13 +0200
Message-ID: <20070426135013.GA12154@xi.wantstofly.org>
References: <44FC0261.6010807@garzik.org> <20060904123123.GB1285@xi.wantstofly.org> <460AF480.7050609@intel.com> <460B4BF2.1070803@roinet.com> <20070329141041.GA3510@csclub.uwaterloo.ca> <46239138.4040408@roinet.com> <20070417173507.GB5575@csclub.uwaterloo.ca> <4630AC02.7040706@roinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jeff@garzik.org>,
	Netdev List <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Russell King <rmk+lkml@arm.linux.org.uk>
To: David Acker <dacker@roinet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:34798 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754795AbXDZNuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 09:50:17 -0400
Content-Disposition: inline
In-Reply-To: <4630AC02.7040706@roinet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 26, 2007 at 09:41:22AM -0400, David Acker wrote:

> Here is a quote from Russell that describes what I believe is the main 
> problem:
> http://www-gatago.com/linux/kernel/15457063.html
> "
> Has e100 actually been fixed to use the PCI DMA API correctly yet?
> Looking at it, it doesn't look like it, so until it does, eepro100
> is the far better bet for platforms needing working DMA API.
> 
> What I'm talking about is e100's apparant belief that it can modify
> rfd's in the receive ring on a non-cache coherent architecture and
> expect the data around it to remain unaffected (see e100_rx_alloc_skb):
> 
> struct rfd {
> u16 status;
> u16 command;
> u32 link;
> u32 rbd;
> u16 actual_size;
> u16 size;
> };
> 
> it touches command and link. This means that the whole rfd plus
> maybe the following or preceding 16 bytes get loaded into a cache
> line (assuming cache lines of 32 bytes), and that data written
> out again at sync. However, it does this on what seems to be an
> active receive chain.
> 
> So, both the CPU _and_ the device own the same data. Which is a
> violation of the DMA API.
> "
> 
> I think that the S-bit patch fixes it because the hardware spins on the 
> s-bit instead of using the packet.  With just the el-bit, the hardware 
> tries to use the same cache line that the software is updating.
> 
> Can someone from Intel let us know if I understand the hardware's 
> handling of the S and EL bits?  If my interpretation is correct, can the 
> s-bit patch be applied?  It seems like the correct way to lock out the 
> hardware while a packet is being updated.  I have not seen a reason 
> given not to apply the patch.

This is all a while ago now, but wasn't the e100 S-bit patch originally
written by Intel people in response to the very same quote by Russell
King that you've quoted above?  The S-bit patch should probably just
be applied, IMHO.
