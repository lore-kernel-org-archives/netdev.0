From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Tue, 17 Aug 2010 10:32:16 +0200
Message-ID: <20100817083216.GA3330@riccoc20.at.omicron.at>
References: <cover.1281956490.git.richard.cochran@omicron.at>
 <201008161626.24083.arnd@arndb.de>
 <20100816190003.GB4166@riccoc20.at.omicron.at>
 <201008162159.39734.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@lists.ozlabs.org,
	Rodolfo Giometti <giometti@linux.it>, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201008162159.39734.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 16, 2010 at 09:59:39PM +0200, Arnd Bergmann wrote:
> Why does it matter how long it takes to read the clock? I wasn't thinking
> of replacing the system clock with this, just exposing the additional
> clock as a new clockid_t value that can be accessed using the existing
> syscalls.

Okay, now I see. You are suggesting this:

      clock_gettime(CLOCK_PTP, &ts);
      clock_settime(CLOCK_PTP, &ts);

I like this. If there is agreement about it, I am happy to implement
the PTP stuff that way.

> Why did you not want to add syscalls? Adding ioctls instead of syscalls
> does not make the interface better, just less visible.

I bet that, had I posted patch set with new syscalls, someone would
have said, "You are adding new syscalls. Can't you just use a char
device instead!"

If you add syscalls and introduce CLOCK_PTP, then you add it to
everyone's kernel, even those people who never heard of PTP. A char
device has the advantage that can it be simply ignored. Also, a
syscall has got to have the right form from the very beginning. If the
next generation of PTP hardware looks very different, then it is not
that much of a crime to change an ioctl interface, provided it has
versioning.

Richard
