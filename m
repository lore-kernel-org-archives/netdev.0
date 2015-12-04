From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next v2 4/4] net: mvneta: Spread out the TX queues management on all CPUs
Date: Fri, 04 Dec 2015 22:30:35 +0100
Message-ID: <10523514.jXrVKo414l@wuerfel>
References: <1449254700-32685-1-git-send-email-gregory.clement@free-electrons.com> <1449254700-32685-5-git-send-email-gregory.clement@free-electrons.com> <1449256350.25029.36.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449256350.25029.36.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 04 December 2015 11:12:30 Eric Dumazet wrote:
> On Fri, 2015-12-04 at 19:45 +0100, Gregory CLEMENT wrote:
> > With this patch each CPU is associated with its own set of TX queues. In
> > the same time the SKB received in mvneta_tx is bound to the queue
> > associated to the CPU sending the data. Thanks to this the next IRQ will
> > be received on the same CPU allowing sending more data.
> > 
> > It will also allow to have a more predictable behavior regarding
> > throughput and latency when having multiple threads sending out data on
> > different CPUs.
> > 
> > As an example on Armada XP GP, with an iperf bound to a CPU and a ping
> > bound to another CPU, without this patch the ping round trip was about
> > 2.5ms (and could reach 3s!), whereas with this patch it was around
> > 0.7ms (and sometime it went to 1.2ms).
> 
> This really looks like you need something smarter than pfifo_fast qdisc,
> and maybe BQL (I did not check if this driver already implements this)

I suggested this change as well as the BQL implementation that Marcin did.
I believe he hasn't posted that yet while he's doing some more testing,
but it should come soon.

	Arnd
