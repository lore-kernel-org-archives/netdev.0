From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] struct file cleanup : the very large file_ra_state is
 now allocated only on demand.
Date: Thu, 18 Aug 2005 00:18:54 -0700 (PDT)
Message-ID: <20050818.001854.21765805.davem@davemloft.net>
References: <20050818010524.GW3996@wotan.suse.de>
	<20050817.194315.111196480.davem@davemloft.net>
	<43043567.3040204@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, bcrl@linux.intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750919AbVHRHT0@vger.kernel.org>
To: dada1@cosmosbay.com
In-Reply-To: <43043567.3040204@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 18 Aug 2005 09:14:47 +0200

> After reading your suggestions, I understand we still need two slabs.
> One (filp_cachep) without the readahead data, the other one
> (filp_ra_cachep) with it.

Correct.

> static inline struct file_ra_state *get_ra_state(struct file *f)
> {
> #ifdef CONFIG_DEBUG_READAHEAD
> 	BUG_ON(filp_ra_cachep != GET_PAGE_CACHE(virt_to_page(f)));
> #endif
> 	return (struct file_ra_state *)(f+1);
> }

Or, instead of mucking with SLAB internals, just put something like
a "filp_ra_present" debugging binary state into filp while it gets
debugged.
