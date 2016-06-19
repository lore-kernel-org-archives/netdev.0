From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: Re: [6/6] ppc: ebpf/jit: Implement JIT compiler for extended BPF
Date: Sun, 19 Jun 2016 23:06:42 +0530
Message-ID: <20160619173642.GB8886@naverao1-tp.localdomain>
References: <908d3552b5eb240b28f70aee7c4c86e2b600aa02.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
 <3rWKtT2tSrz9t2G@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, Matt Evans <matt@ozlabs.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@fb.com>,
	Denis Kirjanov <kda@linux-powerpc.org>,
	Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>
To: Michael Ellerman <mpe@ellerman.id.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3rWKtT2tSrz9t2G@ozlabs.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/06/17 10:53PM, Michael Ellerman wrote:
> On Tue, 2016-07-06 at 13:32:23 UTC, "Naveen N. Rao" wrote:
> > diff --git a/arch/powerpc/net/bpf_jit_comp64.c b/arch/powerpc/net/bpf_jit_comp64.c
> > new file mode 100644
> > index 0000000..954ff53
> > --- /dev/null
> > +++ b/arch/powerpc/net/bpf_jit_comp64.c
> > @@ -0,0 +1,956 @@
> ...
> > +
> > +static void bpf_jit_fill_ill_insns(void *area, unsigned int size)
> > +{
> > +	int *p = area;
> > +
> > +	/* Fill whole space with trap instructions */
> > +	while (p < (int *)((char *)area + size))
> > +		*p++ = BREAKPOINT_INSTRUCTION;
> > +}
> 
> This breaks the build for some configs, presumably you're missing a header:
> 
>   arch/powerpc/net/bpf_jit_comp64.c:30:10: error: 'BREAKPOINT_INSTRUCTION' undeclared (first use in this function)
> 
> http://kisskb.ellerman.id.au/kisskb/buildresult/12720611/

Oops. Yes, I should have caught that. I need to add:

#include <asm/kprobes.h>

in bpf_jit_comp64.c

Can you please check if it resolves the build error?

Regards,
Naveen
