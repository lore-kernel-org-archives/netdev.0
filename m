From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 07/12] use a dynamic pool of sk_buffs to keep up with fast targets
Date: Tue, 3 Jul 2007 13:45:33 -0500
Message-ID: <20070703184533.GR11166@waste.org>
References: <1d8423c28c48a6d26516cdc707dbcdf015a4e347.1182883861.git.ecashin@coraid.com> <bca4cec8ad679e8f8549cb78e012e54bfad1027e.1182883861.git.ecashin@coraid.com> <20070702213636.9ca1d842.akpm@linux-foundation.org> <20070702.214036.42772583.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, ecashin@coraid.com,
	linux-kernel@vger.kernel.org, greg@kroah.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:40742 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755802AbXGCSpz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2007 14:45:55 -0400
Content-Disposition: inline
In-Reply-To: <20070702.214036.42772583.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 02, 2007 at 09:40:36PM -0700, David Miller wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Mon, 2 Jul 2007 21:36:36 -0700
> 
> > My initial thought is that if there is a legitimate need for this
> > new capability then it should be made available to other parts of
> > the kernel rather than being private to the AEO driver.
> 
> Absolutely.
> 
> We even used to have something like this on a per-cpu basis but using
> generic SLAB is so much better for caching and NUMA that we got rid of
> that.
> 
> Every sk_buff private "quicklist" pool implementation you
> see should essentially be NAK'd from the get go, it's
> meaningless and if it's really needed one should investigate
> why SKB allocations become such a problem instead of papering
> over the issue. :-)

This is in the VM write-back path. SLAB is insufficient to avoid
deadlock.

-- 
Mathematics is the supreme nostalgia of our time.
