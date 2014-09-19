From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] macvlan: allow to enqueue broadcast pkt on virtual
 device
Date: Fri, 19 Sep 2014 16:44:31 -0700
Message-ID: <1411170271.26859.67.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1410941288-1880-1-git-send-email-nicolas.dichtel@6wind.com>
	 <20140919.160351.1490731758266834534.davem@davemloft.net>
	 <20140919233108.GA31226@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, nicolas.dichtel@6wind.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:63139 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753883AbaISXod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 19:44:33 -0400
Received: by mail-pa0-f54.google.com with SMTP id fb1so1029695pad.41
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 16:44:33 -0700 (PDT)
In-Reply-To: <20140919233108.GA31226@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-09-20 at 07:31 +0800, Herbert Xu wrote:

> While it would be nice to maintain the ability to chnge this
> parameter, I'm fine with this patch as it stands since it fixes
> a real regression.
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Another interesting feature would be to be able to time limit the queue,
and/or use a head drop instead of tail drop.

(ie timestamp skb when its enqueued into bc_queue,
 and at dequeue time, drop it if elapsed time is above a configurable
limit)

Processing a broadcast one minute after it was really sent makes little
sense, especially if we drop new incoming broadcasts because bc_queue is
full.
