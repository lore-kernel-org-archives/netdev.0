From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 10/16] Don't lookup the socket if there's a
 socket attached to the skb
Date: Wed, 01 Oct 2008 08:51:04 -0700 (PDT)
Message-ID: <20081001.085104.193726318.davem@davemloft.net>
References: <20081001142431.4893.69772.stgit@este>
	<20081001.075040.135314845.davem@davemloft.net>
	<1222875500.7492.6.camel@este>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: hidden@sch.bme.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54250
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751850AbYJAPvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 11:51:15 -0400
In-Reply-To: <1222875500.7492.6.camel@este>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: KOVACS Krisztian <hidden@sch.bme.hu>
Date: Wed, 01 Oct 2008 17:38:20 +0200

> The problem is that if you include the if() test then you have to
> include the lookup call as well and that's different for TCP/UDP.

No, I only mean to make a helper for this construct:

	if (unlikely(skb->sk)) {
		...
	}

so, something like:

static inline struct sock *sock_skb_steal(struct sk_buff *skb)
{
	if (unlikely(skb->sk)) {
		struct sock *sk = skb->sk;

		skb->destructor = NULL;
		skb->sk = NULL;
		return sk;
	}
	return NULL;
}

and then also get rid of the ifdefs at the place where
these calls are made (TCP and UDP).
