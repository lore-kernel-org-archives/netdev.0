From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] ipv6: Don't depend on per socket memory for neighbour discovery messages
Date: Wed, 4 Sep 2013 00:43:48 +0200
Message-ID: <20130903224348.GA31185@order.stressinduktion.org>
References: <e4600dac657e1160da7a5e7758dcb973b616a10e.1378207925.git.tgraf@suug.ch> <52261A12.3060203@wwwdotorg.org> <20130903172736.GB21729@order.stressinduktion.org> <52261F68.70907@wwwdotorg.org> <1378230697.7360.38.camel@edumazet-glaptop> <52262462.80308@wwwdotorg.org> <20130903182348.GB4166@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Stephen Warren <swarren@wwwdotorg.org>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Fabio Estevam <festevam@gmail.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35699 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754315Ab3ICWnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 18:43:49 -0400
Content-Disposition: inline
In-Reply-To: <20130903182348.GB4166@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 03, 2013 at 07:23:48PM +0100, Thomas Graf wrote:
> I'm confused why lockdep would only trigger after my patch, the
> deadlock is unrelated.

Either we had patch caf92bc ("ipv6: do not call ndisc_send_rs() with write
lock") already applied or both our testing was flawed. I reverted caf92bc and
tested v1 again and could also reproduce this problem.

Because of the sk_mc_loop logic I do think it is better to set skb->sk, so:

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

If this should still go to stable, the above mentioned commit should also hit
the queue.

Greetings,

  Hannes
