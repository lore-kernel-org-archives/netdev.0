From: Andi Kleen <ak@linux.intel.com>
Subject: Re: Page allocator bottleneck
Date: Thu, 14 Sep 2017 13:19:17 -0700
Message-ID: <87vaklyqwq.fsf@linux.intel.com>
References: <cef85936-10b2-5d76-9f97-cb03b418fd94@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Michal Hocko <mhocko@suse.com>, linux-mm <linux-mm@kvack.org>
To: Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:45246 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751342AbdINUTS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 14 Sep 2017 16:19:18 -0400
In-Reply-To: <cef85936-10b2-5d76-9f97-cb03b418fd94@mellanox.com> (Tariq
        Toukan's message of "Thu, 14 Sep 2017 19:49:31 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tariq Toukan <tariqt@mellanox.com> writes:
>
> Congestion in this case is very clear.
> When monitored in perf top:
> 85.58% [kernel] [k] queued_spin_lock_slowpath

Please look at the callers. Spinlock profiles without callers
are usually useless because it's just blaming the messenger.

Most likely the PCP lists are too small for your extreme allocation
rate, so it goes back too often to the shared pool.

You can play with the vm.percpu_pagelist_fraction setting.

-Andi
