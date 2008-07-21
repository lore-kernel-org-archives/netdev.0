From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
 RCU.
Date: Mon, 21 Jul 2008 09:25:56 -0700 (PDT)
Message-ID: <20080721.092556.227421936.davem@davemloft.net>
References: <20080721152220.GA12341@gondor.apana.org.au>
	<20080721.082627.128593651.davem@davemloft.net>
	<20080721161616.GA12938@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080721161616.GA12938-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Date: Tue, 22 Jul 2008 00:16:16 +0800

> On Mon, Jul 21, 2008 at 08:26:27AM -0700, David Miller wrote:
> >
> > It is totally unwise to do CPU based TX hashing.
> 
> Right I'm not suggesting having this as a default.  However,
> if you have a finely tuned system (e.g., a router) where you've
> pinned all you RX queues to specific CPUs and your local apps
> as well then it would make sense to provide this as an alternative.
> 
> If this alternative doesn't exist, then unless the RX hash happens
> to match the TX hash, for routing at least the packets are going
> to jump all over the place which isn't nice.

Where are these places they are going to "jump all over"? :-)

You can view the RX and TX queues as roughly independent namespaces.

If the TX hash is good enough (current one certainly isn't and I will
work on fixing that), it is likely to spread the accesses enough that
there won't be many collisions to matter.

If you really think about it, this is even pointless.  Packets that
hit RX queue A will always hit TX queue B, and so on and so forth.
Therefore there will be no new level of separation afforded by using
some kind of strict RX to TX mapping.

We could provide the option, but it is so dangerous and I also see no
real tangible benfit from it.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
