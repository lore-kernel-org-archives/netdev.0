From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net-next RFC 0/4] net: sched: allow qdiscs to share filter
 block instances
Date: Tue, 11 Jul 2017 09:57:30 +0300
Message-ID: <CAJ3xEMjmWvenFqjZayFvKMbJ3WsSJovkOVybBP0MWLnK6VNjJw@mail.gmail.com>
References: <20170710185110.3180-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Jiri Benc <jbenc@redhat.com>, mlxsw <mlxsw@mellanox.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roman Mashak <mrv@mojatatu.com>,
        Paul Blakey <paulb@mellanox.com>,
        Mark Bloch <markb@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:35626 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932297AbdGKG5b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 02:57:31 -0400
Received: by mail-oi0-f65.google.com with SMTP id l130so14553367oib.2
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 23:57:31 -0700 (PDT)
In-Reply-To: <20170710185110.3180-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 10, 2017 at 9:51 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Currently the filters added to qdiscs are independent. So for example if you
> have 2 netdevices and you create ingress qdisc on both and you want to add
> identical filter rules both, you need to add them twice. This patchset
> makes this easier and mainly saves resources allowing to share all filters
> within a qdisc - I call it a "filter block". Also this helps to save
> resources when we do offload to hw for example to expensive TCAM.

[...]


> Now we can add filter to any of qdiscs sharing the same block:
> $ tc filter add dev ens7 parent ffff: protocol ip pref 25 flower dst_ip 192.168.0.0/16 action drop

> We will see the same output if we list filters for ens7 and ens8, including stats:

yeah, but the stats belong to the action, not the filter, right? so you create
here actually a shared action? or you also introduced in that series stats
for filters, I am confused...

Or.
