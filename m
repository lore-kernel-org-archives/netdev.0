From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH V7 1/8] ntp: add ADJ_SETOFFSET mode bit
Date: Sun, 26 Dec 2010 15:14:47 +0100
Message-ID: <20101226141447.GA4830@riccoc20.at.omicron.at>
References: <cover.1292512461.git.richard.cochran@omicron.at>
 <880d82bb8120f73973db27e0c48e949014b1a106.1292512461.git.richard.cochran@omicron.at>
 <AANLkTi=yGoFwYt4p_LeHtAQyYgmURspO-p57UdL0sUEZ@mail.gmail.com>
 <20101221075612.GA13626@riccoc20.at.omicron.at>
 <AANLkTimJd5pScKTiDxuYd-h+NevYbCusyvUAqmUDXe8h@mail.gmail.com>
 <1292970355.2618.76.camel@work-vm>
 <AANLkTimmTzH8+fSYmbajqZ+hU5Ps-UZaTp_1TYzjHB6P@mail.gmail.com>
 <20101223061359.GA7169@riccoc20.at.omicron.at>
 <AANLkTind84BVd=2Z07Sz+JfpVRH7m8wdx37YhRcqkCZv@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john stultz <johnstul@us.ibm.com>, linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>
To: "Kuwahara,T." <6vvetjsrt26xsrzlh1z0zn4d2grdah@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTind84BVd=2Z07Sz+JfpVRH7m8wdx37YhRcqkCZv@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 26, 2010 at 05:38:57AM +0900, Kuwahara,T. wrote:
> After all, I'd prefer your earlier patchset.  Leaving aside the
> compatibility issue, there's no particular reason we have to re-use
> the struct timex, which requires otherwise unnecessary conditional
> branches as well as unit conversions.  Don't you agree?

Well, from my point of view of wanting to allow a user space clock
servo to be able to adjust a hardware clock, it would be sufficient to
offer a way to jump the clock and to adjust the frequency via one or
perhaps two new system calls.

That is indeed what I first suggested, and I still think it would be a
clean and simple interface. The NTP call is quite gross, since it
multiplexes a whole bunch of different functions through the timex
structure.

However, several reviewers on the lkml prefered to keep with the NTP
interface. It offers the needed functionality and is already well
established, despite its ugliness.

To me, the proposed ADJ_SETOFFSET is a simple and logical extenstion
of the NTP interface. Also, the implementation is straightforward. In
contrast, using a special -INF value seems a bit obtuse to me.

Richard
