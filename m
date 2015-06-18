From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] Revert "tcp: switch tcp_fastopen key generation to
 net_get_random_once"
Date: Thu, 18 Jun 2015 04:14:13 -0700
Message-ID: <1434626053.27504.206.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1434587299-60271-1-git-send-email-cpaasch@apple.com>
	 <1434619953.7926.10.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Christoph Paasch <cpaasch@apple.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:38840 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753763AbbFRLOR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 07:14:17 -0400
Received: by wibdq8 with SMTP id dq8so83380317wib.1
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2015 04:14:16 -0700 (PDT)
In-Reply-To: <1434619953.7926.10.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-06-18 at 11:32 +0200, Hannes Frederic Sowa wrote:
> Hello Christoph,

> > There does not seem to be a better way to handle this. We could try
> > to make the call to kmalloc and crypto_alloc_cipher during bootup, and
> > then generate the random value only on-the-fly (when the first TFO-SYN
> > comes in) with net_get_random_once in order to have the better entropy
> > that comes with doing the late initialisation of the random value. But
> > that's probably net-next material.
> 
> can't we simply move the net_get_random_once to the TCP_FASTOPEN setsockopt and
> sendmsg(MSG_FASTOPEN) path, so those allocations still happen in process context
> but we still defer the extraction of entropy as long as posible?

Yes, I do not think this would be hard. This bug is old (3.13) and does
not seem very urgent to expedite a revert.
