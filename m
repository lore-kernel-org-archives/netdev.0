From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: listen(2) backlog changes in or around Linux 3.1?
Date: Fri, 19 Oct 2012 02:14:50 -0700
Message-ID: <CAGK4HS_9mLzL9ESm=n5hvO0cw1hkHFMCSmBiYTBnqEMqQOvPvQ@mail.gmail.com>
References: <CAJgzZorigejCuFweNrvmkEJts3Um7exh1fYTH=4KrEcB=v=2SA@mail.gmail.com>
	<507C4401.7050500@oracle.com>
	<CAJgzZoqhw6HJxa6uRbekLMaVTDVOo92YDtzqHnZoRiQ8tq6G2g@mail.gmail.com>
	<CAJgzZoq9+KZpQ1tVQJUK++VVk4JfY9u8timaJ5q6wSYoF+_tog@mail.gmail.com>
	<5080279F.80008@oracle.com>
	<5080340F.3050207@oracle.com>
	<CAJgzZooJM7aj=K-idvdbwUOOmtDM6u-=gsVOs2OFZjiZwQP0zw@mail.gmail.com>
	<CAGK4HS-tOE1uZR2PE+_DShEb3y5ZAn=dtECY1AmmyO2AmTVzTA@mail.gmail.com>
	<1350629413.2293.157.camel@edumazet-glaptop>
	<1350634013.2293.262.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: enh <enh@google.com>,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:32934 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757157Ab2JSJOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 05:14:50 -0400
Received: by mail-oa0-f46.google.com with SMTP id h16so202589oag.19
        for <netdev@vger.kernel.org>; Fri, 19 Oct 2012 02:14:50 -0700 (PDT)
In-Reply-To: <1350634013.2293.262.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index ef998b0..0404926 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1507,7 +1507,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
>          * clogging syn queue with openreqs with exponentially increasing
>          * timeout.
>          */
> -       if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
> +       if (__sk_acceptq_is_full(sk, inet_csk_reqsk_queue_young(sk)))
>                 goto drop;
>

For what its worth, I think the changes make sense. But is there any
reason to exclude old request_socks in the  call to
__sk_acceptq_is_full().?
as in
      if (__sk_acceptq_is_full(sk, inet_csk_reqsk_queue_len(sk)))
               goto drop;

I am not sure why the current code looks only at young request_socks.
Thanks,
Vijay
