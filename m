From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/16] Spidernet DMA coalescing
Date: Thu, 7 Dec 2006 10:11:51 +0000
Message-ID: <20061207101151.GB27904@infradead.org>
References: <20061206223223.GH17931@austin.ibm.com> <20061206232745.GA4649@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	James K Lewis <jklewis@us.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Geoff Levand <geoffrey.levand@am.sony.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:39617 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031934AbWLGKMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 05:12:02 -0500
To: Linas Vepstas <linas@austin.ibm.com>
Content-Disposition: inline
In-Reply-To: <20061206232745.GA4649@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 06, 2006 at 05:27:45PM -0600, Linas Vepstas wrote:
> 
> The current driver code performs 512 DMA mappings of a bunch of 
> 32-byte structures. This is silly, as they are all in contiguous 
> memory. Ths patch changes the code to DMA map the entie area
> with just one call.

This is still wrong.  The descriptor array must be in dma_alloc_coherent
memory, not a streaming mapping.  (I also think I pointed this out a while
ago when I made dma_alloc_coherent node-aware)

