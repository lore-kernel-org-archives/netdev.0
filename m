From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 6/6] ppc: ebpf/jit: Implement JIT compiler for
 extended BPF
Date: Mon, 4 Apr 2016 22:39:11 +0530
Message-ID: <20160404170911.GA15993@naverao1-tp.in.ibm.com>
References: <cover.1459504222.git.naveen.n.rao@linux.vnet.ibm.com>
 <b58a289b51bbce73f8539290b721a5d461b7cebb.1459504224.git.naveen.n.rao@linux.vnet.ibm.com>
 <56FEB9AD.2080401@fb.com>
 <56FEBF51.7090608@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@fb.com>, linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, Matt Evans <matt@ozlabs.org>,
	oss@buserror.net, Paul Mackerras <paulus@samba.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56FEBF51.7090608@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/04/01 08:34PM, Daniel Borkmann wrote:
> On 04/01/2016 08:10 PM, Alexei Starovoitov wrote:
> >On 4/1/16 2:58 AM, Naveen N. Rao wrote:
> >>PPC64 eBPF JIT compiler. Works for both ABIv1 and ABIv2.
> >>
> >>Enable with:
> >>echo 1 > /proc/sys/net/core/bpf_jit_enable
> >>or
> >>echo 2 > /proc/sys/net/core/bpf_jit_enable
> >>
> >>... to see the generated JIT code. This can further be processed with
> >>tools/net/bpf_jit_disasm.
> >>
> >>With CONFIG_TEST_BPF=m and 'modprobe test_bpf':
> >>test_bpf: Summary: 291 PASSED, 0 FAILED, [234/283 JIT'ed]
> >>
> >>... on both ppc64 BE and LE.
> >>
> >>The details of the approach are documented through various comments in
> >>the code, as are the TODOs. Some of the prominent TODOs include
> >>implementing BPF tail calls and skb loads.
> >>
> >>Cc: Matt Evans <matt@ozlabs.org>
> >>Cc: Michael Ellerman <mpe@ellerman.id.au>
> >>Cc: Paul Mackerras <paulus@samba.org>
> >>Cc: Alexei Starovoitov <ast@fb.com>
> >>Cc: "David S. Miller" <davem@davemloft.net>
> >>Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
> >>Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
> >>---
> >>  arch/powerpc/include/asm/ppc-opcode.h |  19 +-
> >>  arch/powerpc/net/Makefile             |   4 +
> >>  arch/powerpc/net/bpf_jit.h            |  66 ++-
> >>  arch/powerpc/net/bpf_jit64.h          |  58 +++
> >>  arch/powerpc/net/bpf_jit_comp64.c     | 828 ++++++++++++++++++++++++++++++++++
> >>  5 files changed, 973 insertions(+), 2 deletions(-)
> >>  create mode 100644 arch/powerpc/net/bpf_jit64.h
> >>  create mode 100644 arch/powerpc/net/bpf_jit_comp64.c
> >...
> >>-#ifdef CONFIG_PPC64
> >>+#if defined(CONFIG_PPC64) && (!defined(_CALL_ELF) || _CALL_ELF != 2)
> >
> >impressive stuff!
> 
> +1, awesome to see another one!

Thanks!

> 
> >Everything nicely documented. Could you add few words for the above
> >condition as well ?
> >Or may be a new macro, since it occurs many times?
> >What are these _CALL_ELF == 2 and != 2 conditions mean? ppc ABIs ?

Yes, there are 2 ABIs: ppc64 (ABIv1) -- big endian and the recently 
introduced ppc64le (ABIv2) which is currently only little endian. There 
is also ppc32...

Good suggestion about using a macro. I will put out a patch for that.

> >Will there ever be v3 ?

Hope not! ;)

> 
> Minor TODO would also be to convert to use bpf_jit_binary_alloc() and
> bpf_jit_binary_free() API for the image, which is done by other eBPF
> jits, too.

Sure. I will make that change.

> 
> >So far most of the bpf jits were going via net-next tree, but if
> >in this case no changes to the core is necessary then I guess it's fine
> >to do it via powerpc tree. What's your plan?

I initially thought this has to go through the powerpc tree. I don't 
really have a preference and I'll allow the maintainers to take a call 
on that. I do however need a review of the JIT code from Michael
Ellerman/Paul Mackerras.


- Naveen
