From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC] [PATCH 0/3] ioat: DMA engine support
Date: Wed, 23 Nov 2005 22:54:04 +0000
Message-ID: <1132786445.13095.32.camel@localhost.localdomain>
References: <Pine.LNX.4.44.0511231143380.32487-100000@isotope.jf.intel.com>
	 <4384E7F2.2030508@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Grover <andrew.grover@intel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, john.ronciak@intel.com,
	christopher.leech@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932587AbVKWWVv@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4384E7F2.2030508@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mer, 2005-11-23 at 17:06 -0500, Jeff Garzik wrote:
> Sample ideas:  VM page pre-zeroing.  ATA PIO data xfers (async copy to 
> static buffer, to dramatically shorten length of kmap+irqsave time). 
> Extremely large memcpy() calls.

ATA PIO copies are 512 bytes of memory per sector and that is usually
already in cache and on cache line boundaries. You won't even be able to
measure it done by the CPU. I can't see the I/O engine sync cost being
worth it.

Might just about help large transfers I guess but you don't do
multisector which is the only case you'd get perhaps 8K an I/O.

> Additionally, current IOAT is memory->memory.  I would love to be able 
> to convince Intel to add transforms and checksums, 

Not just transforms but also masks and maybe even merges and textures
would be rather handy 8)
