From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH 4/4] net/mlx4_en: Use atomic counter to decide when
 queue is full
Date: Mon, 25 Jun 2012 12:12:05 +0200
Message-ID: <1340619125.10893.20.camel@edumazet-glaptop>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6F61@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, yevgenyp@mellanox.co.il,
	netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:39931 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755813Ab2FYKMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 06:12:09 -0400
Received: by bkcji2 with SMTP id ji2so2948372bkc.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 03:12:08 -0700 (PDT)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6F61@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-25 at 10:00 +0100, David Laight wrote:
> > > The Transmit and transmit completion flows execute from different
> contexts,
> > > which are not synchronized. Hence naive reading the of consumer
> index might
> > > give wrong value by the time it is being used, That could lead to a
> state of transmit timeout.
> > > Fix that by using atomic variable to maintain that index.
> > > 
> > > Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> > 
> > I'm not convinced.  There is only one place that actually changes
> > the counter.
> > 
> > So it seems more like you have a missing memory barrier somewhere.
> 
> Or just keep the two ring indexes - instead of keeping the
> number of 'active' entries as well.
> Then you don't have a variable which the tx setup and
> tx completion routines both update.

This is what was implied by David.

Using a producer/consumer index and appropriate memory barriers.

start_xmit() and tx completion can be truly lockless and atomicless in
their fast path.

There are many drivers doing that correctly.

tg3 driver is a good example.
