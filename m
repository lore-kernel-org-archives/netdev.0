From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net: saving irq context for peernet2id()
Date: Fri, 21 Oct 2016 16:33:42 -0400 (EDT)
Message-ID: <20161021.163342.2187677530255875866.davem@davemloft.net>
References: <CAM_iQpV0vfwsToR=maxhGM+fvQLX9zqcpp14A-C9JNzLfKJy9g@mail.gmail.com>
        <20161021193951.GS23701@madcap2.tricolour.ca>
        <CAHC9VhSm21f-HurdGi7+D0LmHNkkKRyAsT-OHJEyOZgoJVYUNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rgb@redhat.com, xiyou.wangcong@gmail.com, sds@tycho.nsa.gov,
        netdev@vger.kernel.org, e@eladraz.com
To: paul@paul-moore.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35248 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753173AbcJUUdr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 16:33:47 -0400
In-Reply-To: <CAHC9VhSm21f-HurdGi7+D0LmHNkkKRyAsT-OHJEyOZgoJVYUNg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul@paul-moore.com>
Date: Fri, 21 Oct 2016 16:15:00 -0400

> However, that's not the case is it?  Unless I missed something, the
> fix that Cong Wang is advocating (rework the audit multicast code), is
> a change that I have said I'm not going to accept during the -rc
> phase.  It has been a few days now and no alternate fix has been
> proposed, I'll give it a few more hours ...

It really is the right way to fix this though.

Nothing should be emitting netlink messages, potentially en-masse
to a multicast group or broadcast, in hardware interrupt context.

I know it's been said that only systemd receives these things, so
that point doesn't need to be remade again.

We have many weeks until -final is released so I really don't
understand the reluctance at a slightly more involved fix in -rc2.  In
fact this is the most optimal time to try it this way, as we'll have
the maximum amount of time for it to have exposure for testing before
-final.

Thanks.
