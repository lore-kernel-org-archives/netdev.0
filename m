From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/tcp-fastopen: make connect()'s return
 case more consistent with non-TFO
Date: Wed, 25 Jan 2017 14:12:32 -0500 (EST)
Message-ID: <20170125.141232.611265798570382143.davem@davemloft.net>
References: <1485351766-17124-1-git-send-email-w@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, weiwan@google.com, ycheng@google.com,
        edumazet@google.com
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59968 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752389AbdAYTMe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 14:12:34 -0500
In-Reply-To: <1485351766-17124-1-git-send-email-w@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Wed, 25 Jan 2017 14:42:46 +0100

> Without TFO, any subsequent connect() call after a successful one returns
> -1 EISCONN. The last API update ensured that __inet_stream_connect() can
> return -1 EINPROGRESS in response to sendmsg() when TFO is in use to
> indicate that the connection is now in progress. Unfortunately since this
> function is used both for connect() and sendmsg(), it has the undesired
> side effect of making connect() now return -1 EINPROGRESS as well after
> a successful call, while at the same time poll() returns POLLOUT. This
> can confuse some applications which happen to call connect() and to
> check for -1 EISCONN to ensure the connection is usable, and for which
> EINPROGRESS indicates a need to poll, causing a loop.
> 
> This problem was encountered in haproxy where a call to connect() is
> precisely used in certain cases to confirm a connection's readiness.
> While arguably haproxy's behaviour should be improved here, it seems
> important to aim at a more robust behaviour when the goal of the new
> API is to make it easier to implement TFO in existing applications.
> 
> This patch simply ensures that we preserve the same semantics as in
> the non-TFO case on the connect() syscall when using TFO, while still
> returning -1 EINPROGRESS on sendmsg(). For this we simply tell
> __inet_stream_connect() whether we're doing a regular connect() or in
> fact connecting for a sendmsg() call.
> 
> Cc: Wei Wang <weiwan@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Willy Tarreau <w@1wt.eu>

Applied.
