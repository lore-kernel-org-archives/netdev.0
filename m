From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: SLAB vs. SLUB tbench regression (Was: [tbench regression fixes]: digging out smelly deadmen.)
Date: Fri, 31 Oct 2008 21:22:54 +0300
Message-ID: <20081031182253.GA32340@ioremap.net>
References: <84144f020810310728j1f3b8a99se428ec55b0c165b5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <s0mbre@tservice.net.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Ingo Molnar <mingo@elte.hu>,
	David Miller <davem@davemloft.net>,
	Christoph Lameter <cl@linux-foundation.org>,
	Matthew Wilcox <matthew@wil.cx>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tservice.ru ([195.178.208.66]:40548 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751351AbYJaSW4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 14:22:56 -0400
Content-Disposition: inline
In-Reply-To: <84144f020810310728j1f3b8a99se428ec55b0c165b5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pekka.

On Fri, Oct 31, 2008 at 04:28:57PM +0200, Pekka Enberg (penberg@cs.helsinki.fi) wrote:
> As you've already pointed out in private and in your blog, some part
> of the tbench regression comes from SLUB vs. SLAB as well. Looks like
> I can reproduce the regression locally as well:
> 
>   [ 8 clients and tbench_srv on the same machine on 2-way x86-64 ]
> 
>                   min      max      avg      sd
>   2.6.28-rc2-slab 234.57   244.88   242.68   0.71
>   2.6.28-rc2-slub 227.44   240.90   239.08   0.78
> 
> Oprofile seems to be busted for 2.6.28-rc2 so I'll follow up on this
> as soon as that's settled.
> 
> Btw, just as one more data point, I accidentally tested with just 2
> clients at first and SLUB actually beat SLAB.

Looks like under the allocation/freeing pressure some tricky part of
slub starts slowing things down, while at usual rate amount of operations
is smaller, so slub gets its optimized results... Just a handwaving
though.

Tbench regression is not related to slab/slub fight though, since I
always used slab in tests (if not specially tested slub), but of course
fixing this issue in the more and more common allocator would be just
great. Thanks for working on this issue Pekka.

-- 
	Evgeniy Polyakov
