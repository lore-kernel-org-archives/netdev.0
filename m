From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: next build: 235 warnings 3 failures (next/next-20151117)
Date: Wed, 18 Nov 2015 10:22:04 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBD51BD@AcuExch.aculab.com>
References: <564a9961.878b420a.331b8.fffffd62@mx.google.com>
 <6370082.rfihnaNWhf@wuerfel> <20151117171236.GJ30101@arm.com>
 <3723928.99NZh1TC6E@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	"kernel-build-reports@lists.linaro.org"
	<kernel-build-reports@lists.linaro.org>,
	"olof@lixom.net" <olof@lixom.net>,
	David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: 'Arnd Bergmann' <arnd@arndb.de>, Will Deacon <will.deacon@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3723928.99NZh1TC6E@wuerfel>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann
> Sent: 17 November 2015 19:17
> On Tuesday 17 November 2015 17:12:37 Will Deacon wrote:
> > On Tue, Nov 17, 2015 at 06:03:40PM +0100, Arnd Bergmann wrote:
> > > On Tuesday 17 November 2015 16:44:53 Will Deacon wrote:
> > > > > 8<----
> > > > > Subject: ARM64: make smp_load_acquire() work with const arguments
> > > > >
> > > > > smp_load_acquire() uses typeof() to declare a local variable for temporarily
> > > > > storing the output of the memory access. This fails when the argument is
> > > > > constant, because the assembler complains about using a constant register
> > > > > as output:
> > > > >
> > > > >  arch/arm64/include/asm/barrier.h:71:3: error: read-only variable '___p1'
> > > > >  used as 'asm' output
> > > >
> > > > Do you know the usage in the kernel causing this warning?
> > >
> > > A newly introduced function in include/net/sock.h:
> > >
> > > static inline int sk_state_load(const struct sock *sk)
> > > {
> > >         return smp_load_acquire(&sk->sk_state);
> > > }
> >
> > Hmm, maybe we could play a similar trick to READ_ONCE by declaring an
> > anonymous union and writing through the non-const member?
> 
> Yes, I think that would work, if you think we need to care about the
> case where we read into a structure.

How are you going to find the right type/size for the non-const member of the union?
If the type/size is fixed then why use typeof()?

If the variable being read (sk->sk_state above) might only be 8 or 16 bits then
you might be able to use sizeof() to select between code paths.

	David
