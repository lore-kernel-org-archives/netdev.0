From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: flush the softnet backlog in process
 context
Date: Fri, 26 Aug 2016 11:51:30 -0700 (PDT)
Message-ID: <20160826.115130.2054859604870523839.davem@davemloft.net>
References: <528006070d2951617c55b94c60c5d690ff0e4fc3.1472130597.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, tom@herbertland.com,
        hannes@stressinduktion.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59628 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752513AbcHZSvj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 14:51:39 -0400
In-Reply-To: <528006070d2951617c55b94c60c5d690ff0e4fc3.1472130597.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Thu, 25 Aug 2016 15:58:44 +0200

> Currently in process_backlog(), the process_queue dequeuing is
> performed with local IRQ disabled, to protect against
> flush_backlog(), which runs in hard IRQ context.
> 
> This patch moves the flush operation to a work queue and runs the
> callback with bottom half disabled to protect the process_queue
> against dequeuing.
> Since process_queue is now always manipulated in bottom half context,
> the irq disable/enable pair around the dequeue operation are removed.
> 
> To keep the flush time as low as possible, the flush
> works are scheduled on all online cpu simultaneously, using the
> high priority work-queue and statically allocated, per cpu,
> work structs.
> 
> Overall this change increases the time required to destroy a device
> to improve slightly the packets reinjection performances.
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied, thanks.
