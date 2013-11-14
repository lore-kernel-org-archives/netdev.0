From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net-tcp: fix panic in tcp_fastopen_cache_set()
Date: Thu, 14 Nov 2013 20:13:38 +0100
Message-ID: <1384456418.13941.40.camel@jlt4.sipsolutions.net>
References: <20131113204543.GA26715@redhat.com>
	 <1384382413.28458.132.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1384383646.28458.138.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@redhat.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:50026 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755391Ab3KNTNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 14:13:49 -0500
In-Reply-To: <1384383646.28458.138.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-13 at 15:00 -0800, Eric Dumazet wrote:

> --- a/net/ipv4/tcp_metrics.c
> +++ b/net/ipv4/tcp_metrics.c
> @@ -663,10 +663,13 @@ void tcp_fastopen_cache_get(struct sock *sk, u16 *mss,
>  void tcp_fastopen_cache_set(struct sock *sk, u16 mss,
>  			    struct tcp_fastopen_cookie *cookie, bool syn_lost)
>  {
> +	struct dst_entry *dst = __sk_dst_get(sk);
>  	struct tcp_metrics_block *tm;
>  
> +	if (!dst)
> +		return;
>  	rcu_read_lock();
> -	tm = tcp_get_metrics(sk, __sk_dst_get(sk), true);

Doesn't that __sk_dst_get() have to go inside the rcu_read_lock()?

Then again, I guess we hold the socket. Still looks a bit weird to be
moving it out.

johannes
