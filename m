From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/3] slub: fix small HWCACHE_ALIGN alignment
Date: Mon, 3 Mar 2008 21:17:01 +0100
Message-ID: <20080303201701.GF8974@wotan.suse.de>
References: <20080303093449.GA15091@wotan.suse.de> <Pine.LNX.4.64.0803031107130.6917@schroedinger.engr.sgi.com> <20080303200613.GC8974@wotan.suse.de> <Pine.LNX.4.64.0803031209570.16049@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Christoph Lameter <clameter@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756634AbYCCUR1@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803031209570.16049@schroedinger.engr.sgi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 03, 2008 at 12:10:59PM -0800, Christoph Lameter wrote:
> On Mon, 3 Mar 2008, Nick Piggin wrote:
> 
> > > If they are already not cache line aligned then we can make them as 
> > > dense as possible. That is what SLUB does.
> > 
> > Because when you specify HWCACHE_ALIGN, it means that you want the object
> > not to cross cacheline boundaries for at least cache_line_size() bytes.
> > SLAB does this. SLUB does not without this patch.
> 
> HWCACHE_ALIGN means that you want the object to be aligned at 
> cacheline boundaries for optimization. Why does crossing cacheline 
> boundaries matter in this case?

No, HWCACHE_ALIGN means that you want the object not to cross cacheline
boundaries for at least cache_line_size() bytes. You invented new
semantics with SLUB, but all the callers were written expecting the
existing semantics, presumably. So we should retain that behaviour, and
if you disagree with the actual callers, then that is fine but you
should discuss each case with the relevant people.
