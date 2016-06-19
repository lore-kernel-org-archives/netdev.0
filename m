From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: Re: [PATCH] ppc: Fix BPF JIT for ABIv2
Date: Sun, 19 Jun 2016 23:19:14 +0530
Message-ID: <20160619174914.GC8886@naverao1-tp.localdomain>
References: <908d3552b5eb240b28f70aee7c4c86e2b600aa02.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
 <3rWKtT2tSrz9t2G@ozlabs.org>
 <20160617130042.GO3516@indiana.gru.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Ellerman <mpe@ellerman.id.au>,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, Matt Evans <matt@ozlabs.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@fb.com>,
	Denis Kirjanov <kda@linux-powerpc.org>,
	Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>
To: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160617130042.GO3516@indiana.gru.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/06/17 10:00AM, Thadeu Lima de Souza Cascardo wrote:
> On Fri, Jun 17, 2016 at 10:53:21PM +1000, Michael Ellerman wrote:
> > On Tue, 2016-07-06 at 13:32:23 UTC, "Naveen N. Rao" wrote:
> > > diff --git a/arch/powerpc/net/bpf_jit_comp64.c b/arch/powerpc/net/bpf_jit_comp64.c
> > > new file mode 100644
> > > index 0000000..954ff53
> > > --- /dev/null
> > > +++ b/arch/powerpc/net/bpf_jit_comp64.c
> > > @@ -0,0 +1,956 @@
> > ...
> > > +
> > > +static void bpf_jit_fill_ill_insns(void *area, unsigned int size)
> > > +{
> > > +	int *p = area;
> > > +
> > > +	/* Fill whole space with trap instructions */
> > > +	while (p < (int *)((char *)area + size))
> > > +		*p++ = BREAKPOINT_INSTRUCTION;
> > > +}
> > 
> > This breaks the build for some configs, presumably you're missing a header:
> > 
> >   arch/powerpc/net/bpf_jit_comp64.c:30:10: error: 'BREAKPOINT_INSTRUCTION' undeclared (first use in this function)
> > 
> > http://kisskb.ellerman.id.au/kisskb/buildresult/12720611/
> > 
> > cheers
> 
> Hi, Michael and Naveen.
> 
> I noticed independently that there is a problem with BPF JIT and ABIv2, and
> worked out the patch below before I noticed Naveen's patchset and the latest
> changes in ppc tree for a better way to check for ABI versions.
> 
> However, since the issue described below affect mainline and stable kernels,
> would you consider applying it before merging your two patchsets, so that we can
> more easily backport the fix?

Hi Cascardo,
Given that this has been broken on ABIv2 since forever, I didn't bother 
fixing it. But, I can see why this would be a good thing to have for 
-stable and existing distros. However, while your patch below may fix 
the crash you're seeing on ppc64le, it is not sufficient -- you'll need 
changes in bpf_jit_asm.S as well.

Regards,
Naveen
