From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: check if dereference of ipv6 header is safe
Date: Fri, 18 Jan 2013 11:12:26 -0800
Message-ID: <1358536346.11051.580.camel@edumazet-glaptop>
References: <20130117035652.GB23782@order.stressinduktion.org>
	 <20130118020612.GA14833@order.stressinduktion.org>
	 <1358475697.11051.9.camel@edumazet-glaptop>
	 <20130118030819.GA20324@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:43858 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881Ab3ARTM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 14:12:29 -0500
Received: by mail-pa0-f50.google.com with SMTP id hz10so2284292pad.37
        for <netdev@vger.kernel.org>; Fri, 18 Jan 2013 11:12:29 -0800 (PST)
In-Reply-To: <20130118030819.GA20324@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-01-18 at 04:08 +0100, Hannes Frederic Sowa wrote:

> Please correct me if I am wrong:
> 
> The callstack as captured in ipip6_rcv:
>     ipip6_rcv+0xcd/0x680 [sit]
>     tunnel64_rcv+0x4a/0x174 [tunnel4]
>     ip_local_deliver+0x152/0x470
>     ? ip_local_deliver+0x75/0x470
>     ip_rcv+0x36d/0x650
> 
> ip_rcv does first check if the ipv4 header is complete (inclusive options) and
> passes control to ip_local_deliver which calls __skb_pull(skb,
> ip_hdrlen(skb)). So ->data is forwarded behind the ipv4 header. The next
> pskb_may_pull check would check if the necessary amount of data behind the
> ipv4 header is available hence I assume the check in tunnel64_rcv is enough:

Oh, yes, thats fine.
