From: Ian Kumlien <ian.kumlien@gmail.com>
Subject: Re: 4.9.2 panic, __skb_flow_dissect, gro?
Date: Wed, 11 Jan 2017 01:16:35 +0100
Message-ID: <CAA85sZsKSJkaWJ44w9__mJ6vH9ViZwpsovOhnEZRG3sO5K-2PA@mail.gmail.com>
References: <359da98eb44a5a9f9f286cc380143654@nuclearcat.com> <96694297c5f7178b92bfd9a12bef4a42@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:34140 "EHLO
        mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754250AbdAKAQ4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 19:16:56 -0500
Received: by mail-oi0-f44.google.com with SMTP id 3so567274527oih.1
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 16:16:56 -0800 (PST)
In-Reply-To: <96694297c5f7178b92bfd9a12bef4a42@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added David Miller to CC since he said it was queued for stable, maybe
he can comment

On Wed, Jan 11, 2017 at 12:49 AM, Denys Fedoryshchenko
<nuclearcat@nuclearcat.com> wrote:
> It seems this patch solve issue. I hope it will go to stable asap, because
> without it loaded routers crashing almost instantly on 4.9.

I'm also worried that you could trigger it remotely....

I suspect the following:
intel: fm10k, i40e, i40ev, igb, ixgbe, ixgbevf
mellanox: mlx4, mlx5
qlogic: qede

since skb_flow_dissect is called by eth_get_headlen in these drivers...

My machine was running with igb when it happened, is your network
driver in the list?

David: Let me know if i can help with the -stable bit in anyway, i've
been surprised to see it miss .1 and .2

> commit  d0af683407a26a4437d8fa6e283ea201f2ae8146 (patch)
> tree    e769779cf59b0b73333b50a68db5d0b8897a7cb6 /net/core/flow_dissector.c
> parent  94ba998b63c41e92da1b2f0cd8679e038181ef48 (diff)
> flow_dissector: Update pptp handling to avoid null pointer deref.
> __skb_flow_dissect can be called with a skb or a data packet, either
> can be NULL. All calls seems to have been moved to __skb_header_pointer
> except the pptp handling which is still calling skb_header_pointer.
