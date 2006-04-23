From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipsec tunnel asymmetrical mtu
Date: Sun, 23 Apr 2006 13:51:55 +1000
Message-ID: <E1FXVdb-0003Tt-00@gondolin.me.apana.org.au>
References: <BAY103-F21399F30719D1EBD180B04B2CC0@phx.gbl>
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:24839 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751044AbWDWDv6
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Apr 2006 23:51:58 -0400
To: pupilla@hotmail.com (Marco Berizzi)
In-Reply-To: <BAY103-F21399F30719D1EBD180B04B2CC0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marco Berizzi <pupilla@hotmail.com> wrote:
> 
> Is there any news about this issue?

Sorry for the delay, I've been travelling.

The fact that tcpdump with "host 172.16.0.138" does not fix it tells
us that this is related to the NAT that you're doing to the 172.16
side of the network.

Looking at your packet dump your setup is definitely suboptimal in
that correct MTU information is not being provided to either side
of the connection.

The result is that the 10.16 end is sending fragments which have to
be reassembled at mimosa before immediately getting refragmented on
its way to pleiadi.

So if it was my network this would be the first issue I'd try to
address, possibly through MSS clamping.

However, the fact that the tcpdump causes more chunky packets to
make it through could be an indication that there is a bug somewhere
in our NAT/IPsec code or at least a suboptimal memory allocation
strategy that's somehow avoided when AF_PACKET pins the skb down.

So I would like your help in tracking that down before you fix your
network properly.

For a start could you please send me the complete kern.log messages
on mimosa from boot time to the point after a slow connection has
occured.  I'd also like to see /proc/net/snmp at that point.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
