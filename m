From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] [PPP] L2TP: Fix skb handling in pppol2tp_xmit
Date: Wed, 19 Sep 2007 10:47:03 -0700 (PDT)
Message-ID: <20070919.104703.97292447.davem@davemloft.net>
References: <E1IXbqs-0002Od-00@gondolin.me.apana.org.au>
	<46F032D5.7020806@katalix.com>
	<20070919012529.GA15046@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, mostrows@speakeasy.net, paulus@samba.org,
	toralf.foerster@gmx.de, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45137
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751330AbXISRrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 13:47:03 -0400
In-Reply-To: <20070919012529.GA15046@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 19 Sep 2007 09:25:29 +0800

> [PPP] L2TP: Fix skb handling in pppol2tp_xmit
> 
> This patch makes pppol2tp_xmit call skb_cow_head so that we don't modify
> cloned skb data.  It also gets rid of skb2 we only need to preserve the
> original skb for congestion notification, which is only applicable for
> ppp_async and ppp_sync.
> 
> The other semantic change made here is the removal of socket accounting
> for data tranmitted out of pppol2tp_xmit.  The original code leaked any
> existing socket skb accounting.  We could fix this by dropping the
> original skb owner.  However, this is undesirable as the packet has not
> physically left the host yet.
> 
> In fact, all other tunnels in the kernel do not account skb's passing
> through to their own socket.  In partciular, ESP over UDP does not do
> so and it is the closest tunnel type to PPPoL2TP.  So this patch simply
> removes the socket accounting in pppol2tp_xmit.  The accounting still
> applies to control packets of course.
> 
> I've also added a reminder that the outgoing checksum here doesn't work.
> I suppose existing deployments don't actually enable checksums.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I've replaced the older patch with the leak with this one,
thanks Herbert.
