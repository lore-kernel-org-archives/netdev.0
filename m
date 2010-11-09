From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/dst: dst_dev_event() called after other notifiers
Date: Tue, 09 Nov 2010 11:48:53 -0800 (PST)
Message-ID: <20101109.114853.193732360.davem@davemloft.net>
References: <4CD893C6.2030803@candelatech.com>
	<1289331475.2774.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38294
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753289Ab0KITs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 14:48:29 -0500
In-Reply-To: <1289331475.2774.41.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 09 Nov 2010 20:37:55 +0100

> [PATCH] net/dst: dst_dev_event() called after other notifiers

Nice, applied.

However, I had to apply this by hand:

>  static struct notifier_block dst_dev_notifier = {
>  	.notifier_call  = dst_dev_event,
> +	.priority = -10, /* must be called after other network notifiers */
>  };

The character after ".notifier_call" in my tree is a TAB character but
in your patch it is a sequence of spaces.  This isn't looking like the
usual email corruption, because the leading TAB characters on these
lines are properly there.

Please figure out why this happened so that it doesn't repeat in
future patches :-)

Thanks!
