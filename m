From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] inet: tcp listener refactoring, part 13
Date: Wed, 18 Mar 2015 22:01:08 -0400 (EDT)
Message-ID: <20150318.220108.729418866702247151.davem@davemloft.net>
References: <1426712738-23395-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41124 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbbCSCBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 22:01:12 -0400
In-Reply-To: <1426712738-23395-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Wed, 18 Mar 2015 14:05:32 -0700

> inet_hash functions are in a bad state : Too much IPv6/IPv4 copy/pasting.
> 
> Lets refactor a bit.
> 
> Idea is that we do not want to have an equivalent of inet_csk(sk)->icsk_af_ops
> for request socks in order to be able to use the right variant.
> 
> In this patch series, I started to let IPv6/IPv4 converge to common helpers.
> 
> Idea is to use ipv6_addr_set_v4mapped() even for AF_INET sockets, so that
> we can test
>        if (sk->sk_family == AF_INET6 &&
>            !ipv6_addr_v4mapped(&sk->sk_v6_daddr))
> to tell if we deal with an IPv6 socket, or IPv4 one, at least in slow paths.
> 
> Ideally, we could save 8 bytes per struct sock_common, if we
> alias skc_daddr & skc_rcv_saddr to skc_v6_daddr[3]/skc_v6_rcv_saddr[3].

Looks good, applied, thanks Eric.
