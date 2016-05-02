From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/2] net: SOCKWQ_ASYNC_NOSPACE optimizations
Date: Mon, 2 May 2016 18:16:02 +0200
Message-ID: <20160502161602.GA1984@nanopsycho.orion>
References: <1461605974-4242-1-git-send-email-edumazet@google.com>
 <1461605974-4242-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>, eladr@mellanox.com,
	idosch@mellanox.com
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34488 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753465AbcEBQQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 12:16:06 -0400
Received: by mail-wm0-f65.google.com with SMTP id n129so17830163wmn.1
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 09:16:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1461605974-4242-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Apr 25, 2016 at 07:39:32PM CEST, edumazet@google.com wrote:
>SOCKWQ_ASYNC_NOSPACE is tested in sock_wake_async()
>so that a SIGIO signal is sent when needed.
>
>tcp_sendmsg() clears the bit.
>tcp_poll() sets the bit when stream is not writeable.
>
>We can avoid two atomic operations by first checking if socket
>is actually interested in the FASYNC business (most sockets in
>real applications do not use AIO, but select()/poll()/epoll())
>
>This also removes one cache line miss to access sk->sk_wq->flags
>in tcp_sendmsg()
>
>Signed-off-by: Eric Dumazet <edumazet@google.com>

I just bisected down to this. This is causing a regression for me when
my nfs mount becomes stuck. I can easily reproduce this if you need to
test the fix.

Thanks.
