From: "David S. Miller" <davem@redhat.com>
Subject: Re: [BUG 2.6.0-test11] pcnet32 oops
Date: Wed, 10 Dec 2003 00:32:34 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031210003234.2cb6f74e.davem@redhat.com>
References: <20031205234510.GA2319@bougret.hpl.hp.com>
	<20031205165900.2920ea6a.davem@redhat.com>
	<20031209151459.A1345@sygehus.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, jt@bougret.hpl.hp.com, linux-kernel@vger.kernel.org,
        tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rask Ingemann Lambertsen <rask@sygehus.dk>
In-Reply-To: <20031209151459.A1345@sygehus.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Sorry, forgot to mention this in the previous email.

The way to fix this properly in the pcnet32 driver itself would
be to pass a stack local "struct sk_buff_head" list down into
these deep routines while we have the locks held.

Instead of freeing the TX skbs, we add them all to this list.

At the top level, the code drops the spinlock and enables cpu irqs,
then it frees up any SKBs that were put on that list.
