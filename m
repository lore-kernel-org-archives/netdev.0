From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3 06/10] net/macb: clean up ring buffer logic
Date: Wed, 31 Oct 2012 08:57:43 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B707F@saturn3.aculab.com>
References: <cover.1351591858.git.nicolas.ferre@atmel.com><75eb5df193c504e68ebff7d6a6a88d9a1cc678cb.1351591858.git.nicolas.ferre@atmel.com><AE90C24D6B3A694183C094C60CF0A2F6026B707D@saturn3.aculab.com> <CACiLriQnQcoXFqrqNt3nkY47nR8FnXbqWjtPRp250gueHSMDmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Nicolas Ferre" <nicolas.ferre@atmel.com>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	<bhutchings@solarflare.com>,
	<linux-arm-kernel@lists.infradead.org>, <plagnioj@jcrosoft.com>,
	<patrice.vilchez@atmel.com>, <linux-kernel@vger.kernel.org>,
	<manabian@gmail.com>
To: =?Windows-1252?Q?H=E5vard_Skinnemoen?= <havard@skinnemoen.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <CACiLriQnQcoXFqrqNt3nkY47nR8FnXbqWjtPRp250gueHSMDmQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Tue, Oct 30, 2012 at 4:12 AM, David Laight <David.Laight@aculab.com> wrote:
> >> Instead of masking head and tail every time we increment them, just let them
> >> wrap through UINT_MAX and mask them when subscripting. Add simple accessor
> >> functions to do the subscripting properly to minimize the chances of messing
> >> this up.
> > ...
> >> +static unsigned int macb_tx_ring_avail(struct macb *bp)
> >> +{
> >> +     return TX_RING_SIZE - (bp->tx_head - bp->tx_tail);
> >> +}
> >
> > That one doesn't look quite right to me.
> > Surely it should be masking with 'TX_RING_SIZE - 1'
> 
> Why is that? head and tail can never be more than TX_RING_SIZE apart,
> so it shouldn't make any difference.

It's a ring buffer (I presume) the pointers can be in either order.

	David
