From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
	RCU.
Date: Fri, 22 Aug 2008 09:52:05 -0400
Message-ID: <1219413125.4672.39.camel@localhost>
References: <20080822065655.GA18471@gondor.apana.org.au>
	 <20080822.001620.141235108.davem@davemloft.net>
	 <20080822074115.GB25615@gondor.apana.org.au>
	 <20080822.034217.135152551.davem@davemloft.net>
Reply-To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080822.034217.135152551.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2008-22-08 at 03:42 -0700, David Miller wrote:

> I had another idea in the back of my head that I wanted to mention.
> 
> The SKB has a hash, and sources set the hash.  It doesn't matter
> where in the stack it comes from.
> 
> At transmit time, the select queue logic in dev_queue_xmit() will use
> the SKB hash if one has been set already.  Otherwise it will do the
> hashing it does currently.
> 
> So in the simplest case for forwarding, the RX side puts the RSS
> hash or whatever into this SKB hash location.
> 

Makes sense. 
In the case Herbert described, I am assuming that the RSS side could be
configured to select a processor statically (MSI or otherwise). And that
the hash value will be that of the processorid ego the tx queue
selected.

> Then, taking things to the next level, protocols set hashes for
> locally created packets.  And this leads to being able to delete
> the simple_tx_hash() code entirely and also we won't have to add
> support for every protocol on the planet to that function. :)
> 

Well, conntrack could be useful (as long as you dont make it mandatory)
since it already keeps track of flows.
When unresolved, one could add it to some default queue.

cheers,
jamal

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
