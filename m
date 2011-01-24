From: David Miller <davem@davemloft.net>
Subject: Re: Problems with /proc/net/tcp6 - possible bug - ipv6
Date: Mon, 24 Jan 2011 14:42:00 -0800 (PST)
Message-ID: <20110124.144200.112610203.davem@davemloft.net>
References: <702550.61465.qm@web63902.mail.re1.yahoo.com>
	<1295686781.2609.37.camel@edumazet-laptop>
	<1295709344.2651.55.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: runningdoglackey@yahoo.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295709344.2651.55.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 22 Jan 2011 16:15:44 +0100

> [PATCH] tcp: fix bug in listening_get_next()
> 
> commit a8b690f98baf9fb19 (tcp: Fix slowness in read /proc/net/tcp)
> introduced a bug in handling of SYN_RECV sockets.
> 
> st->offset represents number of sockets found since beginning of
> listening_hash[st->bucket].
> 
> We should not reset st->offset when iterating through
> syn_table[st->sbucket], or else if more than ~25 sockets (if
> PAGE_SIZE=4096) are in SYN_RECV state, we exit from listening_get_next()
> with a too small st->offset
> 
> Next time we enter tcp_seek_last_pos(), we are not able to seek past
> already found sockets.
> 
> Reported-by: PK <runningdoglackey@yahoo.com>
> CC: Tom Herbert <therbert@google.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable, thanks Eric.
