From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] atm: remove an unnecessary loop
Date: Mon, 13 Mar 2017 15:37:47 -0700 (PDT)
Message-ID: <20170313.153747.2002680336372510819.davem@davemloft.net>
References: <1489279296-9316-1-git-send-email-3chas3@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com
To: 3chas3@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58428 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932136AbdCMWht (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 18:37:49 -0400
In-Reply-To: <1489279296-9316-1-git-send-email-3chas3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chas Williams <3chas3@gmail.com>
Date: Sat, 11 Mar 2017 19:41:36 -0500

> From: Francois Romieu <romieu@fr.zoreil.com>
> 
> Andrey reported this kernel warning:
> 
> WARNING: CPU: 0 PID: 4114 at kernel/sched/core.c:7737 __might_sleep+0x149/0x1a0
> do not call blocking ops when !TASK_RUNNING; state=1 set at
> [<ffffffff813fcb22>] prepare_to_wait+0x182/0x530
> 
> The deeply nested alloc_skb is a problem.
> 
> Diagnosis: nesting is wrong. It makes zero sense. Fix it and the
> implicit task state change problem automagically goes away.
> 
> alloc_skb() does not need to be in the "while" loop.
> 
> alloc_skb() does not need to be in the {prepare_to_wait/add_wait_queue ...
> finish_wait/remove_wait_queue} block.
> 
> I claim that:
> - alloc_tx() should only perform the "wait_for_decent_tx_drain" part
> - alloc_skb() ought to be done directly in vcc_sendmsg
> - alloc_skb() failure can be handled gracefully in vcc_sendmsg
> - alloc_skb() may use a (m->msg_flags & MSG_DONTWAIT) dependent
>   GFP_{KERNEL / ATOMIC} flag
> 
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Reviewed-and-Tested-by: Chas Williams <3chas3@gmail.com>
> Signed-off-by: Chas Williams <3chas3@gmail.com>

Applied, thanks a lot Chas.
