From: David Miller <davem@davemloft.net>
Subject: Re: macvtap: Limit packet queue length
Date: Thu, 22 Jul 2010 12:58:08 -0700 (PDT)
Message-ID: <20100722.125808.232541418.davem@davemloft.net>
References: <20100722064157.GA25913@gondor.apana.org.au>
	<1279814398.3211.1.camel@localhost.localdomain>
	<20100722160731.GA30723@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mashirle@us.ibm.com, netdev@vger.kernel.org, arnd@arndb.de,
	mwagner@redhat.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35433
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751635Ab0GVT5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 15:57:52 -0400
In-Reply-To: <20100722160731.GA30723@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 23 Jul 2010 00:07:31 +0800

> On Thu, Jul 22, 2010 at 08:59:58AM -0700, Shirley Ma wrote:
>> On Thu, 2010-07-22 at 14:41 +0800, Herbert Xu wrote:
>> >  {
>> >         struct macvtap_queue *q = macvtap_get_queue(dev, skb);
>> >         if (!q)
>> > -               return -ENOLINK;
>> > +               goto drop;
>> > +
>> > +       if (skb_queue_len(&q->sk.sk_receive_queue) >=
>> > dev->tx_queue_len)
>> > +               goto drop;
>> > 
>> 
>> Do we need to orphan skb here, just like tun?
> 
> We could, but that is orthogonal to the problem at hand so feel
> free to do that in another patch.

These days, the stack pre-orphans all packets sent to ->ndo_start_xmit()
in dev_hard_start_xmit() as long as socket based TX timestamping is not
active for the packet.
