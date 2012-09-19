From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Wed, 19 Sep 2012 17:14:19 +0200
Message-ID: <1348067659.26523.949.camel@edumazet-glaptop>
References: <20120917.121243.1665284878800146060.davem@davemloft.net>
	 <1347901326.26523.149.camel@edumazet-glaptop>
	 <1347901493.26523.151.camel@edumazet-glaptop>
	 <20120917.130732.1894375657044880827.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:54174 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755363Ab2ISPOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 11:14:24 -0400
Received: by bkwj10 with SMTP id j10so591713bkw.19
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2012 08:14:23 -0700 (PDT)
In-Reply-To: <20120917.130732.1894375657044880827.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-17 at 13:07 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 17 Sep 2012 19:04:53 +0200
> 
> > On Mon, 2012-09-17 at 19:02 +0200, Eric Dumazet wrote:
> > 
> >> A driver already exports a dev->gso_max_size, dev->gso_max_segs, I guess
> >> it could export a dev->max_seg_order (default to 0)
> > 
> > Oh well, if we use a per thread order-3 page, a driver wont define an
> > order, but the max size of a segment (dev->max_seg_size).
> 
> Since you said that your audit showed that most can handle arbitrary
> segment sizes, it's better to default to infinity or similar.
> 
> Otherwise we'll have to annotate almost every single driver with a
> non-zero value, that's not an efficient way to handle this and
> deploy the higher performance quickly.

I did some tests and got no problem so far, even using splice() [ this
one was tricky because it only deals with order-0 pages at this moment ]

NIC tested : ixgbe, igb, bnx2x, tg3, mellanox mlx4

On loopback, performance of netperf goes from 31900 Mb/s to 38500 Mb/s,
thats a 20 % increase.
