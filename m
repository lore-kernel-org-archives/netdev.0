From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] x86: bpf_jit_comp: simplify trivial boolean return
Date: Wed, 26 Nov 2014 10:41:31 -0800
Message-ID: <1417027291.19695.12.camel@perches.com>
References: <CAADnVQK3iui8cAmhi28=65p2CJbTu45fR98ri8Uh8xLRb=cwnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Quentin Lambert <lambert.quentin@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAADnVQK3iui8cAmhi28=65p2CJbTu45fR98ri8Uh8xLRb=cwnA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-11-26 at 10:34 -0800, Alexei Starovoitov wrote:
> On Wed, Nov 26, 2014 at 10:02 AM, Joe Perches <joe@perches.com> wrote:
> > On Wed, 2014-11-26 at 09:23 -0800, Alexei Starovoitov wrote:
> >> On Wed, Nov 26, 2014 at 8:58 AM, Joe Perches <joe@perches.com> wrote:
> >
> >> > Is there any value in reordering these tests for frequency
> >> > or maybe using | instead of || to avoid multiple jumps?
> >>
> >> probably not. It's not a critical path.
> >> compiler may fuse conditions depending on values anyway.
> >> If it was a critical path, we could have used
> >> (1 << reg) & mask trick.
> >> I picked explicit 'return true' else 'return false' here,
> >> because it felt easier to read. Just a matter of taste.
> >
> > There is a size difference though: (allyesconfig)
> >
> > $ size arch/x86/net/built-in.o*
> >    text    data     bss     dec     hex filename
> >   12999    1012    4336   18347    47ab arch/x86/net/built-in.o.new
> >   13177    1076    4592   18845    499d arch/x86/net/built-in.o.old
> 
> interesting. Compiler obviously thinks that 178 byte increase
> with -O2 is the right trade off. Which I agree with :)

498 overall.

> If I think dropping 'inline' and using -Os will give bigger savings...
> but I suspect 'tinification' folks will compile JIT out anyway...

Smaller is generally better/faster in any case.

> thanks for giving it a shot :)
> That's exactly what I had in mind.
> imo it's less readable, but we probably not going
> to mess much with this piece of code anyway.
> Though to be safe in the future, we'd need to
> add BUILD_BUG_ON that largest value (AUX_REG)
> fits in 32bit (or 64bit) and add a comment that
> verifier goes before the JIT and checks that
> insn->src_reg, insn->dst_reg are less than MAX_BPF_REG,
> so argument 'reg' also doesn't trigger too large shift.
> Perfectionists r us. :)
> ... or just leave it as-is ;)

16 registers max anyway as it's stored
in a :4

No worries, it was just playtime anyway.

cheers, Joe
