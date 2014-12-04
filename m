From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] x86: bpf_jit_comp: simplify trivial boolean return
Date: Thu, 04 Dec 2014 10:05:24 -0800
Message-ID: <1417716324.2721.9.camel@perches.com>
References: <CAADnVQK3iui8cAmhi28=65p2CJbTu45fR98ri8Uh8xLRb=cwnA@mail.gmail.com>
	 <1417032059.16355.4.camel@perches.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1C9FDA63@AcuExch.aculab.com>
	 <1417114175.4305.3.camel@perches.com> <1417685187.2721.1.camel@perches.com>
	 <CAADnVQJawht6+sARaP=s9PyPERjrVOBKiJLrCK0OwnLtzT2CAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@aculab.com>,
	Quentin Lambert <lambert.quentin@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"x86@kernel.org" <x86@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAADnVQJawht6+sARaP=s9PyPERjrVOBKiJLrCK0OwnLtzT2CAA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-12-04 at 07:56 -0800, Alexei Starovoitov wrote:
> On Thu, Dec 4, 2014 at 1:26 AM, Joe Perches <joe@perches.com> wrote:
> > On Thu, 2014-11-27 at 10:49 -0800, Joe Perches wrote:
> >> On Thu, 2014-11-27 at 12:25 +0000, David Laight wrote:
> >> > Why the change in data?
> >>
> >> btw: without gcov and using -O2
> >>
> >> $ size arch/x86/net/bpf_jit_comp.o*
> >>    text          data     bss     dec     hex filename
> >>    9671             4       0    9675    25cb arch/x86/net/bpf_jit_comp.o.new
> >>   10679             4       0   10683    29bb arch/x86/net/bpf_jit_comp.o.old
> >
> > Alexei?
> >
> > Is this 10% reduction in size a good reason to change the code?
> 
> yes.
> I believe you're seeing it with gcc 4.9. I wanted to double
> check what 4.6 and 4.7 are doing. If they're not suddenly
> increase code size then resubmit it for inclusion please.

I get these sizes for these compilers
(x86-64, -O2, without profiling)

$ size arch/x86/net/bpf_jit_comp.o*
   text	   data	    bss	    dec	    hex	filename
   9266	      4	      0	   9270	   2436	arch/x86/net/bpf_jit_comp.o.4.4.new
  10042	      4	      0	  10046	   273e	arch/x86/net/bpf_jit_comp.o.4.4.old
   9109	      4	      0	   9113	   2399	arch/x86/net/bpf_jit_comp.o.4.6.new
   9717	      4	      0	   9721	   25f9	arch/x86/net/bpf_jit_comp.o.4.6.old
   8789	      4	      0	   8793	   2259	arch/x86/net/bpf_jit_comp.o.4.7.new
  10245	      4	      0	  10249	   2809	arch/x86/net/bpf_jit_comp.o.4.7.old
   9671	      4	      0	   9675	   25cb	arch/x86/net/bpf_jit_comp.o.4.9.new
  10679	      4	      0	  10683	   29bb	arch/x86/net/bpf_jit_comp.o.4.9.old

I am a bit surprised by the size variations
