From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Do not use TSO/GSO when there is urgent data
Date: Fri, 21 Nov 2008 16:43:40 -0800 (PST)
Message-ID: <20081121.164340.67054948.davem@davemloft.net>
References: <200811211319.45515.ptesarik@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, jsembera@suse.cz
To: ptesarik@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39600
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753566AbYKVAnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 19:43:41 -0500
In-Reply-To: <200811211319.45515.ptesarik@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Tesarik <ptesarik@suse.cz>
Date: Fri, 21 Nov 2008 13:19:45 +0100

> This patch fixes http://bugzilla.kernel.org/show_bug.cgi?id=12014
> 
> Since most (if not all) implementations of TSO and even the in-kernel
> software GSO do not update the urgent pointer when splitting a large
> segment, it is necessary to turn off TSO/GSO for all outgoing traffic
> with the URG pointer set.
> 
> Looking at tcp_current_mss (and the preceding comment) I even think
> this was the original intention. However, this approach is insufficient,
> because TSO/GSO is turned off only for newly created frames, not for
> frames which were already pending at the arrival of a message with
> MSG_OOB set. These frames were created when TSO/GSO was enabled,
> so they may be large, and they will have the urgent pointer set
> in tcp_transmit_skb().
> 
> With this patch, such large packets will be fragmented again before
> going to the transmit routine.
> 
> As a side note, at least the following NICs are known to screw up
> the urgent pointer in the TCP header when doing TSO:
> 
> 	Intel 82566MM (PCI ID 8086:1049)
> 	Intel 82566DC (PCI ID 8086:104b)
> 	Intel 82541GI (PCI ID 8086:1076)
> 	Broadcom NetXtreme II BCM5708 (PCI ID 14e4:164c)
> 
> Signed-off-by: Petr Tesarik <ptesarik@suse.cz>

Applied, thanks Petr.

BTW, your email client screwed up the patch by breaking up long lines,
for example:

> @@ -722,7 +722,8 @@ static void tcp_queue_skb(struct sock *sk, struct sk_buff 
> *skb)

And:

> @@ -1163,7 +1164,9 @@ static int tcp_init_tso_segs(struct sock *sk, struct 
> sk_buff *skb,

I fixed it up this time, but I will not in the future.
