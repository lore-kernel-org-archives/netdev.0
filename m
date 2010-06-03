From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Question about an assignment in handle_ing()
Date: Thu, 3 Jun 2010 22:56:47 +1000
Message-ID: <20100603125647.GA595@gondor.apana.org.au>
References: <1274790038.3878.926.camel@bigi> <20100525124636.GA13161@gondor.apana.org.au> <1274793216.3878.947.camel@bigi> <20100525231307.GA19475@gondor.apana.org.au> <1274873881.3878.988.camel@bigi> <1275226150.3587.9.camel@bigi> <20100603080130.GA29709@gondor.apana.org.au> <1275569030.3445.49.camel@bigi> <20100603124717.GB315@gondor.apana.org.au> <1275569594.3445.51.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, kaber@trash.net
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:42131 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753249Ab0FCM4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 08:56:54 -0400
Content-Disposition: inline
In-Reply-To: <1275569594.3445.51.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 03, 2010 at 08:53:14AM -0400, jamal wrote:
>
> I dont see the problem of when tcpdump sees the packet first.
> pedit doesnt care if it is cloned or not.
> What i am worried about - and couldnt parse in your email - is:
> What happens when pedit gets to it first? would skb_cloned() be true
> always/guaranteed?

Yes that's what I've been saying all along.  As long as the skb
is still held up in af_packet's socket queue, the packet will be
marked as cloned.

Only when tcpdump has done a recv(2) on the socket and liberated
the skb in the queue, will you see the clone flag turned off in
pedit.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
