From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] x86: bpf_jit_comp: Reduce is_ereg() code size
Date: Thu, 04 Dec 2014 15:14:51 -0800
Message-ID: <1417734891.22424.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAADnVQKtYkKtsd9rUFm2yfMoh7F_SRFPVP8hpvSY00KpmB-NNg@mail.gmail.com>
	 <1417734048.2721.22.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
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
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417734048.2721.22.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-12-04 at 15:00 -0800, Joe Perches wrote:
> Use the (1 << reg) & mask trick to reduce code size.
> 
> x86-64 size difference -O2 without profiling for various
> gcc versions:

> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> 
> compiled, untested by me, but per Alexei Starovoitov this passes
> the test_bpf suite

Really, the root cause of this is the 'inline' abuse in non fast paths
for non trivial functions.
