From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net-tcp: fix panic in tcp_fastopen_cache_set()
Date: Thu, 14 Nov 2013 11:38:42 -0800
Message-ID: <1384457922.28716.32.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131113204543.GA26715@redhat.com>
	 <1384382413.28458.132.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1384383646.28458.138.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1384456418.13941.40.camel@jlt4.sipsolutions.net>
	 <1384457800.28716.30.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@redhat.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f43.google.com ([209.85.213.43]:54035 "EHLO
	mail-yh0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754832Ab3KNTip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 14:38:45 -0500
Received: by mail-yh0-f43.google.com with SMTP id v1so1275595yhn.16
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 11:38:44 -0800 (PST)
In-Reply-To: <1384457800.28716.30.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-14 at 11:36 -0800, Eric Dumazet wrote:
> On Thu, 2013-11-14 at 20:13 +0100, Johannes Berg wrote:
> > On Wed, 2013-11-13 at 15:00 -0800, Eric Dumazet wrote:
> > 
> > > --- a/net/ipv4/tcp_metrics.c
> > > +++ b/net/ipv4/tcp_metrics.c
> > > @@ -663,10 +663,13 @@ void tcp_fastopen_cache_get(struct sock *sk, u16 *mss,
> > >  void tcp_fastopen_cache_set(struct sock *sk, u16 mss,
> > >  			    struct tcp_fastopen_cookie *cookie, bool syn_lost)
> > >  {
> > > +	struct dst_entry *dst = __sk_dst_get(sk);
> > >  	struct tcp_metrics_block *tm;
> > >  
> > > +	if (!dst)
> > > +		return;
> > >  	rcu_read_lock();
> > > -	tm = tcp_get_metrics(sk, __sk_dst_get(sk), true);
> > 
> > Doesn't that __sk_dst_get() have to go inside the rcu_read_lock()?
> > 
> > Then again, I guess we hold the socket. Still looks a bit weird to be
> > moving it out.
> 
> Yep, in fact this rcu_read_lock() is not needed. I'll send a v2.

I take it back.

the rcu_read_lock() protects the tcp_get_metrics(), not the
__sk_dst_get(sk)

So the patch is correct, unless you disagree of course ;)
