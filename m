From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 1/8] ixgbe: Out of line ixgbe_read/write_reg
Date: Mon, 19 May 2014 16:25:31 -0700
Message-ID: <20140519232531.GJ19657@tassilo.jf.intel.com>
References: <1400276595-6965-1-git-send-email-andi@firstfloor.org>
 <1400276595-6965-2-git-send-email-andi@firstfloor.org>
 <7477F573-2AED-4D26-8D5F-DB80DFA7EDEF@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"<linux-kernel@vger.kernel.org>" <linux-kernel@vger.kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:47606 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750894AbaESXcO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2014 19:32:14 -0400
Content-Disposition: inline
In-Reply-To: <7477F573-2AED-4D26-8D5F-DB80DFA7EDEF@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 19, 2014 at 10:00:52PM +0000, Rustad, Mark D wrote:
> On May 16, 2014, at 2:43 PM, Andi Kleen <andi@firstfloor.org> wrote:
> 
> > From: Andi Kleen <ak@linux.intel.com>
> > 
> > ixgbe_read_reg and ixgbe_write_reg are frequently called and are very big
> > because they have complex error handling code.
> 
> Actually, this patch doesn't do anything to ixgbe_write_reg, which would almost certainly be very bad for performance, but instead changes ixgbe_write_reg64.

I doubt a few cycles around the write make a lot of difference for MMIO. MMIO is dominated
by other things.

> The latter is not in a performance-sensitive path, but is only called from one site, so there is little reason to take it out-of-line.

True I moved the wrong one.

ixgbe_write_reg                                    3305  (0.00%)  8     409  


> I already have a patch in queue to make ixgbe_read_reg out-of-line, because it does have a very costly memory footprint inline, as you have found.

Please move write_reg too.

-Andi
