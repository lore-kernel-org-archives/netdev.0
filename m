From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: time stamps of skb packets in NF_HOOKS callbacks
Date: Fri, 18 Aug 2006 10:58:33 +0400
Message-ID: <20060818065832.GA23264@2ka.mipt.ru>
References: <ada605fb0608170737m4c0096c4u33a70dcf37e09df8@mail.gmail.com> <20060817155835.GA11898@2ka.mipt.ru> <ada605fb0608172243raeff154q728bdd026b5b1d31@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:9644 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750754AbWHRHAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2006 03:00:37 -0400
Received: from 2ka.mipt.ru (localhost [127.0.0.1])
	by 2ka.mipt.ru (8.13.7/8.13.7) with ESMTP id k7I70U5M027824
	for <netdev@vger.kernel.org>; Fri, 18 Aug 2006 11:00:30 +0400
To: John Que <qwejohn@gmail.com>
Content-Disposition: inline
In-Reply-To: <ada605fb0608172243raeff154q728bdd026b5b1d31@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 18, 2006 at 08:43:08AM +0300, John Que (qwejohn@gmail.com) wrote:
> Following your answer I tried adding a call to net_enable_timestamp() in
> a module I wrote which use NF_HOOKS.
> This is what is done , for example, in ipq_rcv_skb(struct sk_buff *skb)
> in linux-2.6.14 in net/ipv4/netfilter/ip_queue.c.
> 
> After doing so I get timestamps which are not 0.
> 
> what I wonder now is :
> 1) does this have ANY performance implication (when dealing with a
> high  network  load which can get to 50,000 packets per second?

Yes, it has. do_gettimeofday() is quite slow on some processors and is
not SMP-friendly.

> 2) It does work as I said, but I want to be cautios: Am I permitted to
> add this method ? are  there any  implications for adding this method
> which can create troubles ?
> I must say that I am NOT changing anywhere the timestamp; it's only
> for statistics.

If you add ata least on socket with SO_TIMESTAMP option, it will enable
timestamps for all skbs, so you have not created any wrong thing, except
that slowed down your network processing.

> Regards,
> John

-- 
	Evgeniy Polyakov
