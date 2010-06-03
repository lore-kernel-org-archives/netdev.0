From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Question about an assignment in handle_ing()
Date: Thu, 3 Jun 2010 22:47:17 +1000
Message-ID: <20100603124717.GB315@gondor.apana.org.au>
References: <1274789024.3878.919.camel@bigi> <20100525121202.GA12712@gondor.apana.org.au> <1274790038.3878.926.camel@bigi> <20100525124636.GA13161@gondor.apana.org.au> <1274793216.3878.947.camel@bigi> <20100525231307.GA19475@gondor.apana.org.au> <1274873881.3878.988.camel@bigi> <1275226150.3587.9.camel@bigi> <20100603080130.GA29709@gondor.apana.org.au> <1275569030.3445.49.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, kaber@trash.net
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:39614 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751621Ab0FCMrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 08:47:25 -0400
Content-Disposition: inline
In-Reply-To: <1275569030.3445.49.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 03, 2010 at 08:43:50AM -0400, jamal wrote:
> 
> On Thu, 2010-06-03 at 18:01 +1000, Herbert Xu wrote:
> > On Sun, May 30, 2010 at 09:29:10AM -0400, jamal wrote:
> 
> > > The packet path is:
> > > -->eth0-->tcpdump eth0-->pedit-->mirror to dummy0-->tcpdump dummy0
> > 
> > Well this doesn't guarantee a cloned packet at all.  Once af_packet
> > receives the packet it'll wake up any listeners like tcpdump, if
> > tcpdump gets to it before pedit runs then the packet won't be
> > cloned anymore.
> 
> I may be misreading, but:
> This is the point i have been trying to make, Herbert;-> There is no
> _guarantee_ that the first tcpdump will see the packet that came out of
> eth0 instead of seeing the packet that came out the pedit part of the
> pipeline. I need to see the correct packet. I know with my check
> this is guaranteed.

You *are* misreading what I wrote.

As I've repeatedly stated, it is guaranteed that either tcpdump
is finished with the skb, or you will see it as cloned.

Anything else is a serious bug in our stack, regardless of what
pedit does.

In fact pedit is buggy today because you're modifying a packet
that may be cloned.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
