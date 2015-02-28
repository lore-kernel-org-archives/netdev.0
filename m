From: John Heffner <johnwheffner@gmail.com>
Subject: Re: [PATCHv3 net-next 3/4] ipv4: shrink current mss for tcp PMTU
 blackhole detection
Date: Sat, 28 Feb 2015 18:39:58 -0500
Message-ID: <CABrhC0m6nCwHy-CCLiFStYhSbMf78E1i6Lvh=DsPi6Pcg-GCOw@mail.gmail.com>
References: <1425093785-27380-1-git-send-email-fan.du@intel.com>
	<1425093785-27380-4-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: edumazet@google.com, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Fan Du <fengyuleidian0615@gmail.com>
To: Fan Du <fan.du@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:45365 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885AbbB1XkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 18:40:00 -0500
Received: by lbjb6 with SMTP id b6so23621932lbj.12
        for <netdev@vger.kernel.org>; Sat, 28 Feb 2015 15:39:58 -0800 (PST)
In-Reply-To: <1425093785-27380-4-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2015 at 10:23 PM, Fan Du <fan.du@intel.com> wrote:
> Reducing current tcp mss instead of search_low will make
> more sense, as current tcp mss still got lost.

> @@ -113,7 +114,8 @@ static void tcp_mtu_probing(struct inet_connection_sock *icsk, struct sock *sk)
>                         struct tcp_sock *tp = tcp_sk(sk);
>                         int mss;
>
> -                       mss = tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_low) >> 1;
> +                       /* try mss smaller than current mss */
> +                       mss = tcp_current_mss(sk) >> 1;
>                         mss = min(net->ipv4.sysctl_tcp_base_mss, mss);
>                         mss = max(mss, 68 - tp->tcp_header_len);
>                         icsk->icsk_mtup.search_low = tcp_mss_to_mtu(sk, mss);
> @@ -176,7 +178,7 @@ static int tcp_write_timeout(struct sock *sk)

I don't believe there's a problem with the code as written.  Modulo
headers, search_low <= mss =< search_high.  This code, on successive
timeouts, widens the search range by adjusting search_low (and mss)
downward.

  -John
