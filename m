From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/3] slub: fix small HWCACHE_ALIGN alignment
Date: Thu, 6 Mar 2008 03:57:58 +0100
Message-ID: <20080306025758.GB27150@wotan.suse.de>
References: <20080303201701.GF8974@wotan.suse.de> <Pine.LNX.4.64.0803031315160.4131@schroedinger.engr.sgi.com> <20080305000637.GA1510@wotan.suse.de> <20080304.161003.129716254.davem@davemloft.net> <Pine.LNX.4.64.0803051257030.30742@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yanmin_zhang@linux.intel.com,
	dada1@cosmosbay.com
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:50807 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754584AbYCFC57 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2008 21:57:59 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803051257030.30742@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 05, 2008 at 01:06:30PM -0800, Christoph Lameter wrote:
> On Tue, 4 Mar 2008, David Miller wrote:
> 
> > > Huh?? It is not a new definition, it is exactly what SLAB does. And
> > > then you go and do something different and claim that you follow
> > > what slab does.
> > 
> > I completely agree with Nick.
> 
> So you also want subalignment because of cacheline crossing for 24 byte 
> slabs? We then only have 2 objects per cacheline instead of 3 but no 
> crossing anymore.
> 
> Well okay if there are multiple requests then lets merge Nick's patch that 
> does this. Still think that this will do much ...
> Instead of 170 we will only have 128 objects per slab (64 byte 
> cacheline).

That's what callers expect when they pass the HWCACHE flag. Wouldn't it
be logical to fix the callers if you think it costs too much memory with
not enough improvement?

 
> It will affect the following slab caches (mm) reducing the density of 
> objects. 
> 
> scsi_bidi_sdb numa_policy fasync_cache xfs_bmap_free_item xfs_dabuf 
> fstrm_item dm_target_io
> 
> Nothing related to networking....

There looks like definitely some networking slabs that pass the flag
and can be non-power-of-2. And don't forget cachelines can be anywhere
up to 256 bytes in size. So yeah it definitely makes sense to merge
the patch and then examine the callers if you feel strongly about it.


