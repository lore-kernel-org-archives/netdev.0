From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: shrink tcp6_timewait_sock by one cache
 line
Date: Thu, 03 Oct 2013 12:47:22 -0700
Message-ID: <1380829642.19002.225.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380711604.19002.78.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131003.153158.1558578931500427624.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:37732 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754743Ab3JCTrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 15:47:24 -0400
Received: by mail-pb0-f44.google.com with SMTP id xa7so2928842pbc.17
        for <netdev@vger.kernel.org>; Thu, 03 Oct 2013 12:47:23 -0700 (PDT)
In-Reply-To: <20131003.153158.1558578931500427624.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-03 at 15:31 -0400, David Miller wrote:

> Eric just use tcp_time_stamp in all of these locations, then you can
> lose the casts and still achieve your stated objective.

I thought about this, but this would break if tcp_time_stamp was no
longer tied to jiffies.

Van Jacobson had the idea of using finer resolution tcp_time_stamp for
TCP flows in data centers, for better RTT estimation and and cwin
control, but also for better diagnostics.

Note we used this (u32)jiffies thing in net/ipv4/inetpeer.c in the past,
and tp->tso_deferred is also a u32 value.
