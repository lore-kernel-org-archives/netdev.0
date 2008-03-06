From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/3] slub: fix small HWCACHE_ALIGN alignment
Date: Thu, 6 Mar 2008 03:49:04 +0100
Message-ID: <20080306024904.GA27150@wotan.suse.de>
References: <Pine.LNX.4.64.0803031107130.6917@schroedinger.engr.sgi.com> <20080303200613.GC8974@wotan.suse.de> <Pine.LNX.4.64.0803031209570.16049@schroedinger.engr.sgi.com> <20080303201701.GF8974@wotan.suse.de> <Pine.LNX.4.64.0803031315160.4131@schroedinger.engr.sgi.com> <84144f020803031330i2c0ea1f6kc5b02c8b26145797@mail.gmail.com> <Pine.LNX.4.64.0803031331340.4375@schroedinger.engr.sgi.com> <47CC6F30.50802@cs.helsinki.fi> <20080305002821.GD1510@wotan.suse.de> <Pine.LNX.4.64.0803051254570.30742@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42299 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755875AbYCFCtH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2008 21:49:07 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803051254570.30742@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 05, 2008 at 12:56:33PM -0800, Christoph Lameter wrote:
> On Wed, 5 Mar 2008, Nick Piggin wrote:
> 
> > It started out as a SLUB regression that was exposing poor code in the
> > percpu allocator due to different SLUB kmalloc alignments. That prompted
> 
> That was due to SLUB's support for smaller allocation sizes. AFAICT has 
> nothing to do with alignment.

The smaller sizes meant objects were less often aligned on cacheline
boundaries.

 
> > The SMP flag was just an RFC. I think some people (like Christoph) were
> > being confused about the HWCACHE_ALIGN flag being for avoiding false
> > sharing on SMP systems. It would actually be also generally useful to
> > have the SMP flag (eg. see the sites I added it to in patch #3).
> 
> Hmmm. We could define a global constant for that? Determine it on bootup 
> and then pass it as an alignment parameter?
  
We could, but I'd rather just use the flag.

