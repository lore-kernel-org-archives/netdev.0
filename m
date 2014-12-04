From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] x86: bpf_jit_comp: Reduce is_ereg() code size
Date: Thu, 04 Dec 2014 15:35:03 -0800
Message-ID: <1417736103.2721.24.camel@perches.com>
References: <CAADnVQKtYkKtsd9rUFm2yfMoh7F_SRFPVP8hpvSY00KpmB-NNg@mail.gmail.com>
	 <1417734048.2721.22.camel@perches.com>
	 <1417734891.22424.2.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Quentin Lambert <lambert.quentin@gmail.com>,
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
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417734891.22424.2.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-12-04 at 15:14 -0800, Eric Dumazet wrote:
> On Thu, 2014-12-04 at 15:00 -0800, Joe Perches wrote:
> > Use the (1 << reg) & mask trick to reduce code size.
[]
> Really, the root cause of this is the 'inline' abuse in non fast paths
> for non trivial functions.

There is no object size change with is_ereg()
defined "static inline" or "static"

Curiously, if you mark it noinline, the size increases.

gcc 4.9.1, x86-64, -O2 no profiling support

$ size arch/x86/net/bpf_jit_comp.o.st*
   text	   data	    bss	    dec	    hex	filename
  10679	      4	      0	  10683	   29bb	arch/x86/net/bpf_jit_comp.o.static_inline
  11535	      4	      0	  11539	   2d13	arch/x86/net/bpf_jit_comp.o.static_noinline
  10679	      4	      0	  10683	   29bb	arch/x86/net/bpf_jit_comp.o.static_without_inline
