From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC] net: ipv4: drop unicast encapsulated in L2 multicast
Date: Wed, 27 Aug 2014 13:29:27 +0200
Message-ID: <1409138967.2505.11.camel@jlt4.sipsolutions.net>
References: <1408641747-22199-1-git-send-email-johannes@sipsolutions.net>
	  <alpine.LFD.2.11.1408212119510.1896@ja.home.ssi.bg>
	  <20140822.105405.1982870131653082781.davem@davemloft.net>
	 <1409130792.2505.5.camel@jlt4.sipsolutions.net>
	 <alpine.LFD.2.11.1408271255230.2348@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Julian Anastasov <ja-FgGsKACvmQM@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LFD.2.11.1408271255230.2348-c1lBKlETG9EWAawoAK+ZAw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-08-27 at 13:23 +0300, Julian Anastasov wrote:

> 	CLUSTERIP works in LOCAL_IN. My preference is to
> add checks in every protocol where it is missing but if
> you prefer a global check, ip_local_deliver_finish() is
> a good place: CLUSTERIP already changed pkt_type to
> PACKET_HOST. For example:
> 
> 	if (!(skb_rtable(skb)->rt_flags &
> 	      (RTCF_BROADCAST | RTCF_MULTICAST)) &&
> 	    (skb->pkt_type == PACKET_BROADCAST ||
> 	     skb->pkt_type == PACKET_MULTICAST)) {
> 		kfree_skb(skb);
> 		return;
> 	}
> 
> 	By this way we protect the local stack globally.

I suppose that'd work then?

> BTW, what kind of packets (protocol) we want to drop? UDP?

All IP protocols, this comes either from the IPv4 RFC (1122) or from the
wireless issue which affects all protocols.

> 	As for ip_forward(), there is already check for
> PACKET_HOST.
> 
> 	Not sure, may be a MIB counter for such drops
> would be useful.

Yeah, maybe, not sure.

johannes


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
