From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/12] bpf: map pre-alloc
Date: Tue, 08 Mar 2016 15:31:10 -0500 (EST)
Message-ID: <20160308.153110.1923630451376696677.davem@davemloft.net>
References: <1457416641-306326-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, daniel.wagner@bmw-carit.de,
	tom.zanussi@linux.intel.com, wangnan0@huawei.com,
	hekuang@huawei.com, kafai@fb.com, brendan.d.gregg@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
To: ast@fb.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457416641-306326-1-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@fb.com>
Date: Mon, 7 Mar 2016 21:57:12 -0800

> v1->v2:
> . fix few issues spotted by Daniel
> . converted stackmap into pre-allocation as well
> . added a workaround for lockdep false positive
> . added pcpu_freelist_populate to be used by hashmap and stackmap
> 
> this path set switches bpf hash map to use pre-allocation by default
> and introduces BPF_F_NO_PREALLOC flag to keep old behavior for cases
> where full map pre-allocation is too memory expensive.
> 
> Some time back Daniel Wagner reported crashes when bpf hash map is
> used to compute time intervals between preempt_disable->preempt_enable
> and recently Tom Zanussi reported a dead lock in iovisor/bcc/funccount
> tool if it's used to count the number of invocations of kernel
> '*spin*' functions. Both problems are due to the recursive use of
> slub and can only be solved by pre-allocating all map elements.
> 
> A lot of different solutions were considered. Many implemented,
> but at the end pre-allocation seems to be the only feasible answer.
> As far as pre-allocation goes it also was implemented 4 different ways:
> - simple free-list with single lock
> - percpu_ida with optimizations
> - blk-mq-tag variant customized for bpf use case
> - percpu_freelist
> For bpf style of alloc/free patterns percpu_freelist is the best
> and implemented in this patch set.
> Detailed performance numbers in patch 3.
> Patch 2 introduces percpu_freelist
> Patch 1 fixes simple deadlocks due to missing recursion checks
> Patch 5: converts stackmap to pre-allocation
> Patches 6-9: prepare test infra
> Patch 10: stress test for hash map infra. It attaches to spin_lock
> functions and bpf_map_update/delete are called from different contexts
> Patch 11: stress for bpf_get_stackid
> Patch 12: map performance test
> 
> Reported-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
> Reported-by: Tom Zanussi <tom.zanussi@linux.intel.com>

Series applied, thanks Alexei.
