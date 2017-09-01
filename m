From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [RFC PATCH] net: frag limit checks need to use
 percpu_counter_compare
Date: Fri, 1 Sep 2017 10:10:06 +0200
Message-ID: <20170901081006.6hfftamapa56m2jv@unicorn.suse.cz>
References: <150417481955.28907.15567119824187929000.stgit@firesoul>
 <20170831162349.k3qnkfgkygdh2zqw@unicorn.suse.cz>
 <20170901094156.12e6e0a3@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: liujian56@huawei.com, netdev@vger.kernel.org,
        Florian Westphal <fw@strlen.de>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44017 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751022AbdIAIKI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 04:10:08 -0400
Content-Disposition: inline
In-Reply-To: <20170901094156.12e6e0a3@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 01, 2017 at 09:41:56AM +0200, Jesper Dangaard Brouer wrote:
> On Thu, 31 Aug 2017 18:23:49 +0200 Michal Kubecek <mkubecek@suse.cz> wrote:
> 
> > If we go this way (which would IMHO require some benchmarks to make sure
> > it doesn't harm performance too much) we can drop the explicit checks
> > for zero thresholds which were added to work around the unreliability of
> > fast checks of percpu counters (or at least the second one was by commit
> > 30759219f562 ("net: disable fragment reassembly if high_thresh is zero").
>   
> After much considerations, together with Florian, I'm now instead
> looking at reverting the use of percpu_counter for this memory
> accounting use-case.  The complexity and maintenance cost is not worth
> it.  And I'm of-cause testing the perf effect, and currently I'm _not_
> seeing any perf regression on my 10G + 100G testlab (although this is
> not a NUMA system, which were my original optimization case).

This sounds reasonable to me. It is indeed questionable if percpu
counters are still worth the complexity if all checks have to be changed
to the exact version.

Perhaps there would be some gain for many CPUs if thresholds are large
enough to (almost) always avoid the need to calculate the sum. But once
we leave that safe area, I would be surprised if simple atomic_t
wouldn't be more efficient.

Michal Kubecek
