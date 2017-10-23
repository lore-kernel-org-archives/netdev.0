From: Peter Zijlstra <peterz@infradead.org>
Subject: problem with rtnetlink 'reference' count
Date: Mon, 23 Oct 2017 16:25:55 +0200
Message-ID: <20171023142555.GF3165@worktop.lehotels.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:43860 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751399AbdJWO0B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 10:26:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I just ran across commit:

  019a316992ee ("rtnetlink: add reference counting to prevent module unload while dump is in progress")

And that commit is _completely_ broken.

 1) it not in fact a refcount, so using refcount_t is silly
 2) there is a distinct lack of memory barriers, so we can easily
    observe the decrement while the msg_handler is still in progress.
 3) waiting with a schedule()/yield() loop is complete crap and subject
    life-locks, imagine doing that rtnl_unregister_all() from a RT task.

Please fix..
