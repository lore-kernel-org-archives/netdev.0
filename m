From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] af_packet: Provide a TPACKET_V2 compatible Tx
 path for TPACKET_V3
Date: Fri, 30 Dec 2016 18:39:32 -0500
Message-ID: <CAF=yD-JiRDnYPB=W37T5tF7rVVGD5bACK6YkSWwuGdF2PdOdBQ@mail.gmail.com>
References: <1483116853-45769-1-git-send-email-sowmini.varadhan@oracle.com>
 <CAF=yD-+CMjr_9s2wVZOQEPAP5h9jpnMe3vckYGbQ9hnQoGWFEw@mail.gmail.com> <20161230230316.GB31800@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f67.google.com ([209.85.213.67]:36863 "EHLO
        mail-vk0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754223AbcL3XkO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2016 18:40:14 -0500
Received: by mail-vk0-f67.google.com with SMTP id 19so11528247vko.3
        for <netdev@vger.kernel.org>; Fri, 30 Dec 2016 15:40:13 -0800 (PST)
In-Reply-To: <20161230230316.GB31800@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Once we define the interface as equivalent to v2, we cannot redefine it to
>> support v3-only features later.
>
> What v3 only features do we think we want to support?

Variable length slots seems like the only one from that list that
makes sense on Tx.

It is already possible to prepare multiple buffers before triggering
transmit, so the block-based signal moderation is not very relevant.

> since then apps that want to use the Rx benefits
> have to deal with this dual socket feature, where
> with "one socket for super-fast rx, zero Tx".
> The zero-tx part sounds like a regression to me.

What is the issue with using separate sockets that you are
having? I generally end up using that even with V2.

> If we want to have something that does block Tx,
> and we cannot figure out how to retro-fit it to
> the exisiting APIs, we can always go for TPACKET_V4.

But the semantics for V3 are currenty well defined. Calling something
V3, but using V2 semantics is a somewhat unintuitive interface to me.

I don't see a benefit in defining something that does not implement
any new features. Especially if it blocks adding the expected
semantics later.

That said, if there is a workload that benefits from using a
single socket, and especially if it can be forward compatible with
support for variable sized slots, then I do not object. I was just
having a look at that second point, actually.

Could you also extend the TX_RING test in
tools/testing/selftests/net/psock_tpacket.c if there are no other
blocking issues?
