From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] route: add rcu_read_lock when lookup route and update
 fnhe in __ip_do_redirect
Date: Tue, 2 Feb 2016 01:16:03 +0800
Message-ID: <CADvbK_fScqzKzo-dfRWoAwdYBimEeXjns-1D0uD3WoERoL30hw@mail.gmail.com>
References: <db60649416c596fc5e76930484b726cb180b14b8.1454322132.git.lucien.xin@gmail.com>
	<1454334407.7627.163.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, davem <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f195.google.com ([209.85.214.195]:35668 "EHLO
	mail-ob0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753128AbcBARQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 12:16:05 -0500
Received: by mail-ob0-f195.google.com with SMTP id tr5so8708609obc.2
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 09:16:04 -0800 (PST)
In-Reply-To: <1454334407.7627.163.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> But the whole __ip_do_redirect() needs to be called from rcu_read_lock()
> already.
>
> No need to add another rcu_read_lock() around fib_lookup()
>
> How did you come doing this patch ? Any particular stack dump or
> something ?
>
no, no stack dump was found.
by reviewing code, I found it when I cooked another patch.

and the path that __ip_do_redirect() is called should be:

icmp_rcv |-> icmp_unreach  -\
              |-> icmp_redirect -> icmp_socket_deliver -> ipprot->err_handler()
[tcp_v4/6_err, sctp_v4/6_err, dccp_v4/6_err, udpv4/6_err ...]

-> ... -> __ip_do_redirect()

I checked the codes for many times, didn't find any rcu_lock on this path,
unless we treat BH as rcu_lock.

did I miss something ?

Thanks.

>
>
>
>
>
