From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 1/3] ipv6: Prevent unexpected sk->sk_prot
 changes
Date: Tue, 15 Aug 2017 07:45:36 -0700
Message-ID: <1502808336.4936.78.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1502795320-22538-1-git-send-email-ilyal@mellanox.com>
         <1502795320-22538-2-git-send-email-ilyal@mellanox.com>
         <1502798357.4936.63.camel@edumazet-glaptop3.roam.corp.google.com>
         <DB6PR05MB31768343CE15F47F8CC12CD8B08D0@DB6PR05MB3176.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ilya Lesokhin <ilyal@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "davejwatson@fb.com" <davejwatson@fb.com>,
        Aviad Yehezkel <aviadye@mellanox.com>
To: Boris Pismenny <borisp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:38747 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752435AbdHOOpk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 10:45:40 -0400
Received: by mail-pg0-f66.google.com with SMTP id 123so1764703pga.5
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 07:45:40 -0700 (PDT)
In-Reply-To: <DB6PR05MB31768343CE15F47F8CC12CD8B08D0@DB6PR05MB3176.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-15 at 13:08 +0000, Boris Pismenny wrote:
> Hi Eric,


> 
> The IPV6_ADDRFORM socket option assumes that when 
> (sk->sk_protocol == IPPROTO_TCP)
> then the sk_proto is set to tcpv6_prot and it replaces it with tcp_prot.
> 
> This patch ensures that the IPV6_ADDRFORM socket option doesn't replace
> the socket's sk_prot to tcp when it is not expected. For example, TLS sockets
> also replace sk_prot, and we need to prevent IPV6_ADDRFORM from
> overriding these.
> 
> Are you suggesting that each socket protocol will provide a method that
> converts it from IPv6 to IPv4?

I am just saying IPV6_ADDRFORM is becoming spaghetti code, and maybe
this is time to make it modular.

The UDP or TCP magic really should be implemented in TCP or UDP files.

(Who knows maybe one day SCTP or DCCP will support IPVADDRFORM)
