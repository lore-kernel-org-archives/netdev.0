From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net 2/3] bpf: fix splat for illegal devmap percpu
 allocation
Date: Tue, 17 Oct 2017 08:54:13 -0700
Message-ID: <20171017155411.bwadbz7zlrfo7wf3@ast-mbp.dhcp.thefacebook.com>
References: <cover.1508251210.git.daniel@iogearbox.net>
 <dd091b1fec763d74185a156ecd2f972810bdd1ce.1508251210.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, tj@kernel.org, ast@kernel.org,
        john.fastabend@gmail.com, mark.rutland@arm.com, richard@nod.at,
        sp3485@columbia.edu, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <dd091b1fec763d74185a156ecd2f972810bdd1ce.1508251210.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 17, 2017 at 04:55:53PM +0200, Daniel Borkmann wrote:
> It was reported that syzkaller was able to trigger a splat on
> devmap percpu allocation due to illegal/unsupported allocation
> request size passed to __alloc_percpu():
> 
>   [   70.094249] illegal size (32776) or align (8) for percpu allocation
>   [   70.094256] ------------[ cut here ]------------
>   [   70.094259] WARNING: CPU: 3 PID: 3451 at mm/percpu.c:1365 pcpu_alloc+0x96/0x630
>   [...]
>   [   70.094325] Call Trace:
>   [   70.094328]  __alloc_percpu_gfp+0x12/0x20
>   [   70.094330]  dev_map_alloc+0x134/0x1e0
>   [   70.094331]  SyS_bpf+0x9bc/0x1610
>   [   70.094333]  ? selinux_task_setrlimit+0x5a/0x60
>   [   70.094334]  ? security_task_setrlimit+0x43/0x60
>   [   70.094336]  entry_SYSCALL_64_fastpath+0x1a/0xa5
> 
> This was due to too large max_entries for the map such that we
> surpassed the upper limit of PCPU_MIN_UNIT_SIZE. It's fine to
> fail naturally here, so switch to __alloc_percpu_gfp() and pass
> __GFP_NOWARN instead.
> 
> Fixes: 11393cc9b9be ("xdp: Add batching support to redirect map")
> Reported-by: Mark Rutland <mark.rutland@arm.com>
> Reported-by: Shankara Pailoor <sp3485@columbia.edu>
> Reported-by: Richard Weinberger <richard@nod.at>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: John Fastabend <john.fastabend@gmail.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
