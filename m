From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v2] x86: make DR*_RESERVED unsigned long
Date: Fri, 26 Apr 2013 19:15:26 +0200
Message-ID: <20130426171526.GA30875@redhat.com>
References: <CA+55aFwpLu0qNms=hkQr43yqD0K9DgESNm91OEWKT1ZuT8MU6Q@mail.gmail.com> <20130424072630.GB1780@gmail.com> <20130424170702.GA1867@redhat.com> <5178282D.9030902@zytor.com> <20130425144818.GA25921@redhat.com> <20130426163802.GA30351@redhat.com> <517AAED5.7040400@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	the arch/x86 maintainers <x86@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
	Fr??d??ric Weisbecker <fweisbec@gmail.com>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-ext4-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <517AAED5.7040400@zytor.com>
Sender: linux-ext4-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/26, H. Peter Anvin wrote:
>
> On 04/26/2013 09:38 AM, Oleg Nesterov wrote:
> >
> > 	- do_debug:
> >
> > 		dr6 &= ~DR6_RESERVED;
> >
> > 	  this also wrongly clears 32-63 bits. Fortunately these
> > 	  bits are reserved and must be zero.
>
> I don't think this is wrongly at all.

OK, I meant that it also clears the bits that are not specified in
DR6_RESERVED mask.

> The whole point is to mask out
> the bits that the handler doesn't want to deal with, so masking out the
> reserved bits [63:32] seems reasonable to me.

Then we should do

	- #define DR6_RESERVED    0xFFFF0FF0
	+ #define DR6_RESERVED    0xFFFFFFFFFFFF0FF0

?

or what? (just in case, I will happily agree with "do nothing" ;)

> The comment should probably be corrected, though.

Which one?

	/* Define reserved bits in DR6 which are always set to 1 */
	#define DR6_RESERVED    (0xFFFF0FF0UL)

	/* Filter out all the reserved bits which are preset to 1 */
	dr6 &= ~DR6_RESERVED;

I guess both should be updated then. But if I read the doc correctly
the lower reserved bits are set to 1.

However do_debug() does set_debugreg(0, 6) and this looks correct, the
doc says "debug handlers should clear the register before returning to
the interrupted task".

Oleg.

