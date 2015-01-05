From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 1/7] timecounter: provide a macro to initialize
 the cyclecounter mask field.
Date: Mon, 5 Jan 2015 13:53:51 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAC0A10@AcuExch.aculab.com>
References: <cover.1420108214.git.richardcochran@gmail.com>
 <1f1bee3e2aa0cc530d006d99a621992a1497a442.1420108214.git.richardcochran@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CAC09D7@AcuExch.aculab.com>
 <20150105134327.GA8156@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"John Stultz" <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: 'Richard Cochran' <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150105134327.GA8156@localhost.localdomain>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Mon, Jan 05, 2015 at 01:20:57PM +0000, David Laight wrote:
> > > +/* simplify initialization of mask field */
> > > +#define CYCLECOUNTER_MASK(bits) (cycle_t)((bits) < 64 ? ((1ULL<<(bits))-1) : -1)
> >
> > That has me chasing through the C integer promotion rules.
> > Better might be:
> > 	((bits) < 64 ? (1ULL << (bits)) - 1 : (((1ULL << 63) - 1) << 1) + 1)
> > I actually suspect there is a standard definition somewhere?
> 
> This is an exact copy of CLOCKSOURCE_MASK, and if wrong, then both are
> wrong.  In any case, I can't see any issue here. Is not
> 
> 	(some_int_type) -1
> 
> always equal to
> 
> 	0xf...(width of type)
> 
> for all integer types, when using 2s compliment?

As I said, it leaves me chasing through the promotion rules (which I
probably know if I actually think hard enough).

Thinking... ~0ULL would be nice and simple and correct.

	David
