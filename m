From: Matt Wilson <msw@linux.com>
Subject: Re: [PATCH v6] xen/grant-table: Avoid m2p_override during mapping
Date: Thu, 23 Jan 2014 21:48:29 -0800
Message-ID: <20140124054828.GA18522@u109add4315675089e695.ant.amazon.com>
References: <1390512224-27296-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ian.campbell@citrix.com, wei.liu2@citrix.com,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jonathan.davies@citrix.com,
	Anthony Liguori <aliguori@amazon.com>,
	Matt Wilson <msw@amazon.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1390512224-27296-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 23, 2014 at 09:23:44PM +0000, Zoltan Kiss wrote:
> The grant mapping API does m2p_override unnecessarily: only gntdev needs it,
> for blkback and future netback patches it just cause a lock contention, as
> those pages never go to userspace. Therefore this series does the following:
> - the original functions were renamed to __gnttab_[un]map_refs, with a new
>   parameter m2p_override
> - based on m2p_override either they follow the original behaviour, or just set
>   the private flag and call set_phys_to_machine
> - gnttab_[un]map_refs are now a wrapper to call __gnttab_[un]map_refs with
>   m2p_override false
> - a new function gnttab_[un]map_refs_userspace provides the old behaviour
> 
> It also removes a stray space from page.h and change ret to 0 if
> XENFEAT_auto_translated_physmap, as that is the only possible return value
> there.
> 
> v2:
> - move the storing of the old mfn in page->index to gnttab_map_refs
> - move the function header update to a separate patch
> 
> v3:
> - a new approach to retain old behaviour where it needed
> - squash the patches into one
> 
> v4:
> - move out the common bits from m2p* functions, and pass pfn/mfn as parameter
> - clear page->private before doing anything with the page, so m2p_find_override
>   won't race with this
> 
> v5:
> - change return value handling in __gnttab_[un]map_refs
> - remove a stray space in page.h
> - add detail why ret = 0 now at some places
> 
> v6:
> - don't pass pfn to m2p* functions, just get it locally
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> Suggested-by: David Vrabel <david.vrabel@citrix.com>

Apologies for coming in late on this thread. I'm quite behind on
xen-devel mail that isn't CC: to me.

It seems to have been forgotten that Anthony and I proposed a similar
change last November.

https://lkml.kernel.org/r/1384307336-5328-1-git-send-email-anthony@codemonkey.ws

Or am I misunderstanding the change?

--msw
