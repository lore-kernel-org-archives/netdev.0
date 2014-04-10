From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] macvlan: Move broadcasts into a work queue
Date: Thu, 10 Apr 2014 20:59:02 +0800
Message-ID: <20140410125902.GA25069@gondor.apana.org.au>
References: <20140407075347.GA26461@gondor.apana.org.au>
 <E1WX4P2-0006wA-9Q@gondolin.me.apana.org.au>
 <20140408095523.2d4e14bd@nehalam.linuxnetplumber.net>
 <20140409085001.GA12938@gondor.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D0F6F2E17@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:59111 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965638AbaDJOlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 10:41:06 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6F2E17@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 09, 2014 at 10:10:16AM +0000, David Laight wrote:
> From: Herbert Xu
> ...
> > This patch picks the second option and moves all broadcast handling
> > bar the trivial case of packets going to a single interface into
> > a work queue.  Obviously there also needs to be a limit on how
> > many broadcast packets we postpone in this way.  I've arbitrarily
> > chosen tx_queue_len of the master device as the limit (act_mirred
> > also happens to use this parameter in a similar way).
> > 
> > In order to ensure we don't exceed the backlog queue we will use
> > netif_rx_ni instead of netif_rx for broadcast packets.
> 
> Should you limit the number of broadcasts queued for transmit
> on each interface as well as the number of postponed broadcasts.
> 
> It probably isn't a good idea to completely fill an interface's
> transmit queue with broadcasts.

These are *received* packets so I don't see how they're going
to fill up the transmit queues.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
