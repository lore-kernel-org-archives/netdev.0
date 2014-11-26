From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] x86: bpf_jit_comp: simplify trivial boolean return
Date: Wed, 26 Nov 2014 09:23:59 -0800
Message-ID: <CAADnVQKtYkKtsd9rUFm2yfMoh7F_SRFPVP8hpvSY00KpmB-NNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 26, 2014 at 8:58 AM, Joe Perches <joe@perches.com> wrote:
> On Wed, 2014-11-26 at 08:42 -0800, Alexei Starovoitov wrote:
>> On Wed, Nov 26, 2014 at 1:18 AM, Quentin Lambert
>> <lambert.quentin@gmail.com> wrote:
>> > Remove if then else statements preceding
>> > boolean return.
> []
>> > diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
> []
>> > @@ -135,11 +135,9 @@ static const int reg2hex[] = {
>> >   */
>> >  static inline bool is_ereg(u32 reg)
>> >  {
>> > -       if (reg == BPF_REG_5 || reg == AUX_REG ||
>> > -           (reg >= BPF_REG_7 && reg <= BPF_REG_9))
>> > -               return true;
>> > -       else
>> > -               return false;
>> > +       return (reg == BPF_REG_5 ||
>> > +               reg == AUX_REG ||
>> > +               (reg >= BPF_REG_7 && reg <= BPF_REG_9));
>>
>> please remove extra () around the whole expression, and
>> align in properly, and
>> don't move reg==AUX_REG check to a different line.
>> Subject is not warranted. I don't think it's a simplification.
>
> It's not really a simplification,
> gcc should emit the same object code.

exactly.

>> imo existing code is fine and I don't think the time spent
>> reviewing such changes is worth it when there is no
>> improvement in readability.
>
> Is there any value in reordering these tests for frequency
> or maybe using | instead of || to avoid multiple jumps?

probably not. It's not a critical path.
compiler may fuse conditions depending on values anyway.
If it was a critical path, we could have used
(1 << reg) & mask trick.
I picked explicit 'return true' else 'return false' here,
because it felt easier to read. Just a matter of taste.
