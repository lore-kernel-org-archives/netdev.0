From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netem: fix skb_orphan_partial()
Date: Thu, 11 May 2017 21:33:24 -0400 (EDT)
Message-ID: <20170511.213324.2195365887593861486.davem@davemloft.net>
References: <c5a4858f-1559-7c75-b224-99391e6bb6c4@nabto.com>
        <1494531770.7796.115.camel@edumazet-glaptop3.roam.corp.google.com>
        <1494541481.7796.124.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mkm@nabto.com, stephen@networkplumber.org, edumazet@google.com,
        netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56718 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755591AbdELBdb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 21:33:31 -0400
In-Reply-To: <1494541481.7796.124.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 11 May 2017 15:24:41 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> I should have known that lowering skb->truesize was dangerous :/
> 
> In case packets are not leaving the host via a standard Ethernet device,
> but looped back to local sockets, bad things can happen, as reported
> by Michael Madsen ( https://bugzilla.kernel.org/show_bug.cgi?id=195713 )
> 
> So instead of tweaking skb->truesize, lets change skb->destructor
> and keep a reference on the owner socket via its sk_refcnt.
> 
> Fixes: f2f872f9272a ("netem: Introduce skb_orphan_partial() helper")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Michael Madsen <mkm@nabto.com>

Applied and queued up for -stable, thanks.
