From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Change in alloc_skb() behavior in 3.2+ kernels?
Date: Wed, 06 Jun 2012 21:42:22 +0200
Message-ID: <1339011742.26966.44.camel@edumazet-glaptop>
References: <jqo7op$t6f$1@dough.gmane.org>
	 <20120606.115130.1091814494251887552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: grant.b.edwards@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:58987 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757520Ab2FFTmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 15:42:25 -0400
Received: by eeit10 with SMTP id t10so2474426eei.19
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 12:42:24 -0700 (PDT)
In-Reply-To: <20120606.115130.1091814494251887552.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-06 at 11:51 -0700, David Miller wrote:
> From: Grant Edwards <grant.b.edwards@gmail.com>
> Date: Wed, 6 Jun 2012 18:32:57 +0000 (UTC)
> 
> > The kernel module that's started failing fills the allocated sk_buff
> > until tailroom() indicates it is full and then sends it.  The problem
> > is that sending a packet with a length of 1850 won't work (it's a
> > MAC-layer Ethernet packet).
> 
> The amount of tailroom an SKB has is implementation dependent.
> 
> It's incredibly poor form to rely upon it to determine whether a fully
> sized frame has been constructed or not.
> 
> Please fix the code that does this.


By the way, we had a similar problem, and the fix was :

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commitdiff;h=a21d45726acacc963d8baddf74607d9b74e2b723

Grant, depending on the context, you might use skb->avail_size and
skb_availroom() as well.

Beware skb->avail_size is unioned with skb->{mark|dropcount}
