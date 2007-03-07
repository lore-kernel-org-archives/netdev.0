From: "Michael K. Edwards" <medwards.linux@gmail.com>
Subject: Re: [PATCH 1/2] pcnet32: only allocate init_block dma consistent
Date: Wed, 7 Mar 2007 12:15:26 -0800
Message-ID: <f2b55d220703071215v4df1bb40had54aa66b7ce1065@mail.gmail.com>
References: <20070306184523.GA23268@verizon.net>
	 <20070307031011.GA4281@linux-mips.org>
	 <f2b55d220703061939w731dfcc4t8e0ddcf238203bd@mail.gmail.com>
	 <20070307042155.GA6495@linux-mips.org>
	 <f2b55d220703070835n16fbb052ub80be3e3e6d326a3@mail.gmail.com>
	 <20070307192228.GA13273@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Don Fry" <pcnet32@verizon.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: "Ralf Baechle" <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.230]:47857 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965618AbXCGUP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 15:15:28 -0500
Received: by wr-out-0506.google.com with SMTP id 37so521455wra
        for <netdev@vger.kernel.org>; Wed, 07 Mar 2007 12:15:27 -0800 (PST)
In-Reply-To: <20070307192228.GA13273@linux-mips.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/7/07, Ralf Baechle <ralf@linux-mips.org> wrote:
> GFP_* flags have no influence on caching or prefetching.

The zone modifier flags (like GFP_DMA) can in principle affect the
cache/prefetch policy, since they affect what physical address range
the memory is allocated from.  I don't know whether Linux uses this
effect intentionally, but I would not be the least bit surprised if
virtual machines commonly treat the traditional 16MB of low physical
memory differently from the rest of the address space.

Looking at the i386 implementation of dma_alloc_coherent (underlying
pci_alloc_consistent), it's not clear to me how this interferes with
cacheability of the allocated block.  Maybe it doesn't.  The alpha
version of pci_alloc_consistent, on the other hand, does interesting
things to make the memory visible to PCI.  Don, what arches did you
have in mind when you commented on caching issues?

Cheers,
- Michael
