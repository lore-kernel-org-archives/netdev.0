From: Will Deacon <will.deacon@arm.com>
Subject: Re: next build: 235 warnings 3 failures (next/next-20151117)
Date: Tue, 17 Nov 2015 17:12:37 +0000
Message-ID: <20151117171236.GJ30101@arm.com>
References: <564a9961.878b420a.331b8.fffffd62@mx.google.com>
 <4694362.ZPL12j6kR2@wuerfel>
 <20151117164453.GF30101@arm.com>
 <6370082.rfihnaNWhf@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	kernel-build-reports@lists.linaro.org, olof@lixom.net,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6370082.rfihnaNWhf@wuerfel>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 17, 2015 at 06:03:40PM +0100, Arnd Bergmann wrote:
> On Tuesday 17 November 2015 16:44:53 Will Deacon wrote:
> > > 8<----
> > > Subject: ARM64: make smp_load_acquire() work with const arguments
> > > 
> > > smp_load_acquire() uses typeof() to declare a local variable for temporarily
> > > storing the output of the memory access. This fails when the argument is
> > > constant, because the assembler complains about using a constant register
> > > as output:
> > > 
> > >  arch/arm64/include/asm/barrier.h:71:3: error: read-only variable '___p1'
> > >  used as 'asm' output
> > 
> > Do you know the usage in the kernel causing this warning?
> 
> A newly introduced function in include/net/sock.h:
> 
> static inline int sk_state_load(const struct sock *sk)
> {
>         return smp_load_acquire(&sk->sk_state);
> }

Hmm, maybe we could play a similar trick to READ_ONCE by declaring an
anonymous union and writing through the non-const member?

Will
