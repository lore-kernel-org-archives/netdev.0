From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: handle association restarts when the socket is
 closed.
Date: Mon, 06 Oct 2014 00:22:29 -0400 (EDT)
Message-ID: <20141006.002229.1370132762577292096.davem@davemloft.net>
References: <1412374580-22286-1-git-send-email-vyasevich@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57623 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbaJFEWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 00:22:32 -0400
In-Reply-To: <1412374580-22286-1-git-send-email-vyasevich@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Fri,  3 Oct 2014 18:16:20 -0400

> From: Vlad Yasevich <vyasevich@gmail.com>
> 
> Currently association restarts do not take into consideration the
> state of the socket.  When a restart happens, the current assocation
> simply transitions into established state.  This creates a condition
> where a remote system, through a the restart procedure, may create a
> local association that is no way reachable by user.  The conditions
> to trigger this are as follows:
>   1) Remote does not acknoledge some data causing data to remain
>      outstanding.
>   2) Local application calls close() on the socket.  Since data
>      is still outstanding, the association is placed in SHUTDOWN_PENDING
>      state.  However, the socket is closed.
>   3) The remote tries to create a new association, triggering a restart
>      on the local system.  The association moves from SHUTDOWN_PENDING
>      to ESTABLISHED.  At this point, it is no longer reachable by
>      any socket on the local system.
> 
> This patch addresses the above situation by moving the newly ESTABLISHED
> association into SHUTDOWN-SENT state and bundling a SHUTDOWN after
> the COOKIE-ACK chunk.  This way, the restarted associate immidiately
> enters the shutdown procedure and forces the termination of the
> unreachable association.
> 
> Reported-by: David Laight <David.Laight@aculab.com>
> Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>

Applied, thanks.

Candidate for -stable?
