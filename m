From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] x86: bpf_jit_comp: simplify trivial boolean return
Date: Wed, 26 Nov 2014 08:58:28 -0800
Message-ID: <1417021108.19695.5.camel@perches.com>
References: <CAADnVQK8mn4ZHwbhBArosEw3Bmsc5vJfOzAeRE3R_1S7dbNfkg@mail.gmail.com>
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
In-Reply-To: <CAADnVQK8mn4ZHwbhBArosEw3Bmsc5vJfOzAeRE3R_1S7dbNfkg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-11-26 at 08:42 -0800, Alexei Starovoitov wrote:
> On Wed, Nov 26, 2014 at 1:18 AM, Quentin Lambert
> <lambert.quentin@gmail.com> wrote:
> > Remove if then else statements preceding
> > boolean return.
[]
> > diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
[]
> > @@ -135,11 +135,9 @@ static const int reg2hex[] = {
> >   */
> >  static inline bool is_ereg(u32 reg)
> >  {
> > -       if (reg == BPF_REG_5 || reg == AUX_REG ||
> > -           (reg >= BPF_REG_7 && reg <= BPF_REG_9))
> > -               return true;
> > -       else
> > -               return false;
> > +       return (reg == BPF_REG_5 ||
> > +               reg == AUX_REG ||
> > +               (reg >= BPF_REG_7 && reg <= BPF_REG_9));
> 
> please remove extra () around the whole expression, and
> align in properly, and
> don't move reg==AUX_REG check to a different line.
> Subject is not warranted. I don't think it's a simplification.

It's not really a simplification,
gcc should emit the same object code.

> imo existing code is fine and I don't think the time spent
> reviewing such changes is worth it when there is no
> improvement in readability.

Is there any value in reordering these tests for frequency
or maybe using | instead of || to avoid multiple jumps?
