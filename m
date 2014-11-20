From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: remove from tcp_sendmsg() some fastopen
 code
Date: Thu, 20 Nov 2014 15:05:00 -0800
Message-ID: <1416524700.8629.58.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416268176.18588.26.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1416294380.14060.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAK6E8=dUvde2s7VuUS9rHiA2fU0ZT2bS=ronjM+9BOA=0u-rVw@mail.gmail.com>
	 <20141119.145741.1905980604994551607.davem@davemloft.net>
	 <1416497628.8629.24.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1416500634.8629.31.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, nuclearcat@nuclearcat.com,
	netdev@vger.kernel.org, ncardwell@google.com
To: David Miller <davem@davemloft.net>,
	Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:62905 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756500AbaKTXFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 18:05:01 -0500
Received: by mail-pd0-f180.google.com with SMTP id p10so3975483pdj.11
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 15:05:01 -0800 (PST)
In-Reply-To: <1416500634.8629.31.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-11-20 at 08:23 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> If we consume iovec bytes in tcp_send_syn_data(), we can remove
> annoying fastopen code in tcp_sendmsg() skipping over the already
> consumed bytes.
> 
> Also add an unlikely(flags & MSG_FASTOPEN), as most TCP sendmsg() do not
> ask for FASTOPEN.
> 
> Tested:
>  Ran our 125 packetdrill fastopen tests
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---

Please disregard this patch, Al Viro said sendmsg() was apparently not
allowed to change iovec.

Some callers depend on it staying constant.

Not clear why memcpy_fromiovec() even exists.
