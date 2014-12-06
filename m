From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] bpf: x86: fix epilogue generation for eBPF
 programs
Date: Fri, 05 Dec 2014 21:24:33 -0800 (PST)
Message-ID: <20141205.212433.750912400773154348.davem@davemloft.net>
References: <1417301173-23691-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zlim.lnx@gmail.com, edumazet@google.com, dborkman@redhat.com,
	hpa@zytor.com, tglx@linutronix.de, mingo@kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ast@plumgrid.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417301173-23691-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Sat, 29 Nov 2014 14:46:13 -0800

> classic BPF has a restriction that last insn is always BPF_RET.
> eBPF doesn't have BPF_RET instruction and this restriction.
> It has BPF_EXIT insn which can appear anywhere in the program
> one or more times and it doesn't have to be last insn.
> Fix eBPF JIT to emit epilogue when first BPF_EXIT is seen
> and all other BPF_EXIT instructions will be emitted as jump.
> 
> Since jump offset to epilogue is computed as:
> jmp_offset = ctx->cleanup_addr - addrs[i]
> we need to change type of cleanup_addr to signed to compute the offset as:
> (long long) ((int)20 - (int)30)
> instead of:
> (long long) ((unsigned int)20 - (int)30)
> 
> Fixes: 622582786c9e ("net: filter: x86: internal BPF JIT")
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thanks.
