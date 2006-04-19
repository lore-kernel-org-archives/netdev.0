From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] ip_route_input panic fix
Date: Wed, 19 Apr 2006 04:59:37 +0400
Message-ID: <20060419005937.GA12501@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from dust.inr.ac.ru ([194.67.69.100]:48260 "HELO dust.inr.ac.ru")
	by vger.kernel.org with SMTP id S1750962AbWDSA75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2006 20:59:57 -0400
To: herbert@gondor.apana.org.au, shemminger@osdl.org,
	davem@davemloft.net, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> There is also the ARP code which passes an ARP packet through that
> would get dereferenced as an IP packet.  Granted this shouldn't crash
> because nh is set properly.

And point to something which is not an IP header. So, iph->protocol
is something funny. :-)

It is plain luck that this never happens, ARP packets
with multicast addresses are filtered out.

Mess, I agree.


> But we really should make up our mind as to whether the routing key
> comes from the arguments to ip_route_input (src/dst/...) or the skb.
>
> Using both is just asking for trouble.

Well, both sets are present only for use the same function in ARP.

So, arguments. skb can be even preserved, but it should not be used
for anything but debugging or for hints, when we should not create
cache entry.


BTW, I cannot figure out what ip_check_mc tries to do with protocol
(which is __u16 by some reason). If it creates cache entry, protocol
is not checked. Funny.

Alexey
