From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net-tcp: fix panic in tcp_fastopen_cache_set()
Date: Thu, 14 Nov 2013 21:53:23 +0100
Message-ID: <1384462403.13941.41.camel@jlt4.sipsolutions.net>
References: <20131113204543.GA26715@redhat.com>
	 <1384382413.28458.132.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1384383646.28458.138.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1384456418.13941.40.camel@jlt4.sipsolutions.net>
	 <1384457800.28716.30.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1384457922.28716.32.camel@edumazet-glaptop2.roam.corp.google.com>
	 (sfid-20131114_203846_741927_1B40F181)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@redhat.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:50327 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755166Ab3KNUxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 15:53:35 -0500
In-Reply-To: <1384457922.28716.32.camel@edumazet-glaptop2.roam.corp.google.com> (sfid-20131114_203846_741927_1B40F181)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-14 at 11:38 -0800, Eric Dumazet wrote:

> > > Doesn't that __sk_dst_get() have to go inside the rcu_read_lock()?
> > > 
> > > Then again, I guess we hold the socket. Still looks a bit weird to be
> > > moving it out.
> > 
> > Yep, in fact this rcu_read_lock() is not needed. I'll send a v2.
> 
> I take it back.
> 
> the rcu_read_lock() protects the tcp_get_metrics(), not the
> __sk_dst_get(sk)
> 
> So the patch is correct, unless you disagree of course ;)

Heh. I have no idea, it just seemed a little odd on first look given
that __sk_dst_get() *can* actually use RCU protection. :)

johannes
