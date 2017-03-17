From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] bpf: inline bpf_map_lookup_elem()
Date: Thu, 16 Mar 2017 20:44:28 -0700 (PDT)
Message-ID: <20170316.204428.88037066577723816.davem@davemloft.net>
References: <1489627604-2288703-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, fengguang.wu@intel.com,
        netdev@vger.kernel.org, kernel-team@fb.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54576 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751132AbdCQDpR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 23:45:17 -0400
In-Reply-To: <1489627604-2288703-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Wed, 15 Mar 2017 18:26:38 -0700

> bpf_map_lookup_elem() is one of the most frequently used helper functions.
> Improve JITed program performance by inlining this helper.
> 
> bpf_map_type	before  after
> hash		58M	74M
> array		174M	280M
> 
> The values are number of lookups per second in ideal conditions
> measured by micro-benchmark in patch 6.
> 
> The 'perf report' for HASH map type:
> before:
>     54.23%  map_perf_test  [kernel.kallsyms]  [k] __htab_map_lookup_elem
>     14.24%  map_perf_test  [kernel.kallsyms]  [k] lookup_elem_raw
>      8.84%  map_perf_test  [kernel.kallsyms]  [k] htab_map_lookup_elem
>      5.93%  map_perf_test  [kernel.kallsyms]  [k] bpf_map_lookup_elem
>      2.30%  map_perf_test  [kernel.kallsyms]  [k] bpf_prog_da4fc6a3f41761a2
>      1.49%  map_perf_test  [kernel.kallsyms]  [k] kprobe_ftrace_handler
> 
> after:
>     60.03%  map_perf_test  [kernel.kallsyms]  [k] __htab_map_lookup_elem
>     18.07%  map_perf_test  [kernel.kallsyms]  [k] lookup_elem_raw
>      2.91%  map_perf_test  [kernel.kallsyms]  [k] bpf_prog_da4fc6a3f41761a2
>      1.94%  map_perf_test  [kernel.kallsyms]  [k] _einittext
>      1.90%  map_perf_test  [kernel.kallsyms]  [k] __audit_syscall_exit
>      1.72%  map_perf_test  [kernel.kallsyms]  [k] kprobe_ftrace_handler
> 
> so the cost of htab_map_lookup_elem() and bpf_map_lookup_elem()
> is gone after inlining.
> 
> 'per-cpu' and 'lru' map types can be optimized similarly in the future.
> 
> Note the sparse will complain that bpf is addictive ;)
> kernel/bpf/hashtab.c:438:19: sparse: subtraction of functions? Share your drugs
> kernel/bpf/verifier.c:3342:38: sparse: subtraction of functions? Share your drugs
> it's not a new warning, just in new places.

Series applied, thanks.
