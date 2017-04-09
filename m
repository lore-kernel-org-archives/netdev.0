From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RFC] Generic XDP
Date: Sun, 09 Apr 2017 12:47:26 -0700 (PDT)
Message-ID: <20170409.124726.911932420824458401.davem@davemloft.net>
References: <20170408.200721.109499285021338999.davem@davemloft.net>
        <1491719118.4309.1.camel@sipsolutions.net>
        <1491721447.4309.2.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59682 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752320AbdDITr3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Apr 2017 15:47:29 -0400
In-Reply-To: <1491721447.4309.2.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Sun, 09 Apr 2017 09:04:07 +0200

> On Sun, 2017-04-09 at 08:25 +0200, Johannes Berg wrote:
>> That would also let you use rcu_assign_pointer() which seems like the
>> right thing to do here, along with marking the xdp_prog pointer as
>> __rcu? That'd also let you use rcu_dereference() instead of
>> READ_ONCE() which seems like the better annotation?
> 
> Looks like drivers do it exactly this way too though.

Every driver does things differently.  For example bnxt_en (which I
largely based my patch upon) uses xchg(), whilst mlx4 uses RCU
operations.

It just goes to show why it's good to have a common implementation of
XDP like this.

> What I forgot: I guess we could make drivers use dev->xdp_prog after
> this, instead of having their own?

Yes, but we have to resolve xchg() vs. RCU in order for that to work.

When evaluating this, we have to keep in mind that drivers tend to
have an extra pointer to the XDP program in their per-queue
datastructures.  They do this for the purposes of locality of
refernece during packet processing.

Instinctively I agree with you that RCU should be the way to go so
for now I'll adjust my patch to do things that way.

Thanks.
