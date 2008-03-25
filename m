From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [Bugme-new] [Bug 10318] New: WARNING: at
	arch/x86/mm/highmem_32.c:43 kmap_atomic_prot+0x87/0x184()
Date: Tue, 25 Mar 2008 21:23:50 +0100
Message-ID: <20080325202350.GH15330@elte.hu>
References: <bug-10318-10286@http.bugzilla.kernel.org/> <20080325105750.ff913a83.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	pstaszewski@artcom.pl, linux-mm@kvack.org,
	Christoph Lameter <clameter@sgi.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:46193 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752942AbYCYUYj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 16:24:39 -0400
Content-Disposition: inline
In-Reply-To: <20080325105750.ff913a83.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Andrew Morton <akpm@linux-foundation.org> wrote:

> afacit what's happened is that someone is running __alloc_pages(..., 
> __GFP_ZERO) from softirq context.  But the __GFP_ZERO implementation 
> uses KM_USER0 which cannot be used from softirq context because 
> non-interrupt code on this CPU might be using the same kmap slot.
> 
> Can anyone thing of anything which recently changed in either 
> networking core or e1000e which would have triggered this?
> 
> I think the core MM code is being doubly dumb here.
> 
> a) We should be able to use __GFP_ZERO from all copntexts.
> 
> b) it's not a highmem page anyway, so we won't be using that kmap 
> slot.

i think this came up before (with kzalloc()) and the MM code should have 
been fixed to not even attempt a kmap_atomic(), instead of working it 
around in the callsite or in the kmap_atomic() code.

	Ingo
