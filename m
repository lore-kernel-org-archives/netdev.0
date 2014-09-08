From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: refresh rt6i_genid in ip6_pol_route()
Date: Sun, 07 Sep 2014 21:18:25 -0700
Message-ID: <1410149905.11872.73.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1410021507.11872.35.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1410027712.11872.40.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1410116703.11872.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140907.155446.2293591154334558042.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, therbert@google.com,
	alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:39360 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbaIHES1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 00:18:27 -0400
Received: by mail-pa0-f46.google.com with SMTP id eu11so26225297pac.5
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2014 21:18:27 -0700 (PDT)
In-Reply-To: <20140907.155446.2293591154334558042.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-09-07 at 15:54 -0700, David Miller wrote:

> This might be broken.
> 
> We are dealing here with persistent entries in the ipv6 routine trie.
> 
> If you just bump the genid on the next person to look it up, other
> sockets and cached entities might not have validated the route yet,
> and now will falsely see the route as valid.  We have to ensure that
> they too drop this route and perform a relookup.

I am confused, I thought it was the role of the cookie.

(Ie socket has to store its own cookie to be able to validate a route)

Before 6f3118b571b8 patch, how was this done anyway ?

If persistent routes cannot refresh the genid, then they are useless ?
