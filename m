From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 26 Aug 2008 08:24:55 -0400
Message-ID: <20080826082455.729662ae@speedy>
References: <20080822.044248.175133807.davem@davemloft.net>
	<20080822120918.GB14981@ff.dom.local>
	<20080822121144.GA32397@gondor.apana.org.au>
	<20080822.051841.259820995.davem@davemloft.net>
	<20080822124556.GA15788@gondor.apana.org.au>
	<20080824192639.587f9391@speedy>
	<20080824234947.GA19018@gondor.apana.org.au>
	<20080824202922.2cc9b9f6@speedy>
	<20080826073508.GA1039@gondor.apana.org.au>
	<20080826074702.GA1102@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	netdev@vger.kernel.org, denys@visp.net.lb,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:39533 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753908AbYHZMZA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 08:25:00 -0400
In-Reply-To: <20080826074702.GA1102@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Aug 2008 17:47:02 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Tue, Aug 26, 2008 at 05:35:08PM +1000, Herbert Xu wrote:
> > On Sun, Aug 24, 2008 at 08:29:22PM -0400, Stephen Hemminger wrote:
> > > 
> > > But then you couldn't replace tfifo with pfifo or tbf??
> > 
> > Couldn't the user install TBF as a parent of netem instead?
> 
> In fact, having tfifo there all the time gives us something
> that we couldn't do before.  Conceptually, whether TBF is above
> or below netem corresponds to a network topology where the shaping
> occurs after or before the segment that netem is simulating,
> respectively.
> 
> If you actually replaced tfifo with TBF (as we do now), then the
> shaping always occurs after the segment simulated by netem.  That
> is, this is pretty much the same as having TBF as the parent.
> 
> BTW, the use of the CB area conflicts with the new pkt_len stuff
> so either netem or the pkt_len code needs to be fixed.
> 
> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

The problem with netem as child of TBF is that TBF counts the number
of packets in the queue to determine the rate. Therefore TBF gets confused
about the rate because of the large number of packets that are held in
netem when delaying. 

In an earlier version, I did rate control in netem but jamal thought
doing layering was better and it has worked until the redesign.
