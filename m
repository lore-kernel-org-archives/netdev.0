From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based PCI	Express adapters...
Date: Mon, 2 Jul 2007 22:42:38 +0100
Message-ID: <20070702214238.GA7085@infradead.org>
References: <4688F512.3030801@garzik.org> <E35F4F4D7F6C9E4E826FEC1F86CEF58304193063@orsmsx412.amr.corp.intel.com> <20070702140958.5ea6571a@freepuppy.localdomain.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	arjan@linux.intel.com, akpm@linux-foundation.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:42499 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755555AbXGBVnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2007 17:43:03 -0400
Content-Disposition: inline
In-Reply-To: <20070702140958.5ea6571a@freepuppy.localdomain.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 02, 2007 at 02:09:58PM -0700, Stephen Hemminger wrote:
> The patch is close to ready for 2.6.24 when this driver will need to show up.

If intel manages to fix up the reamining issues I'd rather see it appear
in 2.6.23..

> Since I know Intel will be forced to backport this to older distro's. You
> would be best to have a single receive queue version when you have to make
> it work on the older code.

But that'll require the single receiver queue version I guess.  The
netdevice abuse is the only really major issue I see, although I'd of
course really like to see the driver getting rid of the bitfield abuse
aswell.

> > Since we wanted to distinguish the various MSIX vectors in
> > /proc/interrupts and since request_irq expects memory for name to be
> > allocated somewhere, I added this part of the ring struct.
> 
> You only need to store the name for when you are doing request_irq, so
> it can just be a stack temporary.  

Lots of drivers where the interface name is assigned after request_irq
just use an internal name, e.g. ixgbeX in the case of this driver.

