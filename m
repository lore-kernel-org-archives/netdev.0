From: "Edgar E. Iglesias" <edgar.iglesias@axis.com>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Mon, 7 Aug 2006 17:21:26 +0200
Message-ID: <20060807152126.GL24653@edgar.underground.se.axis.com>
References: <1154797002.5081.21.camel@jzny2> <20060805230517.GA25468@gondor.apana.org.au> <1154819868.5517.34.camel@jzny2> <20060805231959.GA25768@gondor.apana.org.au> <1154821010.5517.48.camel@jzny2> <20060806025123.GA27051@gondor.apana.org.au> <1154867083.6269.35.camel@jzny2> <1154867589.6269.40.camel@jzny2> <4807377b0608061616p5731524fvb0612bdbc32e59b@mail.gmail.com> <1154955036.5246.32.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com,
	"Edgar E. Iglesias" <edgar.iglesias@axis.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from miranda.se.axis.com ([193.13.178.8]:40841 "EHLO
	miranda.se.axis.com") by vger.kernel.org with ESMTP id S932149AbWHGPV3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 11:21:29 -0400
Received: from axis.com (edgar.se.axis.com [10.92.151.1])
	by miranda.se.axis.com (8.12.9/8.12.9/Debian-5local0.1) with ESMTP id k77FLQP0028101
	for <netdev@vger.kernel.org>; Mon, 7 Aug 2006 17:21:27 +0200
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1154955036.5246.32.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 07, 2006 at 08:50:36AM -0400, jamal wrote:
> On Sun, 2006-06-08 at 16:16 -0700, Jesse Brandeburg wrote:
> [..]
> > 
> > As for specifics, for TX_WAKE_THRESHOLD, i noticed that we were
> > starting the queue after every packet was cleaned, so when the ring
> > went full there was a lot of queue thrash.
> 
> indeed this is what used to happen and was bad.... So this is a huge
> improvement.
> What happens now under steady state at high traffic transmits is,
> instead of 1, you see E1000_TX_WEIGHT in between queue sleep/wakes. I
> assume this is a given since E1000_TX_WEIGHT is higher than
> TX_WAKE_THRESHOLD.  I am not sure if i can vouch for even more
> improvement by mucking around with values of E1000_TX_WEIGHT.
> 
> Can you please take a look at the patch i posted? I would like to submit
> that for inclusion. It does two things
> a) make pruning available to be invoked from elsewhere (I tried to do it
> from the tx path but it gave me non-good results)
> b) makes E1000_TX_WEIGHT and TX_WAKE_THRESHOLD relative to the size
> of the transmit ring. I think this is a sane thing to do.
> 

Hi Jamal,

I have a question regarding your patch. In clean_tx_irq, it seems you dont
clean the ring unless fdesc < tx_ring->prunet. Won't this cause deadlocks for
local TCP connections if transmit goes quiet?

It seems to me as if this patch depends on the skb orphaning previously 
suggested on this thread. Please correct me if I'm wrong.

Best regards
-- 
        Programmer
        Edgar E. Iglesias <edgar.iglesias@axis.com> 46.46.272.1946
