From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] route: add rcu_read_lock when lookup route and
 update fnhe in __ip_do_redirect
Date: Mon, 01 Feb 2016 09:49:28 -0800
Message-ID: <1454348968.7627.174.camel@edumazet-glaptop2.roam.corp.google.com>
References: <db60649416c596fc5e76930484b726cb180b14b8.1454322132.git.lucien.xin@gmail.com>
	 <1454334407.7627.163.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CADvbK_fScqzKzo-dfRWoAwdYBimEeXjns-1D0uD3WoERoL30hw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>, davem <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35376 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149AbcBARta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 12:49:30 -0500
Received: by mail-pf0-f178.google.com with SMTP id 65so87401109pfd.2
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 09:49:30 -0800 (PST)
In-Reply-To: <CADvbK_fScqzKzo-dfRWoAwdYBimEeXjns-1D0uD3WoERoL30hw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-02-02 at 01:16 +0800, Xin Long wrote:

> no, no stack dump was found.
> by reviewing code, I found it when I cooked another patch.
> 
> and the path that __ip_do_redirect() is called should be:
> 
> icmp_rcv |-> icmp_unreach  -\
>               |-> icmp_redirect -> icmp_socket_deliver -> ipprot->err_handler()
> [tcp_v4/6_err, sctp_v4/6_err, dccp_v4/6_err, udpv4/6_err ...]
> 
> -> ... -> __ip_do_redirect()
> 
> I checked the codes for many times, didn't find any rcu_lock on this path,
> unless we treat BH as rcu_lock.

Well I believe you missed something yes.

All RX paths run in rcu_read_lock()

ip_local_deliver_finish()
ipv6_rcv()
ip6_input_finish()
