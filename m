From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: Re: [6/6] ppc: ebpf/jit: Implement JIT compiler for extended BPF
Date: Tue, 21 Jun 2016 12:28:47 +0530
Message-ID: <20160621065847.GD8886@naverao1-tp.localdomain>
References: <908d3552b5eb240b28f70aee7c4c86e2b600aa02.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
 <3rWKtT2tSrz9t2G@ozlabs.org>
 <20160619173642.GB8886@naverao1-tp.localdomain>
 <1466465899.437.0.camel@ellerman.id.au>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:15743 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754021AbcFUHAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 03:00:08 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5L6xfmQ114982
	for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 03:00:07 -0400
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0b-001b2d01.pphosted.com with ESMTP id 23n2ekf2ug-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 03:00:07 -0400
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <naveen.n.rao@linux.vnet.ibm.com>;
	Tue, 21 Jun 2016 17:00:04 +1000
Content-Disposition: inline
In-Reply-To: <1466465899.437.0.camel@ellerman.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/06/21 09:38AM, Michael Ellerman wrote:
> On Sun, 2016-06-19 at 23:06 +0530, Naveen N. Rao wrote:
> > On 2016/06/17 10:53PM, Michael Ellerman wrote:
> > > On Tue, 2016-07-06 at 13:32:23 UTC, "Naveen N. Rao" wrote:
> > > > diff --git a/arch/powerpc/net/bpf_jit_comp64.c b/arch/powerpc/net/bpf_jit_comp64.c
> > > > new file mode 100644
> > > > index 0000000..954ff53
> > > > --- /dev/null
> > > > +++ b/arch/powerpc/net/bpf_jit_comp64.c
> > > > @@ -0,0 +1,956 @@
> > > ...
> 
> > > > +
> > > > +static void bpf_jit_fill_ill_insns(void *area, unsigned int size)
> > > > +{
> > > > +	int *p = area;
> > > > +
> > > > +	/* Fill whole space with trap instructions */
> > > > +	while (p < (int *)((char *)area + size))
> > > > +		*p++ = BREAKPOINT_INSTRUCTION;
> > > > +}
> > > 
> > > This breaks the build for some configs, presumably you're missing a header:
> > > 
> > >   arch/powerpc/net/bpf_jit_comp64.c:30:10: error: 'BREAKPOINT_INSTRUCTION' undeclared (first use in this function)
> > > 
> > > http://kisskb.ellerman.id.au/kisskb/buildresult/12720611/
> > 
> > Oops. Yes, I should have caught that. I need to add:
> > 
> > #include <asm/kprobes.h>
> > 
> > in bpf_jit_comp64.c
> > 
> > Can you please check if it resolves the build error?
> 
> Can you? :D

:)
Sorry, I should have explained myself better. I did actually try your 
config and I was able to reproduce the build error. After the above 
#include, that error went away, but I saw some vdso related errors. I 
thought I was doing something wrong and needed a different setup for 
that particular kernel config, which is why I requested your help in the 
matter. I just didn't do a good job of putting across that message...

Note to self: randconfig builds *and* more time drafting emails :)

Do you want me to respin the patches?


Thanks,
Naveen
