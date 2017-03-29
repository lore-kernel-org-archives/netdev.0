From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] l2tp: purge socket queues in the .destruct()
 callback
Date: Wed, 29 Mar 2017 09:27:07 -0700 (PDT)
Message-ID: <20170329.092707.886770535007645317.davem@davemloft.net>
References: <bf0b71ec6a771f4af715573c340dd2a83b4f02b7.1490769866.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48068 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752256AbdC2Q1J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 12:27:09 -0400
In-Reply-To: <bf0b71ec6a771f4af715573c340dd2a83b4f02b7.1490769866.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Wed, 29 Mar 2017 08:45:29 +0200

> The Rx path may grab the socket right before pppol2tp_release(), but
> nothing guarantees that it will enqueue packets before
> skb_queue_purge(). Therefore, the socket can be destroyed without its
> queues fully purged.
> 
> Fix this by purging queues in pppol2tp_session_destruct() where we're
> guaranteed nothing is still referencing the socket.
> 
> Fixes: 9e9cb6221aa7 ("l2tp: fix userspace reception on plain L2TP sockets")
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied.
