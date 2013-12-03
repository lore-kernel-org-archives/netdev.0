From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net v3] vti: fix spd lookup: match plaintext pkt, not
 ipsec pkt
Date: Tue, 3 Dec 2013 10:39:34 +0100
Message-ID: <20131203093934.GR31491@secunet.com>
References: <1383646612-30103-1-git-send-email-christophe.gouault@6wind.com>
 <1383725153-26298-1-git-send-email-christophe.gouault@6wind.com>
 <20131121121246.GD31491@secunet.com>
 <528F6B32.5050103@6wind.com>
 <20131203075513.GQ31491@secunet.com>
 <529D9DD3.7000908@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Saurabh Mohan <saurabh.mohan@vyatta.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Christophe Gouault <christophe.gouault@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:57083 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751252Ab3LCJjh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Dec 2013 04:39:37 -0500
Content-Disposition: inline
In-Reply-To: <529D9DD3.7000908@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 03, 2013 at 10:01:07AM +0100, Christophe Gouault wrote:
> >
> >On transmit side:
> >
> >1. Mark the packet with the o_key. The policy and the state
> >    must match this key now.
> >
> >2. Do a xfrm_lookup on the original packet with the mark applied.
> >
> >3. Check if we got an IPsec route.
> >
> >4. Clean the skb to not leak informations on namespace
> >    transitions.
> >
> >5. Attach the dst_enty we got from the xfrm_lookup to the skb.
> 
> I am just wondering when exactly the netns transition IPsec and route
> lookups are performed (as far as I understand, we first need to perform
> the SP+SA lookup in inner netns, then change namespaces to outer
> netns, then perform a route lookup).
> 

The idea is to do the xfrm_lookup based on the original dst_entry that
comes with the skb. xfrm_lookup then generates a bundle with the IPsec
dst entries on top. Later xfrm_output pops all IPsec dst entires from
the skb, such that only the original routing one remains. I did not
do much with namespaces so far, but after the IPsec processing we should
be in the situation as we are when we transmitting via ipip. If it
works there it should work with vti too.
