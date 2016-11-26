From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] tipc: resolve connection flow control
 compatibility problem
Date: Fri, 25 Nov 2016 21:38:49 -0500 (EST)
Message-ID: <20161125.213849.1520438791184904997.davem@davemloft.net>
References: <1480031227-14836-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, parthasarathy.bhuvaragan@ericsson.com,
        ying.xue@windriver.com, maloy@donjonn.com,
        tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59850 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753370AbcKZCix (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 21:38:53 -0500
In-Reply-To: <1480031227-14836-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Thu, 24 Nov 2016 18:47:07 -0500

> In commit 10724cc7bb78 ("tipc: redesign connection-level flow control")
> we replaced the previous message based flow control with one based on
> 1k blocks. In order to ensure backwards compatibility the mechanism
> falls back to using message as base unit when it senses that the peer
> doesn't support the new algorithm. The default flow control window,
> i.e., how many units can be sent before the sender blocks and waits
> for an acknowledge (aka advertisement) is 512. This was tested against
> the previous version, which uses an acknowledge frequency of on ack per
> 256 received message, and found to work fine.
> 
> However, we missed the fact that versions older than Linux 3.15 use an
> acknowledge frequency of 512, which is exactly the limit where a 4.6+
> sender will stop and wait for acknowledge. This would also work fine if
> it weren't for the fact that if the first sent message on a 4.6+ server
> side is an empty SYNACK, this one is also is counted as a sent message,
> while it is not counted as a received message on a legacy 3.15-receiver.
> This leads to the sender always being one step ahead of the receiver, a
> scenario causing the sender to block after 512 sent messages, while the
> receiver only has registered 511 read messages. Hence, the legacy
> receiver is not trigged to send an acknowledge, with a permanently
> blocked sender as result.
> 
> We solve this deadlock by simply allowing the sender to send one more
> message before it blocks, i.e., by a making minimal change to the
> condition used for determining connection congestion.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks Jon.
