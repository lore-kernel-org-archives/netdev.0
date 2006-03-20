From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Re: TSO and IPoIB performance degradation
Date: Mon, 20 Mar 2006 11:06:29 +0200
Message-ID: <20060320090629.GA11352@mellanox.co.il>
References: <20060308125311.GE17618@mellanox.co.il>
	<20060309.154819.104282952.davem@davemloft.net>
	<4410C671.2050300@hp.com>
	<20060309.232301.77550306.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rdreier@cisco.com, rick.jones2@hp.com,
	linux-kernel@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060309.232301.77550306.davem@davemloft.net>
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

Quoting r. David S. Miller <davem@davemloft.net>:
> > well, there are stacks which do "stretch acks" (after a fashion) that 
> > make sure when they see packet loss to "do the right thing" wrt sending 
> > enough acks to allow cwnds to open again in a timely fashion.
> 
> Once a loss happens, it's too late to stop doing the stretch ACKs, the
> damage is done already.  It is going to take you at least one
> extra RTT to recover from the loss compared to if you were not doing
> stretch ACKs.
> 
> You have to keep giving consistent well spaced ACKs back to the
> receiver in order to recover from loss optimally.

Is it the case then that this requirement is less essential on
networks such as IP over InfiniBand, which are very low latency
and essencially lossless (with explicit congestion contifications
in hardware)?

> The ACK every 2 full sized frames behavior of TCP is absolutely
> essential.

Interestingly, I was pointed towards the following RFC draft
http://www.ietf.org/internet-drafts/draft-ietf-tcpm-rfc2581bis-00.txt

    The requirement that an ACK "SHOULD" be generated for at least every
    second full-sized segment is listed in [RFC1122] in one place as a
    SHOULD and another as a MUST.  Here we unambiguously state it is a
    SHOULD.  We also emphasize that this is a SHOULD, meaning that an
    implementor should indeed only deviate from this requirement after
    careful consideration of the implications.

And as Matt Leininger's research appears to show, stretch ACKs
are good for performance in case of IP over InfiniBand.

Given all this, would it make sense to add a per-netdevice (or per-neighbour)
flag to re-enable the trick for these net devices (as was done before
314324121f9b94b2ca657a494cf2b9cb0e4a28cc)?
IP over InfiniBand driver would then simply set this flag.

David, would you accept such a patch? It would be nice to get 2.6.17
back to within at least 10% of 2.6.11.

-- 
Michael S. Tsirkin
Staff Engineer, Mellanox Technologies
