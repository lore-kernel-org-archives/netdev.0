From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: fix recovering from 0 win with small data
 chunks
Date: Fri, 23 Dec 2016 14:02:09 -0500 (EST)
Message-ID: <20161223.140209.1226868882402302341.davem@davemloft.net>
References: <d9025eef1b2be8e7097fd4a5db73b4f5c0f5418b.1482510289.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        nhorman@tuxdriver.com, vyasevich@gmail.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48518 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965069AbcLWTCO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2016 14:02:14 -0500
In-Reply-To: <d9025eef1b2be8e7097fd4a5db73b4f5c0f5418b.1482510289.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Fri, 23 Dec 2016 14:29:37 -0200

> Currently if SCTP closes the receive window with window pressure, mostly
> caused by excessive skb overhead on payload/overheads ratio, SCTP will
> close the window abruptly while saving the delta on rwnd_press. It will
> start recovering rwnd as the chunks are consumed by the application and
> the rwnd_press will be only recovered after rwnd reach the same value as
> of rwnd_press, mostly to prevent silly window syndrome.
> 
> Thing is, this is very inefficient with small data chunks, as with those
> it will never reach back that value, and thus it will never recover from
> such pressure. This means that we will not issue window updates when
> recovering from 0 window and will rely on a sender retransmit to notice
> it.
> 
> The fix here is to remove such threshold, as no value is good enough: it
> depends on the (avg) chunk sizes being used.
> 
> Test with netperf -t SCTP_STREAM -- -m 1, and trigger 0 window by
> sending SIGSTOP to netserver, sleep 1.2, and SIGCONT.
> Rate limited to 845kbps, for visibility. Capture done at netserver side.
 ...
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied.
