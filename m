From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v6 0/8] ptp: IEEE 1588 hardware clock support
Date: Fri, 24 Sep 2010 15:07:38 +0100
Message-ID: <20100924150738.744297d0@lxorguk.ukuu.org.uk>
References: <cover.1285261533.git.richard.cochran@omicron.at>
	<20100923213654.0c64b047@lxorguk.ukuu.org.uk>
	<20100924131407.GA3113@riccoc20.at.omicron.at>
	<20100924150246.0e6064b6@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: John Stultz <johnstul@us.ibm.com>, Rodolfo Giometti <giometti@linux.it>,
	Arnd Bergmann <arnd@arndb.de>,
	Peter Zijlstra <peterz@infradead.org>, linux-api@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org,
	Richard Cochran <richardcochran@gmail.com>,
	linux-arm-kernel@lists.infradead.org, Krzysztof Halasa <khc@pm.waw.pl>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20100924150246.0e6064b6@lxorguk.ukuu.org.uk>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

> You can't do that avoiding as you might like because the behaviour of
> file handle numbering is defined by the standards. Hence the "f*"
> versions of the calls (and of lots of other stuff)
> 
> Whether you add new syscalls or do the fd passing using flags and hide
> the ugly bits in glibc is another question.

To add an example of what I mean you might end up defining "CLOCK_FD" to
indicate to use the fd in the struct, but given syscalls are trivial
codewise and would end up as

	fclock_foo(int fd, blah)
	{
		clock = fd_to_clock(fd);
		if (error)
			return error
		clock_do_foo(clock, blah);
		clock_put(clock);
	}

and

	clock_foo(int posixid, blah)
	{
		clock = posix_to_clock(posixid)
		...
		rest same
	}

as wrappers it seems hardly worth adding ugly hacks
