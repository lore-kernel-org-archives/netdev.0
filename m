From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] ip_route_input panic fix
Date: Wed, 19 Apr 2006 13:46:59 +0400
Message-ID: <20060419094659.GA16973@ms2.inr.ac.ru>
References: <20060417171253.4e988afc@localhost.localdomain> <E1FVk6q-0000Tf-00@gondolin.me.apana.org.au> <20060418235222.GA20504@ms2.inr.ac.ru> <20060418.205317.18564378.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, shemminger@osdl.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:37531 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1750842AbWDSJry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2006 05:47:54 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060418.205317.18564378.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> ipmr_get_route() is the trouble maker.  If ipmr_cache_find() cannot
> find an entry, it tries to use the netlink SKB to send out an ipv4
> packet, completely mangling it, via ipmr_cache_unresolved().

It just adds dummy IP header to tail of this skb. Nothing illegal.
The skb is not sent out, it is enqueued in an ARP-like queue and
the IP header is submitted to mroute_socket.

When user level mrouter resolves the route, ipmr_cache_resolve()
removes this, completes filling netlink attributes and sends it to netlink.


> Even worse it may even free the skb on us,

Oops, seems, this is a real bug... Need to think how to fix.


> or queue it to mroute_socket.

It is OK, it is the purpose.


> It is pure disaster, this entire code path.

Well, it may be buggy, but esentially there is nothing to simplify.
At least, I do not see.

Alexey
