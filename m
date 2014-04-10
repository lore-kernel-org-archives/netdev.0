From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/2] macvlan: Move broadcasts into a work queue
Date: Thu, 10 Apr 2014 14:50:52 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6F47CA@AcuExch.aculab.com>
References: <20140407075347.GA26461@gondor.apana.org.au>
 <E1WX4P2-0006wA-9Q@gondolin.me.apana.org.au>
 <20140408095523.2d4e14bd@nehalam.linuxnetplumber.net>
 <20140409085001.GA12938@gondor.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D0F6F2E17@AcuExch.aculab.com>
 <20140410125902.GA25069@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Herbert Xu' <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:42252 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S933057AbaDJOwi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 10:52:38 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 09229-03 for <netdev@vger.kernel.org>;
 Thu, 10 Apr 2014 15:52:27 +0100 (BST)
In-Reply-To: <20140410125902.GA25069@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu
> On Wed, Apr 09, 2014 at 10:10:16AM +0000, David Laight wrote:
> > From: Herbert Xu
> > ...
> > > This patch picks the second option and moves all broadcast handling
> > > bar the trivial case of packets going to a single interface into
> > > a work queue.  Obviously there also needs to be a limit on how
> > > many broadcast packets we postpone in this way.  I've arbitrarily
> > > chosen tx_queue_len of the master device as the limit (act_mirred
> > > also happens to use this parameter in a similar way).
> > >
> > > In order to ensure we don't exceed the backlog queue we will use
> > > netif_rx_ni instead of netif_rx for broadcast packets.
> >
> > Should you limit the number of broadcasts queued for transmit
> > on each interface as well as the number of postponed broadcasts.
> >
> > It probably isn't a good idea to completely fill an interface's
> > transmit queue with broadcasts.
> 
> These are *received* packets so I don't see how they're going
> to fill up the transmit queues.

I was thinking of a bridge - where the packets get transmitted.
In this case they get put on the interfaces receive queue,
but the same thing applies.
Maybe there isn't actually a queue at that point?

	David
