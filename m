From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v3 net-next] bpf/verifier: track liveness for pruning
Date: Wed, 16 Aug 2017 00:12:58 +0200
Message-ID: <599371EA.20605@iogearbox.net>
References: <f40d3d54-c88a-7348-99ca-66db8075a8d5@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        iovisor-dev <iovisor-dev@lists.iovisor.org>
To: Edward Cree <ecree@solarflare.com>, davem@davemloft.net,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f40d3d54-c88a-7348-99ca-66db8075a8d5@solarflare.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/15/2017 09:34 PM, Edward Cree wrote:
> State of a register doesn't matter if it wasn't read in reaching an exit;
>   a write screens off all reads downstream of it from all explored_states
>   upstream of it.
> This allows us to prune many more branches; here are some processed insn
>   counts for some Cilium programs:
> Program                  before  after
> bpf_lb_opt_-DLB_L3.o       6515   3361
> bpf_lb_opt_-DLB_L4.o       8976   5176
> bpf_lb_opt_-DUNKNOWN.o     2960   1137
> bpf_lxc_opt_-DDROP_ALL.o  95412  48537
> bpf_lxc_opt_-DUNKNOWN.o  141706  78718
> bpf_netdev.o              24251  17995
> bpf_overlay.o             10999   9385
>
> The runtime is also improved; here are 'time' results in ms:
> Program                  before  after
> bpf_lb_opt_-DLB_L3.o         24      6
> bpf_lb_opt_-DLB_L4.o         26     11
> bpf_lb_opt_-DUNKNOWN.o       11      2
> bpf_lxc_opt_-DDROP_ALL.o   1288    139
> bpf_lxc_opt_-DUNKNOWN.o    1768    234
> bpf_netdev.o                 62     31
> bpf_overlay.o                15     13
>
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
