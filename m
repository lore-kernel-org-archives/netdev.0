From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] x86: bpf_jit_comp: simplify trivial boolean return
Date: Wed, 26 Nov 2014 12:00:59 -0800
Message-ID: <1417032059.16355.4.camel@perches.com>
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
> 
> If I think dropping 'inline' and using -Os will give bigger savings...

This was allyesconfig which already uses -Os

Using -O2, there is no difference using inline
or not, but the size delta with the bitmask is
much larger

$ size arch/x86/net/built-in.o* (allyesconfig, but not -Os)
   text	   data	    bss	    dec	    hex	filename
  13410	    820	   3624	  17854	   45be	arch/x86/net/built-in.o.new
  16130	    884	   4200	  21214	   52de	arch/x86/net/built-in.o.old
  16130	    884	   4200	  21214	   52de	arch/x86/net/built-in.o.static
