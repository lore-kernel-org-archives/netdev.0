From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [RFC] Fine-grained memory priorities and PI
Date: Fri, 16 Dec 2005 00:02:48 +1100
Message-ID: <200512160002.49096.kernel@kolivas.org>
References: <20051215033937.GC11856@waste.org> <200512152345.25375.kernel@kolivas.org> <8803F1D1-E647-45A3-B2A4-E3C95AAC11C6@mac.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, sri@us.ibm.com,
	mpm@selenic.com, ak@suse.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422718AbVLONDr@vger.kernel.org>
To: Kyle Moffett <mrmacman_g4@mac.com>
In-Reply-To: <8803F1D1-E647-45A3-B2A4-E3C95AAC11C6@mac.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 15 December 2005 23:58, Kyle Moffett wrote:
> On Dec 15, 2005, at 07:45, Con Kolivas wrote:
> > I have some basic process-that-called the memory allocator link in
> > the -ck tree already which alters how aggressively memory is
> > reclaimed according to priority. It does not affect out of memory
> > management but that could be added to said algorithm; however I
> > don't see much point at the moment since oom is still an uncommon
> > condition but regular memory allocation is routine.
>
> My thought would be to generalize the two special cases of writeback
> of dirty pages or dropping of clean pages under memory pressure and
> OOM to be the same general case.  When you are trying to free up
> pages, it may be permissible to drop dirty mbox pages and kill the
> postfix process writing them in order to satisfy allocations for the
> mission-critical database server.  (Or maybe it's the other way
> around).  If a large chunk of the allocated pages have priorities and
> lossless/lossy free functions, then the kernel can be much more
> flexible and configurable about what to do when running low on RAM.

Indeed the implementation I currently have is lightweight to say the least but 
I really didn't think bloating struct page was worth it since the memory cost 
would be prohibitive, but would allow all sorts of priority effects and vm 
scheduling to be possible. That is, struct page could have an extra entry 
keeping track of the highest priority of the process that used it and use 
that to determine further eviction etc.

Cheers,
Con
