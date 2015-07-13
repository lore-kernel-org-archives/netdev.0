From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netlink: enable skb header refcounting before sending
 first broadcast
Date: Mon, 13 Jul 2015 10:05:42 +0200
Message-ID: <1436774742.9402.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150710115141.12980.88829.stgit@buzz>
	 <20150713072352.GA8485@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:35210 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292AbbGMIFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 04:05:47 -0400
Received: by wiga1 with SMTP id a1so61487952wig.0
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 01:05:46 -0700 (PDT)
In-Reply-To: <20150713072352.GA8485@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-07-13 at 15:23 +0800, Herbert Xu wrote:

> The real issue here is that the recv path no longer handles shared
> skbs.  So either we need to fix the recv path to not touch skbs
> without cloning them, or we need to get rid of the use of shared
> skbs in netlink.
> 
> In fact it looks I introduced the bug way back in
> 
> commit a59322be07c964e916d15be3df473fb7ba20c41e
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Wed Dec 5 01:53:40 2007 -0800
> 
>     [UDP]: Only increment counter on first peek/recv
> 
> I will try to mend this error :)
> 
> Cheers,

Herbert, UDP peek support is very buggy anyway, because of deferred
checksums

__skb_checksum_complete() will happily manipulate csum, ip_summed,
csum_complete_sw & csum_valid

Ideally, peek should never touch skb (but skb->users)
