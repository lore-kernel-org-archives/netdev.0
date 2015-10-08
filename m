From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 00/14] RDS: connection scalability and performance
 improvements
Date: Thu, 08 Oct 2015 04:39:05 -0700 (PDT)
Message-ID: <20151008.043905.148919078156104097.davem@davemloft.net>
References: <1444233228-4481-1-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ssantosh@kernel.org
To: santosh.shilimkar@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444233228-4481-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Date: Wed,  7 Oct 2015 08:53:34 -0700

> [v4]
> Re-sending the same patches from v3 again since my repost of
> patch 05/14 from v3 was whitespace damaged.
> 
> [v3]
> Updated patch "[PATCH v2 05/14] RDS: defer the over_batch work to
> send worker" as per David Miller's comment [4] to avoid the magic
> value usage. Patch now makes use of already available but unused
> send_batch_count module parameter. Rest of the patches are same as
> earlier version v2 [3]
> 
> [v2]:
> Dropped "[PATCH 05/15] RDS: increase size of hash-table to 8K" from
> earlier version [1]. I plan to address the hash table scalability using
> re-sizable hash tables as suggested by David Laight and David Miller [2]
> 
> This series addresses RDS connection bottlenecks on massive workloads and
> improve the RDMA performance almost by 3X. RDS TCP also gets a small gain
> of about 12%.
> 
> RDS is being used in massive systems with high scalability where several
> hundred thousand end points and tens of thousands of local processes
> are operating in tens of thousand sockets. Being RC(reliable connection),
> socket bind and release happens very often and any inefficiencies in
> bind hash look ups hurts the overall system performance. RDS bin hash-table
> uses global spin-lock which is the biggest bottleneck. To make matter worst,
> it uses rcu inside global lock for hash buckets.
> This is being addressed by simply using per bucket rw lock which makes the
> locking simple and very efficient. The hash table size is still an issue and
> I plan to address it by using re-sizable hash tables as suggested on the list.
> 
> For RDS RDMA improvement, the completion handling is revamped so that we
> can do batch completions. Both send and receive completion handlers are
> split logically to achieve the same. RDS 8K messages being one of the
> key usecase, mr pool is adapted to have the 8K mrs along with default 1M
> mrs. And while doing this, few fixes and couple of bottlenecks seen with
> rds_sendmsg() are addressed.
> 
> Series applies against 4.3-rc1 as well net-next. Its tested on Oracle
> hardware with IB fabric for both bcopy as well as RDMA mode. RDS TCP is
> tested with iXGB NIC. Like last time, iWARP transport is untested with
> these changes. The patchset is also available at below git repo:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/ssantosh/linux.git net/rds/4.3-v3
> 
> As a side note, the IB HCA driver I used for testing misses at least 3
> important patches in upstream to see the full blown IB performance and
> am hoping to get that in mainline with help of them.

Pulled, thank you.
