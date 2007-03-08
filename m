From: Don Fry <pcnet32@verizon.net>
Subject: Re: [PATCH 1/2] pcnet32: only allocate init_block dma consistent
Date: Wed, 7 Mar 2007 17:44:17 -0800
Message-ID: <20070308014417.GA11717@verizon.net>
References: <20070306184523.GA23268@verizon.net> <20070307031011.GA4281@linux-mips.org> <f2b55d220703061939w731dfcc4t8e0ddcf238203bd@mail.gmail.com> <20070307042155.GA6495@linux-mips.org> <f2b55d220703070835n16fbb052ub80be3e3e6d326a3@mail.gmail.com> <20070307192228.GA13273@linux-mips.org> <f2b55d220703071215v4df1bb40had54aa66b7ce1065@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: "Michael K. Edwards" <medwards.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [71.117.224.81] ([71.117.224.81]:28425 "EHLO linux.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751149AbXCHBnv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2007 20:43:51 -0500
Content-Disposition: inline
In-Reply-To: <f2b55d220703071215v4df1bb40had54aa66b7ce1065@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 07, 2007 at 12:15:26PM -0800, Michael K. Edwards wrote:
> cacheability of the allocated block.  Maybe it doesn't.  The alpha
> version of pci_alloc_consistent, on the other hand, does interesting
> things to make the memory visible to PCI.  Don, what arches did you
> have in mind when you commented on caching issues?
> 
I had not made any comments on the caching issue until now.
The comments on the caching and performance improvements came from
Thomas Bogendoerfer who submitted this change, and Ralf Baechle.

On some architectures, at least for MIPS, the locks have to be in cached
memory.  The only part of the data structure that has to be in pci
coherent memory is the init block data structure, which the chip reads.
All the rest of the information in the private structure are for the
driver.

Having those variables in cacheable memory "should" improve performance,
I would think.

Don
