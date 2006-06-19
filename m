From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET]: Prevent multiple qdisc runs
Date: Mon, 19 Jun 2006 23:42:27 +1000
Message-ID: <20060619134227.GA16662@gondor.apana.org.au>
References: <20060619121519.GA16031@gondor.apana.org.au> <1150724031.5815.39.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:517 "EHLO arnor.apana.org.au")
	by vger.kernel.org with ESMTP id S932446AbWFSNme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2006 09:42:34 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1150724031.5815.39.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jamal:

On Mon, Jun 19, 2006 at 09:33:51AM -0400, jamal wrote:
> 
> I take it you saw a lot of requeues happening that prompted this? What
> were the circumstances? The _only_ times i have seen it happen is when
> the (PCI) bus couldnt handle the incoming rate or there was a bug in the
> driver. 

Actually I discovered the problem only because the generic segmentation
offload stuff that I'm working on needs to deal with the situation where
a super-packet is partially transmitted.  Requeueing causes all sorts of
nasty problems so I chose to keep it within the net_device structure.

To do so requires qdisc_run to be serialised against each other.  I then
found out that we want this anyway because otherwise the requeued packets
could be reordered.

> Also: what happens to the packet that comes in from either local or is
> being forwarded and finds the qdisc_is_running flag is set? I couldnt
> tell if the intent was to drop it or not. The answer for TCP is probably
> simpler than for packets being forwarded.

The qdisc_is_running only prevents qdisc_run from occuring (because it's
already running), it does not impact on the queueing of the packet.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
