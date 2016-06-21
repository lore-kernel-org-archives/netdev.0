From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: reduce cpu usage when SO_SNDBUF is set
Date: Tue, 21 Jun 2016 16:48:34 -0700
Message-ID: <1466552914.6850.33.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1466457781-24123-1-git-send-email-jbaron@akamai.com>
	 <1466461744.6850.29.camel@edumazet-glaptop3.roam.corp.google.com>
	 <57695C11.6070201@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:33323 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750731AbcFUXsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 19:48:41 -0400
Received: by mail-pa0-f65.google.com with SMTP id ts6so2265094pac.0
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 16:48:41 -0700 (PDT)
In-Reply-To: <57695C11.6070201@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-06-21 at 11:24 -0400, Jason Baron wrote:

> in tcp_check_space() with something like:
> 
> sk->sk_flags &= ~((1UL << SOCK_QUEUE_SHRUNK) | (1UL << SOCK_SHORT_WRITE));
> 
> Since we are already writing to sk_flags there this should have very
> minimal overhead. And then remove the clear in sk_stream_write_space().

Interesting. You added in 3c7151275c0c9 a smp_mb__after_atomic()
in tcp_check_space(), but there is no atomic operation to begin with ;)
