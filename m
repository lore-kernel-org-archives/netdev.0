From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v2 net-next 4/5] xps_flows: XPS for packets that don't
 have a socket
Date: Thu, 29 Sep 2016 08:53:48 -0400
Message-ID: <CALx6S36FsjSioksB+O7Lp7-7PcC8iMc9LWqWiFr8RzFJ=GkKGQ@mail.gmail.com>
References: <20160929035428.204355-1-tom@herbertland.com> <20160929035428.204355-5-tom@herbertland.com>
 <1475124851.28155.135.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Rick Jones <rick.jones2@hpe.com>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35350 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750700AbcI2Mxu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 08:53:50 -0400
Received: by mail-qt0-f193.google.com with SMTP id 38so2248746qte.2
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 05:53:50 -0700 (PDT)
In-Reply-To: <1475124851.28155.135.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 29, 2016 at 12:54 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-09-28 at 20:54 -0700, Tom Herbert wrote:
>> xps_flows maintains a per device flow table that is indexed by the
>> skbuff hash. The table is only consulted when there is no queue saved in
>> a transmit socket for an skbuff.
>>
>> Each entry in the flow table contains a queue index and a queue
>> pointer. The queue pointer is set when a queue is chosen using a
>> flow table entry. This pointer is set to the head pointer in the
>> transmit queue (which is maintained by BQL).
>>
>> The new function get_xps_flows_index that looks up flows in the
>> xps_flows table. The entry returned gives the last queue a matching flow
>> used. The returned queue is compared against the normal XPS queue. If
>> they are different, then we only switch if the tail pointer in the TX
>> queue has advanced past the pointer saved in the entry. In this
>> way OOO should be avoided when XPS wants to use a different queue.
>
> There is something I do not understand with this.
>
> If this OOO avoidance is tied to BQL, it means that packets sitting in a
> qdisc wont be part of the detection.
>
> So packets of flow X could possibly be queued on multiple qdiscs.
>
Hi Eric,

I'm not sure I understand your concern. If packets for flow X can be
queued on multiple qdiscs wouldn't that mean that flow will be subject
to ooo transmission regardless of this patch? In other words here
we're trying to keep packets for the flow in order as they are emitted
from the qdiscs which we assume maintains ordering of packets in a
flow.

Tom

>
>
