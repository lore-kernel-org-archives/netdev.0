From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH] net: frag limit checks need to use
 percpu_counter_compare
Date: Fri, 1 Sep 2017 09:41:56 +0200
Message-ID: <20170901094156.12e6e0a3@redhat.com>
References: <150417481955.28907.15567119824187929000.stgit@firesoul>
        <20170831162349.k3qnkfgkygdh2zqw@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: liujian56@huawei.com, netdev@vger.kernel.org,
        Florian Westphal <fw@strlen.de>, brouer@redhat.com
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46088 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751022AbdIAHmC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 03:42:02 -0400
In-Reply-To: <20170831162349.k3qnkfgkygdh2zqw@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 31 Aug 2017 18:23:49 +0200 Michal Kubecek <mkubecek@suse.cz> wrote:

> If we go this way (which would IMHO require some benchmarks to make sure
> it doesn't harm performance too much) we can drop the explicit checks
> for zero thresholds which were added to work around the unreliability of
> fast checks of percpu counters (or at least the second one was by commit
> 30759219f562 ("net: disable fragment reassembly if high_thresh is zero").
  
After much considerations, together with Florian, I'm now instead
looking at reverting the use of percpu_counter for this memory
accounting use-case.  The complexity and maintenance cost is not worth
it.  And I'm of-cause testing the perf effect, and currently I'm _not_
seeing any perf regression on my 10G + 100G testlab (although this is
not a NUMA system, which were my original optimization case).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
