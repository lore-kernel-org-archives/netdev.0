From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] mlxsw: core: Fix possible deadlock
Date: Wed, 18 Oct 2017 12:21:13 +0100 (WEST)
Message-ID: <20171018.122113.2048778528438796236.davem@davemloft.net>
References: <20171016142828.2742-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59776 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752029AbdJRLVT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 07:21:19 -0400
In-Reply-To: <20171016142828.2742-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 16 Oct 2017 16:28:28 +0200

> From: Ido Schimmel <idosch@mellanox.com>
> 
> When an EMAD is transmitted, a timeout work item is scheduled with a
> delay of 200ms, so that another EMAD will be retried until a maximum of
> five retries.
> 
> In certain situations, it's possible for the function waiting on the
> EMAD to be associated with a work item that is queued on the same
> workqueue (`mlxsw_core`) as the timeout work item. This results in
> flushing a work item on the same workqueue.
> 
> According to commit e159489baa71 ("workqueue: relax lockdep annotation
> on flush_work()") the above may lead to a deadlock in case the workqueue
> has only one worker active or if the system in under memory pressure and
> the rescue worker is in use. The latter explains the very rare and
> random nature of the lockdep splats we have been seeing:
 ...
> Fix this by creating another workqueue for EMAD timeouts, thereby
> preventing the situation of a work item trying to flush a work item
> queued on the same workqueue.
> 
> Fixes: caf7297e7ab5f ("mlxsw: core: Introduce support for asynchronous EMAD register access")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Reported-by: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied.
