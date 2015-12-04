From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: bpf: undefined shift in __bpf_prog_run
Date: Fri, 4 Dec 2015 11:10:15 -0800
Message-ID: <20151204191013.GB45508@ast-mbp.thefacebook.com>
References: <CACT4Y+ZxoR3UjLgcNdUm4fECLMx2VdtfrENMtRRCdgHB2n0bJA@mail.gmail.com>
 <20151204184333.GA42737@ast-mbp.thefacebook.com>
 <CACT4Y+YLV4scGXSFz=G3ACa-WE8VuT5wDGvPBV9D2Q+devxedA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>,
	Andrey Ryabinin <ryabinin.a.a@gmail.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACT4Y+YLV4scGXSFz=G3ACa-WE8VuT5wDGvPBV9D2Q+devxedA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 04, 2015 at 08:03:47PM +0100, Dmitry Vyukov wrote:
> > is it with some random seccomp program?
> > If normal libseccomp generates such programs than it needs to be fixed.
> 
> Yes, it is with completely random seccomp program.
> 
> >> Such shifts have undefined behavior according to C standard and behave
> >> differently on different archs. I guess we don't want to rely on any
> >> kind of undefined behavior in bpf/seccomp. And generally want to
> >> completely define results of all operations in bpf.
> >
> > bpf is an engine and we're not going to slow down each shift operation
> > by extra run-time checks or masks.
> > In other words bpf shift instruction == shift in C. Both undefined
> > with for large operands.
> > If seccomp is relying on undefined behavior, it should be fixed.
> 
> But note that it is not that result of such operation is undefined, it
> is overall kernel behavior that becomes undefined.

not true.
just don't generate random bpf programs with such shifts.
kernel is fine.
