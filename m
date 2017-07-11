From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 0/4] net: sched: allow qdiscs to share
 filter block instances
Date: Tue, 11 Jul 2017 09:02:46 +0200
Message-ID: <20170711070246.GA1874@nanopsycho>
References: <20170710185110.3180-1-jiri@resnulli.us>
 <CAJ3xEMjmWvenFqjZayFvKMbJ3WsSJovkOVybBP0MWLnK6VNjJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35647 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754416AbdGKHCu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 03:02:50 -0400
Received: by mail-wr0-f196.google.com with SMTP id z45so30225708wrb.2
        for <netdev@vger.kernel.org>; Tue, 11 Jul 2017 00:02:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMjmWvenFqjZayFvKMbJ3WsSJovkOVybBP0MWLnK6VNjJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jul 11, 2017 at 08:57:30AM CEST, gerlitz.or@gmail.com wrote:
>On Mon, Jul 10, 2017 at 9:51 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> Currently the filters added to qdiscs are independent. So for example if you
>> have 2 netdevices and you create ingress qdisc on both and you want to add
>> identical filter rules both, you need to add them twice. This patchset
>> makes this easier and mainly saves resources allowing to share all filters
>> within a qdisc - I call it a "filter block". Also this helps to save
>> resources when we do offload to hw for example to expensive TCAM.
>
>[...]
>
>
>> Now we can add filter to any of qdiscs sharing the same block:
>> $ tc filter add dev ens7 parent ffff: protocol ip pref 25 flower dst_ip 192.168.0.0/16 action drop
>
>> We will see the same output if we list filters for ens7 and ens8, including stats:
>
>yeah, but the stats belong to the action, not the filter, right? so you create
>here actually a shared action? or you also introduced in that series stats
>for filters, I am confused...

Filters are shared along with all that belongs to them, so including
actions.
