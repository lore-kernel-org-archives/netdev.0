From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6] tilegx network driver: initial support
Date: Sun, 20 May 2012 16:55:46 -0400 (EDT)
Message-ID: <20120520.165546.1211013675964130504.davem@davemloft.net>
References: <201205091452.q49EqcO7005975@farm-0027.internal.tilera.com>
	<1336744445.2874.57.camel@bwh-desktop.uk.solarflarecom.com>
	<201205201636.q4KGaoA3003845@farm-0027.internal.tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, arnd@arndb.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: cmetcalf@tilera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201205201636.q4KGaoA3003845@farm-0027.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Metcalf <cmetcalf@tilera.com>
Date: Sun, 20 May 2012 00:42:03 -0400

> +static int tile_net_tx_tso(struct sk_buff *skb, struct net_device *dev)

This function has 80 lines of local variable declarations,
that's absolutely rediculous.

A comment and an empty line interspacing many of these local
variable declarations, also rediculous, and part of why it
is 80 lines long.

This function is completely unreadable, if I have to scan
multiple pages before I get to real code, the function is
broken.

You either need to compartmentalize these variable declarations
and/or write helper functions to spread it out.

This is some of the most unpleasant code I've had to review in quite
some time.  Look at other networking drivers in the tree, such as
drivers/net/ethernet/broadcom/tg3.c, and try to mimick their style and
layout.  Anything in your driver that is different is likely to get
you into trouble and make your driver hard to review.
