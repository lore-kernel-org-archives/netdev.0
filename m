From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: net_enable_timestamp() can be called from irq
 contexts
Date: Wed, 01 Mar 2017 20:58:16 -0800 (PST)
Message-ID: <20170301.205816.1158665690798472665.davem@davemloft.net>
References: <1488398879.9415.302.camel@edumazet-glaptop3.roam.corp.google.com>
        <1488399119.9415.304.camel@edumazet-glaptop3.roam.corp.google.com>
        <1488407319.9415.315.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, dvyukov@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58844 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751675AbdCBKYZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 05:24:25 -0500
In-Reply-To: <1488407319.9415.315.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 01 Mar 2017 14:28:39 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> It is now very clear that silly TCP listeners might play with
> enabling/disabling timestamping while new children are added
> to their accept queue.
> 
> Meaning net_enable_timestamp() can be called from BH context
> while current state of the static key is not enabled.
> 
> Lets play safe and allow all contexts.
> 
> The work queue is scheduled only under the problematic cases,
> which are the static key enable/disable transition, to not slow down
> critical paths.
> 
> This extends and improves what we did in commit 5fa8bbda38c6 ("net: use
> a work queue to defer net_disable_timestamp() work")
> 
> Fixes: b90e5794c5bd ("net: dont call jump_label_dec from irq context")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>

Applied and queued up for -stable.
