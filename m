From: David Miller <davem@davemloft.net>
Subject: Re: [PATH 02/02] af_unix: fix unix_dgram_recvmsg entry locking
Date: Sun, 06 Dec 2015 23:31:07 -0500 (EST)
Message-ID: <20151206.233107.1531491369717555436.davem@davemloft.net>
References: <8737vf7051.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: rweikusat@mobileactivedefense.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8737vf7051.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Date: Sun, 06 Dec 2015 21:11:38 +0000

> The current unix_dgram_recvsmg code acquires the u->readlock mutex in
> order to protect access to the peek offset prior to calling
> __skb_recv_datagram for actually receiving data. This implies that a
> blocking reader will go to sleep with this mutex held if there's
> presently no data to return to userspace. Two non-desirable side effects
> of this are that a later non-blocking read call on the same socket will
> block on the ->readlock mutex until the earlier blocking call releases it
> (or the readers is interrupted) and that later blocking read calls
> will wait longer than the effective socket read timeout says they
> should: The timeout will only start 'ticking' once such a reader hits
> the schedule_timeout in wait_for_more_packets (core.c) while the time it
> already had to wait until it could acquire the mutex is unaccounted for.
> 
> The patch avoids both by using the __skb_try_recv_datagram and
> __skb_wait_for_more packets functions created by the first patch to
> implement a unix_dgram_recvmsg read loop which releases the readlock
> mutex prior to going to sleep and reacquires it as needed
> afterwards. Non-blocking readers will thus immediately return with
> -EAGAIN if there's no data available regardless of any concurrent
> blocking readers and all blocking readers will end up sleeping via
> schedule_timeout, thus honouring the configured socket receive timeout.
> 
> Signed-Off-By: Rainer Weikusat <rweikusat@mobileactivedefense.com>

Also applied to net-next, thanks.

BTW, it's "Signed-off-by: ".  Only the first word is capitalized.
