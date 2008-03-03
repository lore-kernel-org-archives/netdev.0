From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/3] slub: fix small HWCACHE_ALIGN alignment
Date: Mon, 3 Mar 2008 21:06:13 +0100
Message-ID: <20080303200613.GC8974@wotan.suse.de>
References: <20080303093449.GA15091@wotan.suse.de> <Pine.LNX.4.64.0803031107130.6917@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:42463 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754351AbYCCUGP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 15:06:15 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803031107130.6917@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 03, 2008 at 11:08:44AM -0800, Christoph Lameter wrote:
> On Mon, 3 Mar 2008, Nick Piggin wrote:
> 
> > SLUB should pack even small objects nicely into cachelines if that is what
> > has been asked for. Use the same algorithm as SLAB for this.
> 
> Why? SLAB does not cacheline align objects smaller than cache_line_size() 
> /2.

It still doesn't after this patch.

> If they are already not cache line aligned then we can make them as 
> dense as possible. That is what SLUB does.

Because when you specify HWCACHE_ALIGN, it means that you want the object
not to cross cacheline boundaries for at least cache_line_size() bytes.
SLAB does this. SLUB does not without this patch.

