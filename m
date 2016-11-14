From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: change sk state only when it has assocs in
 sctp_shutdown
Date: Mon, 14 Nov 2016 16:23:49 -0500 (EST)
Message-ID: <20161114.162349.1179710065617941826.davem@davemloft.net>
References: <d260f8b59f52d7ef00b83a554fc19d4aa91766a2.1479044677.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com,
        vyasevich@gmail.com, andreyknvl@google.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41346 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938697AbcKNVXv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 16:23:51 -0500
In-Reply-To: <d260f8b59f52d7ef00b83a554fc19d4aa91766a2.1479044677.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sun, 13 Nov 2016 21:44:37 +0800

> Now when users shutdown a sock with SEND_SHUTDOWN in sctp, even if
> this sock has no connection (assoc), sk state would be changed to
> SCTP_SS_CLOSING, which is not as we expect.
> 
> Besides, after that if users try to listen on this sock, kernel
> could even panic when it dereference sctp_sk(sk)->bind_hash in
> sctp_inet_listen, as bind_hash is null when sock has no assoc.
> 
> This patch is to move sk state change after checking sk assocs
> is not empty, and also merge these two if() conditions and reduce
> indent level.
> 
> Fixes: d46e416c11c8 ("sctp: sctp should change socket state when shutdown is received")
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Tested-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable, thanks.
