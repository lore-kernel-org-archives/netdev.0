From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] net-tcp: Fast Open client - cookie cache
Date: Mon, 16 Jul 2012 23:15:35 -0700 (PDT)
Message-ID: <20120716.231535.1001789192358609710.davem@davemloft.net>
References: <1342473410-6265-1-git-send-email-ycheng@google.com>
	<1342473410-6265-3-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hkchu@google.com, edumazet@google.com, ncardwell@google.com,
	sivasankar@cs.ucsd.edu, netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46602 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170Ab2GQGPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 02:15:36 -0400
In-Reply-To: <1342473410-6265-3-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Mon, 16 Jul 2012 14:16:45 -0700

> The Fast Open cookie cache is used by a TCP Fast Open client to store
> remote servers' Fast Open cookies. It stores one Fast Open cookie
> per IP (v4 or v6) and by default 1024 cookies total. The size is
> tunable via /proc/sys/net/ipv4/tcp_fastopen_cookies. Setting it to 0
> will flush the cache.
> 
> The inetpeer cache also caches remote peer's information but the
> in-active cache entries are recycled on the scale of minutes. Therefore
> a separate storage is required but the lookup is done via inetpeer.
> Each inetpeer entry holds a cookie cache entry pointer (if TFO is used
> on that IP). On cache write, the cookie cache entry is allocated and
> stored in a list for LRU replacement. A spinlock protects any R/W
> operation on the cookie cache entry and the list.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

I would store these in the new tcp metrics cache.

Any argument against doing so wrt. expiry is bogus, because you can
implement whatever time limit you want using a jiffies based
expiration value.
