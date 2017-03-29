From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] l2tp: purge socket queues in the .destruct()
 callback
Date: Tue, 28 Mar 2017 21:39:50 -0700 (PDT)
Message-ID: <20170328.213950.605445824406263363.davem@davemloft.net>
References: <5e9e60582739bc2b9def6c29abe071913632878a.1490707863.git.g.nault@alphalink.fr>
        <5d7b420189448fbc837a115b34ba59e42781aaef.1490707863.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41470 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751820AbdC2Ejw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 00:39:52 -0400
In-Reply-To: <5d7b420189448fbc837a115b34ba59e42781aaef.1490707863.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Tue, 28 Mar 2017 15:32:41 +0200

> The Rx path may grab the socket right before pppol2tp_release(), but
> nothing guarantees that it will enqueue packets before
> skb_queue_purge(). Therefore, the socket can be destroyed without its
> queues fully purged.
> 
> Fix this by purging queues in pppol2tp_session_destruct() where we're
> guaranteed nothing is still referencing the socket.
> 
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

As a quick guess, I'm thinking this problem might have been introduced
by:

====================
commit 9e9cb6221aa7cb04765484fe87cc2d1b92edce64
Author: Guillaume Nault <g.nault@alphalink.fr>
Date:   Thu Mar 6 11:15:10 2014 +0100

    l2tp: fix userspace reception on plain L2TP sockets
====================

Please add an appropriate Fixes: tag for this patch.

Thanks.
