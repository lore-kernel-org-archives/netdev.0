From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net-tcp: fix panic in tcp_fastopen_cache_set()
Date: Thu, 14 Nov 2013 13:22:32 -0800
Message-ID: <1384464152.28716.35.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131113204543.GA26715@redhat.com>
	 <1384382413.28458.132.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1384383646.28458.138.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1384456418.13941.40.camel@jlt4.sipsolutions.net>
	 <1384457800.28716.30.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1384457922.28716.32.camel@edumazet-glaptop2.roam.corp.google.com>
	 (sfid-20131114_203846_741927_1B40F181) <1384462403.13941.41.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@redhat.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f44.google.com ([209.85.213.44]:58496 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757728Ab3KNVWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 16:22:38 -0500
Received: by mail-yh0-f44.google.com with SMTP id f73so1361752yha.17
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 13:22:37 -0800 (PST)
In-Reply-To: <1384462403.13941.41.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-14 at 21:53 +0100, Johannes Berg wrote:

> Heh. I have no idea, it just seemed a little odd on first look given
> that __sk_dst_get() *can* actually use RCU protection. :)

Yep, the deal is that if you own socket lock, you do not need
rcu_read_lock()

Look for dst_negative_advice() as another example :

We call __sk_dst_get(sk) without rcu_read_lock() protection.
