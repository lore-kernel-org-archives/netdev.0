From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: accept RST for rcv_nxt - 1 after
 receiving a FIN
Date: Tue, 17 Jan 2017 15:52:26 -0500 (EST)
Message-ID: <20170117.155226.1285167033562007741.davem@davemloft.net>
References: <1484678239-19199-1-git-send-email-jbaron@akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: jbaron@akamai.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43854 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750992AbdAQVBL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 16:01:11 -0500
In-Reply-To: <1484678239-19199-1-git-send-email-jbaron@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Baron <jbaron@akamai.com>
Date: Tue, 17 Jan 2017 13:37:19 -0500

> From: Jason Baron <jbaron@akamai.com>
> 
> Using a Mac OSX box as a client connecting to a Linux server, we have found
> that when certain applications (such as 'ab'), are abruptly terminated
> (via ^C), a FIN is sent followed by a RST packet on tcp connections. The
> FIN is accepted by the Linux stack but the RST is sent with the same
> sequence number as the FIN, and Linux responds with a challenge ACK per
> RFC 5961. The OSX client then sometimes (they are rate-limited) does not
> reply with any RST as would be expected on a closed socket.
> 
> This results in sockets accumulating on the Linux server left mostly in
> the CLOSE_WAIT state, although LAST_ACK and CLOSING are also possible.
> This sequence of events can tie up a lot of resources on the Linux server
> since there may be a lot of data in write buffers at the time of the RST.
> Accepting a RST equal to rcv_nxt - 1, after we have already successfully
> processed a FIN, has made a significant difference for us in practice, by
> freeing up unneeded resources in a more expedient fashion.
> 
> A packetdrill test demonstrating the behavior:
 ...
> Signed-off-by: Jason Baron <jbaron@akamai.com>

Applied, thanks Jason.
