From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] netlink: enable skb header refcounting before sending
 first broadcast
Date: Mon, 13 Jul 2015 16:10:40 +0800
Message-ID: <20150713081040.GB8971@gondor.apana.org.au>
References: <20150710115141.12980.88829.stgit@buzz>
 <20150713072352.GA8485@gondor.apana.org.au>
 <1436774742.9402.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:54651 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751370AbbGMIKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 04:10:45 -0400
Content-Disposition: inline
In-Reply-To: <1436774742.9402.3.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 13, 2015 at 10:05:42AM +0200, Eric Dumazet wrote:
>
> Herbert, UDP peek support is very buggy anyway, because of deferred
> checksums
> 
> __skb_checksum_complete() will happily manipulate csum, ip_summed,
> csum_complete_sw & csum_valid
> 
> Ideally, peek should never touch skb (but skb->users)

I think UDP should be OK because the main creator of shared skbs
is af_packet and in that cast the IP stack will clone the skb upon
entry.  AFAIK there aren't any entities doing the shared skb trick
within the IP stack.

IOW the UDP stack does not have to worry about share skbs, unlike
netlink.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
