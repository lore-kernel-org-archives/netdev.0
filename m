From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regression with commit 971f10eca186 ("tcp: better TCP_SKB_CB
 layout to reduce cache line misses")
Date: Mon, 22 Dec 2014 08:15:39 -0800
Message-ID: <1419264939.11185.18.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54983612.8000600@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Eric Dumazet <edumazet@google.com>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:48079 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754588AbaLVQPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 11:15:41 -0500
Received: by mail-pa0-f49.google.com with SMTP id eu11so6089151pac.8
        for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 08:15:41 -0800 (PST)
In-Reply-To: <54983612.8000600@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-12-22 at 16:17 +0100, Nicolas Dichtel wrote:
> One of our engineer (Huaibin Wang <huaibin.wang@6wind.com>) has reported and
> analysed this bug:
> 
> This commit introduces a regression with IPv6 + IPsec transport + TCP.
> 
> In TCP (net/ipv6/tcp_ipv6.c), xfrm6_policy_check() is called and thus, after
> some intermediate functions, _decode_session6() is also called.
> 
> This function uses IP6CB() (u8 nexthdr = nh[IP6CB(skb)->nhoff]), which is wrong
> becauses it has been moved to the end of TCP_SKB_CB().
> 
> Not sure what is the best way to fix this, any suggestion?

Thanks for the report

Presumably tcp_v6_rcv() needs to be reordered so that
xfrm6_policy_check() calls are done before the CB swap.

swap should probably be done right before bh_lock_sock_nested()

I am currently traveling and I am not sure if I can get Internet access
to post a patch soon.
