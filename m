From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: remove redundant checking for sock timer state
Date: Thu, 31 Jan 2013 22:26:43 -0800
Message-ID: <1359700003.30177.32.camel@edumazet-glaptop>
References: <1359697980-28613-1-git-send-email-ying.xue@windriver.com>
	 <20130201.010946.584437309593473452.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ying.xue@windriver.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f41.google.com ([209.85.210.41]:38806 "EHLO
	mail-da0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752121Ab3BAG0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 01:26:47 -0500
Received: by mail-da0-f41.google.com with SMTP id e20so1622682dak.0
        for <netdev@vger.kernel.org>; Thu, 31 Jan 2013 22:26:47 -0800 (PST)
In-Reply-To: <20130201.010946.584437309593473452.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-01 at 01:09 -0500, David Miller wrote:
> From: Ying Xue <ying.xue@windriver.com>
> Date: Fri, 1 Feb 2013 13:53:00 +0800
> 
> > It's unnecessary to check whether the sock timer to be stopped is
> > pending or not in sk_stop_timer() as del_timer() will do the same
> > thing later.
> > 
> > Signed-off-by: Ying Xue <ying.xue@windriver.com>
> 
> Did it even occur to you that when this code was written, this
> "redundant" testing was also redundant, but that it might have been
> done on purpose?
> 
> If you are going to change this code, you must understand why it was
> written this way, because that is the only context in which you will
> be able to justify removing the test.
> 

I had the same reaction but maybe its not anymore a valid thing.

Before commit 55c888d6d ([PATCH] timers fixes/improvements) there was
indeed a significant cost calling del_timer() because of unconditional
spinlock acquisition.

But nowadays del_timer() doesn't blindly lock the spinlock.

So I guess we could change all occurrences of :

if (timer_pending(X))
    del_timer(X);

It would save some bytes of code.

But please Ying, do a complete patch for net tree, don't send 30
patches.
