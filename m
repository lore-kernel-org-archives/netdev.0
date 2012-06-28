From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv4: tcp: dont cache unconfirmed intput dst
Date: Thu, 28 Jun 2012 07:08:22 +0200
Message-ID: <1340860102.26242.203.camel@edumazet-glaptop>
References: <20120627.153454.30398632011109264.davem@davemloft.net>
	 <20120627.164418.1928194990434756968.davem@davemloft.net>
	 <20120627.170101.99084491660488389.davem@davemloft.net>
	 <20120627.170830.811332455348620174.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hans.schillstrom@ericsson.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:45393 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123Ab2F1FI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 01:08:27 -0400
Received: by wgbdr13 with SMTP id dr13so1810103wgb.1
        for <netdev@vger.kernel.org>; Wed, 27 Jun 2012 22:08:26 -0700 (PDT)
In-Reply-To: <20120627.170830.811332455348620174.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-27 at 17:08 -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 27 Jun 2012 17:01:01 -0700 (PDT)
> 
> > There are quite a number of unwanted side effects from this change, so
> > I think we'll have to revert unless you can fix up all of the relevant
> > cases quickly.
> 
> Actually I've decided to revert it now.
> 
> Whilst this was a swell idea, there is no way for you to know if
> we should really create a cached route or not.
> 
> Even if you could, there is a lot of logic you'll need to code up
> so that, f.e., once we determine that we've got a DST_NOCACHE route
> when we move to established state, we can insert it into the routing
> cache and not mark it DST_NOCACHE any longer.
> 
> But even if we did that, we're going to eat 2 uncached route lookups
> for every new incoming legitimate connection.

The initial idea was to perform this only for SYN packets received on a
listener in SYNCOOKIE mode. I'll resend the patch when fully
implemented, instead of a forward patch.

Thanks
