From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] udp: ipv4: must add synchronization in
 udp_sk_rx_dst_set()
Date: Sun, 15 Dec 2013 10:30:04 -0800
Message-ID: <1387132204.19078.199.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386727643.30495.363.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1386778205.30495.374.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1386802011.19078.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131211.202212.1810247707228138095.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sbohrer@rgmadvisors.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:55493 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751717Ab3LOSaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 13:30:07 -0500
Received: by mail-pb0-f50.google.com with SMTP id rr13so4537854pbb.23
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 10:30:06 -0800 (PST)
In-Reply-To: <20131211.202212.1810247707228138095.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-12-11 at 20:22 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 11 Dec 2013 14:46:51 -0800
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Unlike TCP, UDP input path does not hold the socket lock.
> > 
> > Before messing with sk->sk_rx_dst, we must use a spinlock, otherwise
> > multiple cpus could leak a refcount.
> > 
> > This patch also takes care of renewing a stale dst entry.
> > (When the sk->sk_rx_dst would not be used by IP early demux)
> > 
> > Fixes: 421b3885bf6d ("udp: ipv4: Add udp early demux")
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Applied.
> 
> Longterm, perhaps a candidate for using xchg() instead of this
> spinlock?

Indeed... It appears sk_dst_lock should not be used from BH context
anyway...

I am sending a fix, thanks.
