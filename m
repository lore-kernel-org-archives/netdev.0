From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v9] tilegx network driver: initial support
Date: Wed, 06 Jun 2012 11:54:40 -0700 (PDT)
Message-ID: <20120606.115440.1245419453265419850.davem@davemloft.net>
References: <201206042023.q54KNEZp003834@farm-0002.internal.tilera.com>
	<1339004459.26966.31.camel@edumazet-glaptop>
	<4FCFA312.4020505@tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, bhutchings@solarflare.com, arnd@arndb.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: cmetcalf@tilera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FCFA312.4020505@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Metcalf <cmetcalf@tilera.com>
Date: Wed, 6 Jun 2012 14:36:02 -0400

> By the way, your question about tx_queue_len is a good one; I'm roping in
> our other network developer folks to figure it out.  Originally it was a
> performance optimization, I believe; I'm not sure it's still required. 

It's illegal, you cannot do this.

If you set the TX queue length to zero, amongst other very serious
and grave problems, your device cannot be used with the various
packet scheduler queueing disciplies.

Zero TX queue lengths should only be used for layering drivers which
are purely software entities rather than for real actual hardware.

As stated before, all of the areas where the tilegx driver tries to be
different end up being bugs.  It would therefore be nice, if, as I
suggested before, the driver is audited by you against a known
gold-standard Linux driver such as tg3 to spot inconsistencies like
this.
