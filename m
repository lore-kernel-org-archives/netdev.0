From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] x86: bpf_jit_comp: Reduce is_ereg() code size
Date: Thu, 4 Dec 2014 15:31:00 -0800
Message-ID: <CAADnVQ+3jiYOYReRLPUsFeG1p66ezo-TXBLX3BGQQh7V8QX0tQ@mail.gmail.com>
References: <CAADnVQKtYkKtsd9rUFm2yfMoh7F_SRFPVP8hpvSY00KpmB-NNg@mail.gmail.com>
	<1417734048.2721.22.camel@perches.com>
	<1417734891.22424.2.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joe Perches <joe@perches.com>,
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
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417734891.22424.2.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 4, 2014 at 3:14 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2014-12-04 at 15:00 -0800, Joe Perches wrote:
>> Use the (1 << reg) & mask trick to reduce code size.
>>
>> x86-64 size difference -O2 without profiling for various
>> gcc versions:
>
>>
>> Signed-off-by: Joe Perches <joe@perches.com>
>> ---
>>
>> compiled, untested by me, but per Alexei Starovoitov this passes
>> the test_bpf suite
>
> Really, the root cause of this is the 'inline' abuse in non fast paths
> for non trivial functions.

well, it is a trivial function even from compiler point of view.
Dropping inline keyword doesn't help. gcc still inlines them.
Changing all 3 functions to _noinline_ doesn't help either.
So I think this patch is actually quite helpful to reduce code size.
