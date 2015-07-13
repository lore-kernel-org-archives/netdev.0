From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netlink: enable skb header refcounting before sending
 first broadcast
Date: Mon, 13 Jul 2015 10:22:34 +0200
Message-ID: <1436775754.9402.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150710115141.12980.88829.stgit@buzz>
	 <20150713072352.GA8485@gondor.apana.org.au>
	 <1436774742.9402.3.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150713081040.GB8971@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:37446 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900AbbGMIWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 04:22:38 -0400
Received: by wicmz13 with SMTP id mz13so54765842wic.0
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 01:22:37 -0700 (PDT)
In-Reply-To: <20150713081040.GB8971@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-07-13 at 16:10 +0800, Herbert Xu wrote:
> On Mon, Jul 13, 2015 at 10:05:42AM +0200, Eric Dumazet wrote:
> >
> > Herbert, UDP peek support is very buggy anyway, because of deferred
> > checksums
> > 
> > __skb_checksum_complete() will happily manipulate csum, ip_summed,
> > csum_complete_sw & csum_valid
> > 
> > Ideally, peek should never touch skb (but skb->users)
> 
> I think UDP should be OK because the main creator of shared skbs
> is af_packet and in that cast the IP stack will clone the skb upon
> entry.  AFAIK there aren't any entities doing the shared skb trick
> within the IP stack.
> 
> IOW the UDP stack does not have to worry about share skbs, unlike
> netlink.

It should worry, in case multiple threads are using MSG_PEEK on same udp
socket ;)

Problem here is not the producer (might be unicast packets btw),
but multiple 'consumers'

It turns out your patch would also solve this problem.
