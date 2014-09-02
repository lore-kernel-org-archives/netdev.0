From: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Subject: Re: [RFC] net: ipv4: drop unicast encapsulated in L2 multicast
Date: Tue, 2 Sep 2014 14:16:20 -0700
Message-ID: <20140902141620.2da1f6aa@urahara>
References: <1408641747-22199-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1408641747-22199-1-git-send-email-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 21 Aug 2014 19:22:27 +0200
Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:

> +	/* RFC 1122 3.3.6:
> +	 *
> +	 *   When a host sends a datagram to a link-layer broadcast address,
> +	 *   the IP destination address MUST be a legal IP broadcast or IP
> +	 *   multicast address.
> +	 *
> +	 *   A host SHOULD silently discard a datagram that is received via
> +	 *   a link-layer broadcast (see Section 2.4) but does not specify
> +	 *   an IP multicast or broadcast destination address.
> +	 *
> +	 * We also do this for link-layer multicast.
> +	 */
> +	if ((skb->pkt_type == PACKET_BROADCAST ||
> +	     skb->pkt_type == PACKET_MULTICAST) &&
> +	    res.type != RTN_BROADCAST)
> +		goto e_inval;
> +

I think you need to all multicast packet but not broadcast.
The RFC does not specify that you should drop link-layer multicast to a unicast
address. There are several clustering products use that.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
