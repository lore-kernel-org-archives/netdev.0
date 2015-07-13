From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] netlink: enable skb header refcounting before sending
 first broadcast
Date: Mon, 13 Jul 2015 17:04:40 +0800
Message-ID: <20150713090440.GA9468@gondor.apana.org.au>
References: <20150710115141.12980.88829.stgit@buzz>
 <20150713072352.GA8485@gondor.apana.org.au>
 <55A37CD7.9050104@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:53223 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487AbbGMJEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 05:04:45 -0400
Content-Disposition: inline
In-Reply-To: <55A37CD7.9050104@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 13, 2015 at 11:54:47AM +0300, Konstantin Khlebnikov wrote:
> 
> I don't think that recv path should care about shared skb -- skb can be
> delivered into only one socket anyway.

The fact is that this is how the original code worked and was
expected to do.  The broadcast side would generate a shared skb
and the recv side is supposed to only read it, not modify it.

In fact apart from the skb->peeked bug netlink_recvmsg does all
the right things and never modifies skb.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
