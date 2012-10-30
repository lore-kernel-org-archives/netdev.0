From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3 06/10] net/macb: clean up ring buffer logic
Date: Tue, 30 Oct 2012 11:12:53 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B707D@saturn3.aculab.com>
References: <cover.1351591858.git.nicolas.ferre@atmel.com> <75eb5df193c504e68ebff7d6a6a88d9a1cc678cb.1351591858.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <bhutchings@solarflare.com>,
	<linux-arm-kernel@lists.infradead.org>, <plagnioj@jcrosoft.com>,
	<patrice.vilchez@atmel.com>, <linux-kernel@vger.kernel.org>,
	<manabian@gmail.com>
To: "Nicolas Ferre" <nicolas.ferre@atmel.com>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	<havard@skinnemoen.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <75eb5df193c504e68ebff7d6a6a88d9a1cc678cb.1351591858.git.nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Instead of masking head and tail every time we increment them, just let them
> wrap through UINT_MAX and mask them when subscripting. Add simple accessor
> functions to do the subscripting properly to minimize the chances of messing
> this up.
...
> +static unsigned int macb_tx_ring_avail(struct macb *bp)
> +{
> +	return TX_RING_SIZE - (bp->tx_head - bp->tx_tail);
> +}

That one doesn't look quite right to me.
Surely it should be masking with 'TX_RING_SIZE - 1'

	David
