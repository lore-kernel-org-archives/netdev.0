From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH 4/4] samples/bpf: Enable powerpc support
Date: Thu, 31 Mar 2016 10:52:52 -0700
Message-ID: <56FD63F4.2010500@fb.com>
References: <922f95fb5d16686367a66d2d4bd176149a87e9ad.1459423412.git.naveen.n.rao@linux.vnet.ibm.com>
 <28a3811d03f6e8f7dca989a4ade536bf9aa8c7ce.1459423412.git.naveen.n.rao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Daniel Borkmann <daniel@iogearbox.net>,
	<netdev@vger.kernel.org>
To: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>,
	<linux-kernel@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <28a3811d03f6e8f7dca989a4ade536bf9aa8c7ce.1459423412.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/31/16 4:25 AM, Naveen N. Rao wrote:
> Add the necessary definitions for building bpf samples on ppc.
>
> Since ppc doesn't store function return address on the stack, modify how
> PT_REGS_RET() and PT_REGS_FP() work.
>
> Also, introduce PT_REGS_IP() to access the instruction pointer. I have
> fixed this to work with x86_64 and arm64, but not s390.
>
> Cc: Alexei Starovoitov <ast@fb.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
> ---
...
> +
> +#ifdef __powerpc__
> +#define BPF_KPROBE_READ_RET_IP(ip, ctx)		{ (ip) = (ctx)->link; }
> +#define BPF_KRETPROBE_READ_RET_IP(ip, ctx)	BPF_KPROBE_READ_RET_IP(ip, ctx)
> +#else
> +#define BPF_KPROBE_READ_RET_IP(ip, ctx)						\
> +		bpf_probe_read(&(ip), sizeof(ip), (void *)PT_REGS_RET(ctx))
> +#define BPF_KRETPROBE_READ_RET_IP(ip, ctx)					\
> +		bpf_probe_read(&(ip), sizeof(ip),				\
> +				(void *)(PT_REGS_FP(ctx) + sizeof(ip)))

makes sense, but please use ({ }) gcc extension instead of {} and
open call to make sure that macro body is scoped.
