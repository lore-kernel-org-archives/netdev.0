From: Christoph Paasch <cpaasch@apple.com>
Subject: Re: [PATCH net] Revert
 "tcp: switch tcp_fastopen key generation to net_get_random_once"
Date: Thu, 18 Jun 2015 08:45:29 -0700
Message-ID: <20150618154529.GG33243@Chimay.local>
References: <1434587299-60271-1-git-send-email-cpaasch@apple.com>
 <1434619953.7926.10.camel@stressinduktion.org>
 <1434626053.27504.206.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out4.apple.com ([17.151.62.26]:43802 "EHLO
	mail-in4.apple.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751937AbbFRPpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 11:45:31 -0400
Received: from localhost ([17.149.226.91])
 by chicory.apple.com (Oracle Communications Messaging Server 7.0.5.30.0 64bit
 (built Oct 22 2013)) with ESMTPSA id <0NQ500NFQD3U1U40@chicory.apple.com> for
 netdev@vger.kernel.org; Thu, 18 Jun 2015 08:45:30 -0700 (PDT)
Content-disposition: inline
In-reply-to: <1434626053.27504.206.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/06/15 - 04:14:13, Eric Dumazet wrote:
> On Thu, 2015-06-18 at 11:32 +0200, Hannes Frederic Sowa wrote:
> > > There does not seem to be a better way to handle this. We could try
> > > to make the call to kmalloc and crypto_alloc_cipher during bootup, and
> > > then generate the random value only on-the-fly (when the first TFO-SYN
> > > comes in) with net_get_random_once in order to have the better entropy
> > > that comes with doing the late initialisation of the random value. But
> > > that's probably net-next material.
> > 
> > can't we simply move the net_get_random_once to the TCP_FASTOPEN setsockopt and
> > sendmsg(MSG_FASTOPEN) path, so those allocations still happen in process context
> > but we still defer the extraction of entropy as long as posible?
> 
> Yes, I do not think this would be hard. This bug is old (3.13) and does
> not seem very urgent to expedite a revert.

True, it would be simpler to call tcp_fastopen_init_key_once to the
setsocketopt() and inet_listen().

I will resubmit.


Christoph
