From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH 1/2] mpls: add handlers
Date: Tue, 15 Aug 2017 22:30:21 -0700
Message-ID: <CAJieiUhp57grbrzNcdyJj+_iKp=rusLfrJjsRPfebAUFEqy89A@mail.gmail.com>
References: <1502396917-14848-1-git-send-email-amine.kherbouche@6wind.com>
 <1502396917-14848-2-git-send-email-amine.kherbouche@6wind.com>
 <20170811123405.GY773745@eidolon> <CAJieiUiDN0pk2GDb2+jBQzbjdPTpckSm23SCFGZ9mRHWfQ1H4w@mail.gmail.com>
 <c6fc221b-c0fa-1dbc-d1e2-a746b722dcd7@6wind.com> <CAJieiUijsyWjzNL=oFaGxtuos367v0VrpSaEqwHvVacrk5hcTA@mail.gmail.com>
 <20170815093745.GC773745@eidolon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Amine Kherbouche <amine.kherbouche@6wind.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f169.google.com ([209.85.217.169]:33768 "EHLO
        mail-ua0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750912AbdHPFaW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 01:30:22 -0400
Received: by mail-ua0-f169.google.com with SMTP id r9so720565uad.0
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 22:30:22 -0700 (PDT)
In-Reply-To: <20170815093745.GC773745@eidolon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 15, 2017 at 2:37 AM, David Lamparter <equinox@diac24.net> wrote:

[snip]

> I think the reverse is the better option, removing the vpls device
> information and just going with the route table.  My approach to this
> would be to add a new netlink route attribute "RTA_VPLS" which
> identifies the vpls device, is stored in the route table, and provides
> the device ptr needed here.
> (The control word config should also be on the route.)
>
> My reason for thinking this is that the VPLS code needs exactly the same
> information as does a normal MPLS route:  it attaches to an incoming
> label (decapsulating packets instead of forwarding them), and for TX it
> does the same operation of looking up a nexthop (possibly with ECMP
> support) and adding a label stack.  The code should, in fact, probably
> reuse the TX path.
>
> This also fits both an 1:1 and 1:n model pretty well.  Creating a VPLS
> head-end netdevice doesn't even need any config.  It'd just work like:
> - ip link add name vpls123 type vpls
> - ip -f mpls route add \
>         1234 \                              # incoming label for decap
>         vpls vpls123 \                      # new attr: VPLS device
>         as 2345 via inet 10.0.0.1 dev eth0  # outgoing label for encap
>
> For a 1:n model, one would simply add multiple routes on the same vpls
> device.
>

this is a nice model too. But, i don't see how vlans and mac based
learning will fit in here.

modeling it same as how vxlan l2 overlay tunnels are done seems like a
great fit.
The vpls driver can learn mac's per pw tunnel labels. And this l2 fdb
table per vpls device can also carry dst information similar to how
vxlan driver does today.
