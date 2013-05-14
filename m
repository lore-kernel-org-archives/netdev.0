From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH] net/802/mrp: fix lockdep splat
Date: Tue, 14 May 2013 09:12:20 +0800
Message-ID: <1368493940.30953.3.camel@cr0>
References: <6901a7785249816fe13a98e3c0b35127@visp.net.lb>
	 <1368447851.13473.119.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <denys@visp.net.lb>,
	David Ward <david.ward@ll.mit.edu>,
	hayeswang <hayeswang@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3553 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752642Ab3ENBMg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 May 2013 21:12:36 -0400
In-Reply-To: <1368447851.13473.119.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-05-13 at 05:24 -0700, Eric Dumazet wrote:
>         del_timer_sync(&app->join_timer);
>  
> -       spin_lock(&app->lock);
> +       spin_lock_bh(&app->lock); 

But we just have removed the join timer before taking this spin lock, so
it is not possible to race with timer, but we still have race condition
with mrp_rcv() which is called in BH context too. However, this is not
what Denys reported, so I have no idea on this.
