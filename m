From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 00/14] Swap-over-NBD without deadlocking v5
Date: Thu, 7 Jul 2011 08:58:31 -0400
Message-ID: <20110707125831.GA15412@infradead.org>
References: <1308575540-25219-1-git-send-email-mgorman@suse.de>
 <20110706165146.be7ab61b.akpm@linux-foundation.org>
 <20110707094737.GG15285@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux-MM <linux-mm@kvack.org>,
	Linux-Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Mel Gorman <mgorman@suse.de>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20110707094737.GG15285@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 07, 2011 at 10:47:37AM +0100, Mel Gorman wrote:
> Additional complexity is required for swap-over-NFS but affects the
> core kernel far less than this series. I do not have a series prepared
> but from what's in a distro kernel, supporting NFS requires extending
> address_space_operations for swapfile activation/deactivation with
> some minor helpers and the bulk of the remaining complexity within
> NFS itself.

The biggest addition for swap over NFS is to add proper support for
a filesystem interface to do I/O on random kernel pages instead of
the current nasty bmap hack the swapfile code is using.  Splitting
that work from all the required VM infrastructure should make life
easier for everyone involved and allows merging it independeny as
both bits have other uses case as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
