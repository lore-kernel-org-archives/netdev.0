From: Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 4/4] mtd: nand: nandsim: convert to memalloc_noreclaim_*()
Date: Thu, 6 Apr 2017 09:27:55 +0200
Message-ID: <20170406072754.GC5497@dhcp22.suse.cz>
References: <20170405074700.29871-1-vbabka@suse.cz>
 <20170405074700.29871-5-vbabka@suse.cz>
 <20170405113157.GM6035@dhcp22.suse.cz>
 <ee6649ed-b0e8-1c59-c193-d1688fdfe7f5@nod.at>
 <9b9d5bca-e125-e07b-b700-196cc800bbd7@suse.cz>
 <fe1c21a4-0bc6-529c-5446-382b01d4c99e@intel.com>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vlastimil Babka <vbabka-AlSwsSmVLrQ@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mel Gorman <mgorman-3eNAlZScCAx27rWaFMvyedHuzzzSOjJt@public.gmane.org>,
	Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, linux-block-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	nbd-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Boris Brezillon <boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: Adrian Hunter <adrian.hunter-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <open-iscsi+bncBC4LN7MPQ4HRB763S7DQKGQE7C7BZQI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <fe1c21a4-0bc6-529c-5446-382b01d4c99e-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Post: <https://groups.google.com/group/open-iscsi/post>, <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/open-iscsi
List-Subscribe: <https://groups.google.com/group/open-iscsi/subscribe>, <mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+856124926423+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/open-iscsi/subscribe>
List-Id: netdev.vger.kernel.org

On Thu 06-04-17 09:33:44, Adrian Hunter wrote:
> On 05/04/17 14:39, Vlastimil Babka wrote:
> > On 04/05/2017 01:36 PM, Richard Weinberger wrote:
> >> Michal,
> >>
> >> Am 05.04.2017 um 13:31 schrieb Michal Hocko:
> >>> On Wed 05-04-17 09:47:00, Vlastimil Babka wrote:
> >>>> Nandsim has own functions set_memalloc() and clear_memalloc() for robust
> >>>> setting and clearing of PF_MEMALLOC. Replace them by the new generic helpers.
> >>>> No functional change.
> >>>
> >>> This one smells like an abuser. Why the hell should read/write path
> >>> touch memory reserves at all!
> >>
> >> Could be. Let's ask Adrian, AFAIK he wrote that code.
> >> Adrian, can you please clarify why nandsim needs to play with PF_MEMALLOC?
> > 
> > I was thinking about it and concluded that since the simulator can be
> > used as a block device where reclaimed pages go to, writing the data out
> > is a memalloc operation. Then reading can be called as part of r-m-w
> > cycle, so reading as well.
> 
> IIRC it was to avoid getting stuck with nandsim waiting on memory reclaim
> and memory reclaim waiting on nandsim.

I've got lost in the indirection. Could you describe how would reclaim
get stuck waiting on these paths please?

-- 
Michal Hocko
SUSE Labs

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To unsubscribe from this group and stop receiving emails from it, send an email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
Visit this group at https://groups.google.com/group/open-iscsi.
For more options, visit https://groups.google.com/d/optout.
