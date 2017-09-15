From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] packet: hold bind lock when rebinding to fanout hook
Date: Fri, 15 Sep 2017 10:07:46 -0400
Message-ID: <CAF=yD-J3PYMsZXxogr_9-fbDXHnTT-LBq0TXjbFbhSHXKeA65w@mail.gmail.com>
References: <20170914211441.67326-1-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        nixiaoming <nixiaoming@huawei.com>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:44166 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751584AbdIOOI2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 10:08:28 -0400
Received: by mail-io0-f170.google.com with SMTP id v36so8714455ioi.1
        for <netdev@vger.kernel.org>; Fri, 15 Sep 2017 07:08:27 -0700 (PDT)
In-Reply-To: <20170914211441.67326-1-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 14, 2017 at 5:14 PM, Willem de Bruijn <willemb@google.com> wrote:
> Packet socket bind operations must hold the po->bind_lock. This keeps
> po->running consistent with whether the socket is actually on a ptype
> list to receive packets.
>
> fanout_add unbinds a socket and its packet_rcv/tpacket_rcv call, then
> binds the fanout object to receive through packet_rcv_fanout.
>
> Make it hold the po->bind_lock when testing po->running and rebinding.
> Else, it can race with other rebind operations, such as that in
> packet_set_ring from packet_rcv to tpacket_rcv. Concurrent updates
> can result in a socket being added to a fanout group twice, causing
> use-after-free KASAN bug reports, among others.
>
> Reported independently by both trinity and syzkaller.
> Verified that the syzkaller reproducer passes after this patch.
>

I forgot to add the Fixes tag, sorry.

Fixes: dc99f600698d ("packet: Add fanout support.")

> Reported-by: nixioaming <nixiaoming@huawei.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>
