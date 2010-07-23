From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: macvtap: Limit packet queue length
Date: Fri, 23 Jul 2010 09:28:08 +0200
Message-ID: <201007230928.09064.arnd@arndb.de>
References: <20100722064157.GA25913@gondor.apana.org.au> <20100722160731.GA30723@gondor.apana.org.au> <20100722.125808.232541418.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, mashirle@us.ibm.com,
	netdev@vger.kernel.org, mwagner@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:57660 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752132Ab0GWH2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 03:28:15 -0400
In-Reply-To: <20100722.125808.232541418.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 22 July 2010, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Fri, 23 Jul 2010 00:07:31 +0800
> 
> > On Thu, Jul 22, 2010 at 08:59:58AM -0700, Shirley Ma wrote:
> >> On Thu, 2010-07-22 at 14:41 +0800, Herbert Xu wrote:
> >> >  {
> >> >         struct macvtap_queue *q = macvtap_get_queue(dev, skb);
> >> >         if (!q)
> >> > -               return -ENOLINK;
> >> > +               goto drop;
> >> > +
> >> > +       if (skb_queue_len(&q->sk.sk_receive_queue) >=
> >> > dev->tx_queue_len)
> >> > +               goto drop;
> >> > 
> >> 
> >> Do we need to orphan skb here, just like tun?
> > 
> > We could, but that is orthogonal to the problem at hand so feel
> > free to do that in another patch.
> 
> These days, the stack pre-orphans all packets sent to ->ndo_start_xmit()
> in dev_hard_start_xmit() as long as socket based TX timestamping is not
> active for the packet.

But this is the receive path, not transmit, so a packet coming from an
external NIC never goes through dev_hard_start_xmit.

	Arnd
