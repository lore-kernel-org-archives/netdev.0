From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH 3/3] [PPP] L2TP: Fix skb handling in pppol2tp_xmit
Date: Tue, 18 Sep 2007 21:19:33 +0100
Message-ID: <46F032D5.7020806@katalix.com>
References: <20070918120438.GA9121@gondor.apana.org.au> <E1IXbqs-0002Od-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Michal Ostrowski <mostrows@speakeasy.net>,
	Paul Mackerras <paulus@samba.org>,
	=?ISO-8859-1?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:51266 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751755AbXIRUTs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2007 16:19:48 -0400
In-Reply-To: <E1IXbqs-0002Od-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
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

This one causes my test system to lock up. I'll investigate. Please 
don't apply this patch for now.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

