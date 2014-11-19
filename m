From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: fix arraymap NULL deref and missing
 overflow and zero size checks
Date: Wed, 19 Nov 2014 16:55:57 -0500 (EST)
Message-ID: <20141119.165557.1477971698958867828.davem@davemloft.net>
References: <1416360736-9531-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, hannes@stressinduktion.org,
	dborkman@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ast@plumgrid.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416360736-9531-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue, 18 Nov 2014 17:32:16 -0800

> - fix NULL pointer dereference:
> kernel/bpf/arraymap.c:41 array_map_alloc() error: potential null dereference 'array'.  (kzalloc returns null)
> kernel/bpf/arraymap.c:41 array_map_alloc() error: we previously assumed 'array' could be null (see line 40)
> 
> - integer overflow check was missing in arraymap
> (hashmap checks for overflow via kmalloc_array())
> 
> - arraymap can round_up(value_size, 8) to zero. check was missing.
> 
> - hashmap was missing zero size check as well, since roundup_pow_of_two() can
> truncate into zero
> 
> - found a typo in the arraymap comment and unnecessary empty line
> 
> Fix all of these issues and make both overflow checks explicit U32 in size.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
> This silly NULL deref bug and missing overflow check was an oversight when
> I refactored the code from two allocations (kmalloc for struct bpf_array and
> kcalloc for array of elements) in the first implementation of arraymap
> into one allocation which is this code.

Applied, thanks.
