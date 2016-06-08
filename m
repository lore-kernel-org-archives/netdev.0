From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/6] ppc: ebpf/jit: Implement JIT compiler for extended
 BPF
Date: Wed, 8 Jun 2016 22:47:47 +0530
Message-ID: <20160608171747.GP18654@naverao1-tp.localdomain>
References: <cover.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
 <908d3552b5eb240b28f70aee7c4c86e2b600aa02.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
 <20160607225609.GA40706@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Matt Evans <matt@ozlabs.org>, Alexei Starovoitov <ast@fb.com>,
	netdev@vger.kernel.org, Denis Kirjanov <kda@linux-powerpc.org>,
	linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	linuxppc-dev@lists.ozlabs.org,
	"David S. Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:49959 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757594AbcFHRTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 13:19:25 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u58HIqTk018071
	for <netdev@vger.kernel.org>; Wed, 8 Jun 2016 13:19:24 -0400
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23e9m46j5s-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 13:19:24 -0400
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <naveen.n.rao@linux.vnet.ibm.com>;
	Thu, 9 Jun 2016 03:19:21 +1000
Content-Disposition: inline
In-Reply-To: <20160607225609.GA40706@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/06/07 03:56PM, Alexei Starovoitov wrote:
> On Tue, Jun 07, 2016 at 07:02:23PM +0530, Naveen N. Rao wrote:
> > PPC64 eBPF JIT compiler.
> > 
> > Enable with:
> > echo 1 > /proc/sys/net/core/bpf_jit_enable
> > or
> > echo 2 > /proc/sys/net/core/bpf_jit_enable
> > 
> > ... to see the generated JIT code. This can further be processed with
> > tools/net/bpf_jit_disasm.
> > 
> > With CONFIG_TEST_BPF=m and 'modprobe test_bpf':
> > test_bpf: Summary: 305 PASSED, 0 FAILED, [297/297 JIT'ed]
> > 
> > ... on both ppc64 BE and LE.
> 
> Nice. That's even better than on x64 which cannot jit one test:
> test_bpf: #262 BPF_MAXINSNS: Jump, gap, jump, ... jited:0 168 PASS
> which was designed specifically to hit x64 jit pass limit.
> ppc jit has predicatble number of passes and doesn't have this problem
> as expected. Great.

Yes, that's thanks to the clever handling of conditional branches by 
Matt -- we always emit 2 instructions for this reason (encoded in 
PPC_BCC() macro).

> 
> > The details of the approach are documented through various comments in
> > the code.
> > 
> > Cc: Matt Evans <matt@ozlabs.org>
> > Cc: Denis Kirjanov <kda@linux-powerpc.org>
> > Cc: Michael Ellerman <mpe@ellerman.id.au>
> > Cc: Paul Mackerras <paulus@samba.org>
> > Cc: Alexei Starovoitov <ast@fb.com>
> > Cc: Daniel Borkmann <daniel@iogearbox.net>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
> > Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
> > ---
> >  arch/powerpc/Kconfig                  |   3 +-
> >  arch/powerpc/include/asm/asm-compat.h |   2 +
> >  arch/powerpc/include/asm/ppc-opcode.h |  20 +-
> >  arch/powerpc/net/Makefile             |   4 +
> >  arch/powerpc/net/bpf_jit.h            |  53 +-
> >  arch/powerpc/net/bpf_jit64.h          | 102 ++++
> >  arch/powerpc/net/bpf_jit_asm64.S      | 180 +++++++
> >  arch/powerpc/net/bpf_jit_comp64.c     | 956 ++++++++++++++++++++++++++++++++++
> >  8 files changed, 1317 insertions(+), 3 deletions(-)
> >  create mode 100644 arch/powerpc/net/bpf_jit64.h
> >  create mode 100644 arch/powerpc/net/bpf_jit_asm64.S
> >  create mode 100644 arch/powerpc/net/bpf_jit_comp64.c
> 
> don't see any issues with the code.
> Thank you for working on this.
> 
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Thanks, Alexei!


Regards,
Naveen
