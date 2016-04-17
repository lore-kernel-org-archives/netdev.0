From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] bpf: avoid warning for wrong pointer cast
Date: Sat, 16 Apr 2016 17:47:42 -0700
Message-ID: <20160417004740.GA80675@ast-mbp.thefacebook.com>
References: <1460838585-1248139-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@redhat.com>,
	Alexei Starovoitov <ast@fb.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-kernel@vger.kernel.org, fengguang.wu@intel.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1460838585-1248139-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 16, 2016 at 10:29:33PM +0200, Arnd Bergmann wrote:
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

Thanks.
Acked-by: Alexei Starovoitov <ast@kernel.org>

I guess I started to rely on 0-day build-bot too much.
This patch has been in my tree for 2+ weeks and then in net-next and
I didn't receive a single email from build-bot about this warning,
though I do receive them for my other work-in-progress stuff. Odd.
Fengguang, any idea why build-bot sometimes silent?
