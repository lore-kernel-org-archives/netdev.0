From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: fix handling of throw routes
Date: Thu, 06 Sep 2012 15:58:25 +0200
Message-ID: <1346939905.2484.43.camel@edumazet-glaptop>
References: <5048A374.60005@6wind.com>
	 <1346946815-3094-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, markus.stenberg@iki.fi
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:46426 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752838Ab2IFN63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 09:58:29 -0400
Received: by eekc1 with SMTP id c1so712220eek.19
        for <netdev@vger.kernel.org>; Thu, 06 Sep 2012 06:58:28 -0700 (PDT)
In-Reply-To: <1346946815-3094-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-06 at 11:53 -0400, Nicolas Dichtel wrote:
> It's the same problem that previous fix about blackhole and prohibit routes.
> 
> When adding a throw route, it was handled like a classic route.
> Moreover, it was only possible to add this kind of routes by specifying
> an interface.
> 
> Before the patch:
>   $ ip route add throw 2001::2/128
>   RTNETLINK answers: No such device
>   $ ip route add throw 2001::2/128 dev eth0
>   $ ip -6 route | grep 2001::2
>   2001::2 dev eth0  metric 1024
> 
> After:
>   $ ip route add throw 2001::2/128
>   $ ip -6 route | grep 2001::2
>   throw 2001::2 dev lo  metric 1024  error -11
> 
> Reported-by: Markus Stenberg <markus.stenberg@iki.fi>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  net/ipv6/route.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks Nicolas
