From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC] net: ipv4: drop unicast encapsulated in L2 multicast
Date: Thu, 20 Nov 2014 22:31:14 +0100
Message-ID: <1416519074.8557.15.camel@sipsolutions.net>
References: <1408641747-22199-1-git-send-email-johannes@sipsolutions.net>
	 <alpine.LFD.2.11.1408212119510.1896@ja.home.ssi.bg>
	 <20140822.105405.1982870131653082781.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ja-FgGsKACvmQM@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140822.105405.1982870131653082781.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-08-22 at 10:54 -0700, David Miller wrote:

> >>  	if (res.type == RTN_BROADCAST)
> >>  		goto brd_input;
> > 
> > 	Is this place better, after checking for RTN_BROADCAST?
> > 
> > 	/* ARP link-layer broadcasts are acceptable here */
> > 	if ((skb->pkt_type == PACKET_BROADCAST ||
> > 	     skb->pkt_type == PACKET_MULTICAST) &&
> > 	    skb->protocol == htons(ETH_P_IP))
> > 		goto e_inval;
> 
> Indeed, this would make ARP happier, but that still leaves open the
> issue of CLUSTERIP.

I'm back looking at this, but must admit I'm completely confused now :-)

I could add an IPv4 sysctl to control this behaviour:
  0 - off
  1 - RFC 1122 "SHOULD"
  2 - also drop unicast-in-multicast (for wireless)

But I guess due to cluster-IP it would have to default to 0.


However, talk about ip_local_deliver_finish() in this thread has me
wondering if we could just implement it using iptables? I guess
ipt_addrtype and ip6t_addrtype would let me do that?

johannes


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
