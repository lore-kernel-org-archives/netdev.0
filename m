From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH v2 net-next 0/6] tcp: better handling of memory pressure
Date: Fri, 15 May 2015 17:20:22 -0400
Message-ID: <55566316.5020800@akamai.com>
References: <1431718770-3815-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay02.akamai.com ([72.246.2.14]:57519 "EHLO
	prod-mail-xrelay02.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1423084AbbEOVUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 17:20:23 -0400
In-Reply-To: <1431718770-3815-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, feel free to add:

Acked-by: Jason Baron <jbaron@akamai.com>

Also, I sent as a separate patch:

Subject: [PATCH] tcp: ensure epoll edge trigger wakeup when out of memory

This does the wakeup in the case where we really can't allocate the
memory to see what you think of that idea. I didn't test it, but wanted
to see what you thought.

Thanks,

-Jason

On 05/15/2015 03:39 PM, Eric Dumazet wrote:
> When testing commit 790ba4566c1a ("tcp: set SOCK_NOSPACE under memory
> pressure") using edge triggered epoll applications, I found various
> issues under memory pressure and thousands of active sockets.
>
> This patch series is a first round to solve these issues, in send
> and receive paths. There are probably other fixes needed, but
> with this series, my tests now all succeed.
>
> v2: fix typo in "allow one skb to be received per socket under memory pressure",
> as spotted by Jason Baron.
>
> Eric Dumazet (6):
>   net: fix sk_mem_reclaim_partial()
>   tcp: rename sk_forced_wmem_schedule() to sk_forced_mem_schedule()
>   tcp: introduce tcp_under_memory_pressure()
>   tcp: fix behavior for epoll edge trigger
>   tcp: allow one skb to be received per socket under memory pressure
>   tcp: halves tcp_mem[] limits
>
>  include/net/sock.h    |  6 +++---
>  include/net/tcp.h     | 10 ++++++++++
>  net/core/sock.c       |  9 +++++----
>  net/ipv4/tcp.c        | 24 ++++++++++++++++++------
>  net/ipv4/tcp_input.c  | 18 ++++++++++--------
>  net/ipv4/tcp_output.c | 10 ++++++----
>  net/ipv4/tcp_timer.c  |  2 +-
>  7 files changed, 53 insertions(+), 26 deletions(-)
>
