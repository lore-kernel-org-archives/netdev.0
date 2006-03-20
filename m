From: "David S. Miller" <davem@davemloft.net>
Subject: Re: TSO and IPoIB performance degradation
Date: Mon, 20 Mar 2006 01:55:00 -0800 (PST)
Message-ID: <20060320.015500.72136710.davem@davemloft.net>
References: <4410C671.2050300@hp.com>
	<20060309.232301.77550306.davem@davemloft.net>
	<20060320090629.GA11352@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, rick.jones2@hp.com,
	linux-kernel@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: mst@mellanox.co.il
In-Reply-To: <20060320090629.GA11352@mellanox.co.il>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Date: Mon, 20 Mar 2006 11:06:29 +0200

> Is it the case then that this requirement is less essential on
> networks such as IP over InfiniBand, which are very low latency
> and essencially lossless (with explicit congestion contifications
> in hardware)?

You can never assume any attribute of the network whatsoever.
Even if initially the outgoing device is IPoIB, something in
the middle, like a traffic classification or netfilter rule,
could rewrite the packet and make it go somewhere else.

This even applies to loopback packets, because packets can
get rewritten and redirected even once they are passed in
via netif_receive_skb().

> And as Matt Leininger's research appears to show, stretch ACKs
> are good for performance in case of IP over InfiniBand.
>
> Given all this, would it make sense to add a per-netdevice (or per-neighbour)
> flag to re-enable the trick for these net devices (as was done before
> 314324121f9b94b2ca657a494cf2b9cb0e4a28cc)?
> IP over InfiniBand driver would then simply set this flag.

See above, this is not feasible.

The path an SKB can take is opaque and unknown until the very last
moment it is actually given to the device transmit function.

People need to get the "special case this topology" ideas out of their
heads. :-)
