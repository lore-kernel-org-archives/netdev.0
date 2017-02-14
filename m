From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] packet: fix races in fanout_add()
Date: Tue, 14 Feb 2017 15:05:49 -0500 (EST)
Message-ID: <20170214.150549.1660822376531685873.davem@davemloft.net>
References: <1487091831.8227.62.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42064 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751837AbdBNUFu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 15:05:50 -0500
In-Reply-To: <1487091831.8227.62.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 14 Feb 2017 09:03:51 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Multiple threads can call fanout_add() at the same time.
> 
> We need to grab fanout_mutex earlier to avoid races that could
> lead to one thread freeing po->rollover that was set by another thread.
> 
> Do the same in fanout_release(), for peace of mind, and to help us
> finding lockdep issues earlier.
> 
> Fixes: dc99f600698d ("packet: Add fanout support.")
> Fixes: 0648ab70afe6 ("packet: rollover prepare: per-socket state")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
