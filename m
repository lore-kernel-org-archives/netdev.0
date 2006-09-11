From: "Ananda Raju" <Ananda.Raju@neterion.com>
Subject: RE: LRO fix needed
Date: Mon, 11 Sep 2006 08:53:16 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77BB97C5@nekter>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:7362 "EHLO
	barracuda.s2io.com") by vger.kernel.org with ESMTP id S1750800AbWIKMzL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Sep 2006 08:55:11 -0400
Received: from owa.neterion.com (unknown [72.1.205.142])
	by barracuda.s2io.com (Spam Firewall) with ESMTP id E77182014A2B
	for <netdev@vger.kernel.org>; Mon, 11 Sep 2006 08:55:09 -0400 (EDT)
Content-class: urn:content-classes:message
To: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"David Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi 

I was on leave for 3 weeks so couldn't answer to Questions.

Current s2io driver won't use any hardware assistance for LRO. Present
hardware Xframe-I and Xframe-II provides header separation functionality
which can be used for LRO but not in use.  Our next generation hardware
will have more assistance for LRO. 

We aggregate
1. Till skb length reaches close to 64k and send the packet up once
skb->len goes to 64k
2. Once there are not more packets to process in the ring buffers. At
end of ISR we indicate all the LRO packets up the network stack. 

Does the modification to gso_size in LRO packet applied to Linux source
tree? 


On Fri, Sep 01, 2006 at 09:43:47AM +1000, herbert wrote:
> 
> It might be better to set it to the biggest frag you see rather
> than the first.

I've coded it up.

BTW Ananda, what hardware assistance do your chips currently provide
for LRO? What are the timeouts used before it gives up on aggregating
a session?

[NETDRV] s2io: Set gso_size for LRO to TCP stack

Now that the TCP stack uses gso_size to estimate the receive MSS,
it helps to actually set it :)

Unlike the sending side, there is no single MSS that naturally
pops up for LRO.  However, for our purposes the maximal TCP payload
size is the most appropriate for estimating MSS.

Signed-off-by: Herbert Xu <[EMAIL PROTECTED]>

Cheers,-----Original Message-----
From: Herbert Xu [mailto:herbert@gondor.apana.org.au] 
Sent: Thursday, August 31, 2006 4:44 PM
To: David Miller
Cc: Ananda Raju; netdev@vger.kernel.org
Subject: Re: LRO fix needed

On Thu, Aug 31, 2006 at 04:42:27PM -0700, David Miller wrote:
> 
> So could you please make the S2io driver LRO path
> set skb_shared_info(skb)->gso_size appropriately?
> Probably the easiest is to use the length of the
> first frag of a multiple frag LRO sequence.

It might be better to set it to the biggest frag you see rather
than the first.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

