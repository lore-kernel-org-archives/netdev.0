From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next 0/2] netfilter: IPv4/v6 IPcomp match support
Date: Tue, 24 Dec 2013 19:16:14 +0100
Message-ID: <20131224181614.GA26270@localhost>
References: <1386937082-30412-1-git-send-email-fan.du@windriver.com>
 <20131217130555.GA8874@localhost>
 <52B26841.40800@windriver.com>
 <20131220090419.GA5661@localhost>
 <52B40C01.7070406@windriver.com>
 <20131223121337.GA5373@localhost>
 <52B9278D.4020905@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, steffen.klassert@secunet.com,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54602 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752241Ab3LXSQV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Dec 2013 13:16:21 -0500
Content-Disposition: inline
In-Reply-To: <52B9278D.4020905@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 24, 2013 at 02:19:57PM +0800, Fan Du wrote:
> For a packet encapsulated in order of ah->esp->ah->original packet, as you said
> par->thoff is set at esp, that's why netfilter esp has a unified implementation
> in net/netfilter/xt_esp.c, because it's always the last parse header netfilter
> can reach.
> 
> The same rule apply with IPcomp, for example,
> (1) ah->ipcomp->original packet
>          ^par->thoff
> (2) ipcomp->ah->original packet
>       ^par->thoff
> 
> Both cases (1) and (2) par->thoff can only point into IPcomp header, so in such
> circumstance, a unified implementation for both IPv4/6 is feasible, and I have
> tested (2) in such implementation, it works anyway.
> 
> IMO, a unified implementation suggested by you previous is ok for this round review.

Your right, I forgot the fact that ipcomp "hides" what it
encapsulates, so it's basically the last header we can see.
