From: Willy Tarreau <w@1wt.eu>
Subject: Re: Major network performance regression in 3.7
Date: Sun, 6 Jan 2013 17:44:16 +0100
Message-ID: <20130106164416.GF16031@1wt.eu>
References: <20130106013027.GV16031@1wt.eu> <1357436430.1678.5111.camel@edumazet-glaptop> <1357437086.1678.5135.camel@edumazet-glaptop> <1357438591.1678.5205.camel@edumazet-glaptop> <20130106025256.GY16031@1wt.eu> <1357457724.1678.5941.camel@edumazet-glaptop> <20130106092435.GZ16031@1wt.eu> <1357484342.6919.61.camel@edumazet-glaptop> <20130106155123.GB16031@1wt.eu> <1357490393.6919.267.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <erdnetdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:37699 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756056Ab3AFQoW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jan 2013 11:44:22 -0500
Content-Disposition: inline
In-Reply-To: <1357490393.6919.267.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 06, 2013 at 08:39:53AM -0800, Eric Dumazet wrote:
> Hmm, I'll have to check if this really can be reverted without hurting
> vmsplice() again.

Looking at the code I've been wondering whether we shouldn't transform
the condition to perform the push if we can't push more segments, but
I don't know what to rely on. It would be something like this :

       if (copied &&
          (!(flags & MSG_SENDPAGE_NOTLAST) || cant_push_more))
                tcp_push(sk, flags, mss_now, tp->nonagle);

Willy
