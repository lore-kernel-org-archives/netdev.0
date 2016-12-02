From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] packet: fix race condition in packet_set_ring
Date: Fri, 02 Dec 2016 12:17:16 -0500 (EST)
Message-ID: <20161202.121716.1777311750320989876.davem@davemloft.net>
References: <1480546536.18162.216.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, philip.pettersson@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36888 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752366AbcLBRRR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 12:17:17 -0500
In-Reply-To: <1480546536.18162.216.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 30 Nov 2016 14:55:36 -0800

> From: Philip Pettersson <philip.pettersson@gmail.com>
> 
> When packet_set_ring creates a ring buffer it will initialize a
> struct timer_list if the packet version is TPACKET_V3. This value
> can then be raced by a different thread calling setsockopt to
> set the version to TPACKET_V1 before packet_set_ring has finished.
> 
> This leads to a use-after-free on a function pointer in the
> struct timer_list when the socket is closed as the previously
> initialized timer will not be deleted.
> 
> The bug is fixed by taking lock_sock(sk) in packet_setsockopt when
> changing the packet version while also taking the lock at the start
> of packet_set_ring.
> 
> Fixes: f6fb8f100b80 ("af-packet: TPACKET_V3 flexible buffer implementation.")
> Signed-off-by: Philip Pettersson <philip.pettersson@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
