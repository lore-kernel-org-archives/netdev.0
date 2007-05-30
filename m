From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Wed, 30 May 2007 21:58:13 +0200
Message-ID: <465DD755.4070702@trash.net>
References: <20070530131123.10843.0@janus.isnogud.escape.de> <20070530131204.10843.5@janus.isnogud.escape.de> <465DB0B6.109@trash.net> <465DC4CD.9080801@hartkopp.net> <465DCD90.9070103@trash.net> <465DD506.4000503@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>,
	David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	netdev@vger.kernel.org
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47038 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758815AbXE3T6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 15:58:19 -0400
In-Reply-To: <465DD506.4000503@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Hartkopp wrote:
> Patrick McHardy wrote:
> 
>>skb->sk should work here as well since you detect these frames
>>before queueing to the receiving socket.
>>  
> 
> 
> Hm - this would indeed be much nicer than using skb->cb.
> 
> I think we just had some concerns to use skb->sk for our own
> functionality, as it might be used and dereferenced by other layers
> between the socket and the network driver ... so setting skb->sk to NULL
> (to indicate 'no loopback') smells bad if you don't really know who ever
> dereferences skb->sk.


Indeed, that will break things.

> Btw. it's really worth to look at it again. I just had the idea to
> access the loopback flag via skb->sk->opt->loopback (argpfl!) on the TX
> path and skb->sk on the RX path. This would avoid skb->sk to be set to
> NULL but need to have this loopback flag to be implemented in each CAN
> socket opt.


Yes, thats what I wanted to suggest. You should even be able
to use skb->sk->opt->loopback on the receive path before you
queue the packet to the socket.
