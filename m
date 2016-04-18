From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bpf: avoid warning for wrong pointer cast
Date: Mon, 18 Apr 2016 00:04:09 -0400 (EDT)
Message-ID: <20160418.000409.811805682656661992.davem@davemloft.net>
References: <1460838585-1248139-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rostedt@goodmis.org, mingo@redhat.com,
	ast@fb.com, daniel@iogearbox.net, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460838585-1248139-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Sat, 16 Apr 2016 22:29:33 +0200

> Two new functions in bpf contain a cast from a 'u64' to a
> pointer. This works on 64-bit architectures but causes a warning
> on all 32-bit architectures:
> 
> kernel/trace/bpf_trace.c: In function 'bpf_perf_event_output_tp':
> kernel/trace/bpf_trace.c:350:13: error: cast to pointer from integer of different size [-Werror=int-to-pointer-cast]
>   u64 ctx = *(long *)r1;
> 
> This changes the cast to first convert the u64 argument into a uintptr_t,
> which is guaranteed to be the same size as a pointer.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 9940d67c93b5 ("bpf: support bpf_get_stackid() and bpf_perf_event_output() in tracepoint programs")

Applied.
