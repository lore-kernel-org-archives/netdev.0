From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/802/mrp: fix lockdep splat
Date: Tue, 14 May 2013 12:21:47 -0700
Message-ID: <1368559307.4519.21.camel@edumazet-glaptop>
References: <6901a7785249816fe13a98e3c0b35127@visp.net.lb>
	 <1368447851.13473.119.camel@edumazet-glaptop>
	 <16b0a5ee4602cb9005dd67ea7ad0d4e8@visp.net.lb>
	 <20130514.120754.1745967383330029903.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, amwang@redhat.com, david.ward@ll.mit.edu,
	hayeswang@realtek.com, romieu@fr.zoreil.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:47173 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755446Ab3ENTVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 May 2013 15:21:50 -0400
Received: by mail-pb0-f52.google.com with SMTP id xa7so687687pbc.25
        for <netdev@vger.kernel.org>; Tue, 14 May 2013 12:21:49 -0700 (PDT)
In-Reply-To: <20130514.120754.1745967383330029903.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-14 at 12:07 -0700, David Miller wrote:

> Can you double check that you really had Eric's patch applied?
> lockdep appears to be complaining about the same thing in your
> log dump, as if the patch was not really applied.
> 
> It's saying that app->lock can be taken from the join timer in
> softirq, but mrp_uninit_applicant() takes it without disabling
> softirqs.
> 
> Eric's patch explicitly fixes this, by making sure that spin_lock_bh()
> is used there.

I am going to test this myself, it seems quite simple.
I'll add a Tested-by: tag once done.

Thanks
