From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [6/6] ppc: ebpf/jit: Implement JIT compiler for extended BPF
Date: Fri, 17 Jun 2016 22:53:21 +1000 (AEST)
Message-ID: <3rWKtT2tSrz9t2G@ozlabs.org>
References: <908d3552b5eb240b28f70aee7c4c86e2b600aa02.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
Cc: Matt Evans <matt@ozlabs.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@fb.com>,
	Denis Kirjanov <kda@linux-powerpc.org>,
	Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>
To: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <908d3552b5eb240b28f70aee7c4c86e2b600aa02.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-07-06 at 13:32:23 UTC, "Naveen N. Rao" wrote:
> diff --git a/arch/powerpc/net/bpf_jit_comp64.c b/arch/powerpc/net/bpf_jit_comp64.c
> new file mode 100644
> index 0000000..954ff53
> --- /dev/null
> +++ b/arch/powerpc/net/bpf_jit_comp64.c
> @@ -0,0 +1,956 @@
...
> +
> +static void bpf_jit_fill_ill_insns(void *area, unsigned int size)
> +{
> +	int *p = area;
> +
> +	/* Fill whole space with trap instructions */
> +	while (p < (int *)((char *)area + size))
> +		*p++ = BREAKPOINT_INSTRUCTION;
> +}

This breaks the build for some configs, presumably you're missing a header:

  arch/powerpc/net/bpf_jit_comp64.c:30:10: error: 'BREAKPOINT_INSTRUCTION' undeclared (first use in this function)

http://kisskb.ellerman.id.au/kisskb/buildresult/12720611/

cheers
