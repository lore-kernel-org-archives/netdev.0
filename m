From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help() 2.6.18-rc3
Date: Tue, 1 Aug 2006 22:34:08 +1000
Message-ID: <20060801123408.GB6177@gondor.apana.org.au>
References: <44CE4DCA.8000609@trash.net> <44CF0086.1030404@trash.net> <20060801072358.GB3802@gondor.apana.org.au> <20060801.003614.54188740.davem@davemloft.net> <20060801074504.GA4272@gondor.apana.org.au> <1154433648.5170.84.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:32530 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751452AbWHAMeW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 08:34:22 -0400
To: Jamal Hadi Salim <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1154433648.5170.84.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2006 at 08:00:48AM -0400, Jamal Hadi Salim wrote:
> > > 
> > > > > - tc_verd/tc_index/input_dev: when directing a packet from a device
> > > > >   supporting GSO to a device not supporting GSO using tc actions,
> > > > >   these fields may be set.
> > > > 
> > > > This doesn't look right though.  GSO should occur just before
> > > > hard_start_xmit (after all tc actions have taken place) so we
> > > > shouldn't have any more tc actions to perform.
> > > 
> > > Hmmm, what about loopback?  Yeah yeah, LOOPBACK_TSO is not defined :)
> > > but what I'm really referring to is that loopback preserves the
> > > traffic classifier bits of the skb.
> > 
> > I don't know.  Jamal, is there a scenario where these three attributes
> > are needed for loopback packets?
> 
> I didnt fully understand the scope of the discussion, but a little
> explanation may help answer the question:

My question isn't really about GSO as such.

What I'd like to know is do we really need to preserve

	tc_verd/tc_index/input_dev

for a packet crossing loopback's xmit function?

The reason I'm asking is because currently they're preserved as a matter
of course since loopback just shoves the same packet down the other end.

If we were to apply GSO to loopback (purely as a thought exercise since
loopback can handle large frames just fine without segmenting it :) would
we need to copy those attriutes?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
