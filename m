From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 1/7] timecounter: provide a macro to initialize
 the cyclecounter mask field.
Date: Mon, 5 Jan 2015 14:43:27 +0100
Message-ID: <20150105134327.GA8156@localhost.localdomain>
References: <cover.1420108214.git.richardcochran@gmail.com>
 <1f1bee3e2aa0cc530d006d99a621992a1497a442.1420108214.git.richardcochran@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CAC09D7@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAC09D7@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 05, 2015 at 01:20:57PM +0000, David Laight wrote:
> > +/* simplify initialization of mask field */
> > +#define CYCLECOUNTER_MASK(bits) (cycle_t)((bits) < 64 ? ((1ULL<<(bits))-1) : -1)
> 
> That has me chasing through the C integer promotion rules.
> Better might be:
> 	((bits) < 64 ? (1ULL << (bits)) - 1 : (((1ULL << 63) - 1) << 1) + 1)
> I actually suspect there is a standard definition somewhere?

This is an exact copy of CLOCKSOURCE_MASK, and if wrong, then both are
wrong.  In any case, I can't see any issue here. Is not

	(some_int_type) -1

always equal to

	0xf...(width of type)

for all integer types, when using 2s compliment?

Thanks
Richard
