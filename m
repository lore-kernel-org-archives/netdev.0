From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: split eBPF out of NET
Date: Mon, 27 Oct 2014 19:10:43 -0400 (EDT)
Message-ID: <20141027.191043.246099210901442100.davem@davemloft.net>
References: <1414114868-28228-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: geert@linux-m68k.org, josh@joshtriplett.org, mingo@kernel.org,
	rostedt@goodmis.org, hannes@stressinduktion.org,
	edumazet@google.com, dborkman@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ast@plumgrid.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414114868-28228-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Thu, 23 Oct 2014 18:41:08 -0700

> introduce two configs:
> - hidden CONFIG_BPF to select eBPF interpreter that classic socket filters
>   depend on
> - visible CONFIG_BPF_SYSCALL (default off) that tracing and sockets can use
> 
> that solves several problems:
> - tracing and others that wish to use eBPF don't need to depend on NET.
>   They can use BPF_SYSCALL to allow loading from userspace or select BPF
>   to use it directly from kernel in NET-less configs.
> - in 3.18 programs cannot be attached to events yet, so don't force it on
> - when the rest of eBPF infra is there in 3.19+, it's still useful to
>   switch it off to minimize kernel size
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
> 
> bloat-o-meter on x64 shows:
> add/remove: 0/60 grow/shrink: 0/2 up/down: 0/-15601 (-15601)
> 
> tested with many different config combinations. Hopefully didn't miss anything.

Applied with two changes:

1) boolean --> bool
2) Moved bloat-o-meter and testing information into commit message.

Thanks.
