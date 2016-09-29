From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 4/5] xps_flows: XPS for packets that don't
 have a socket
Date: Wed, 28 Sep 2016 21:54:11 -0700
Message-ID: <1475124851.28155.135.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160929035428.204355-1-tom@herbertland.com>
         <20160929035428.204355-5-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com,
        rick.jones2@hpe.com, alexander.duyck@gmail.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36375 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753065AbcI2EyR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 00:54:17 -0400
Received: by mail-pa0-f67.google.com with SMTP id cd13so1075533pac.3
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 21:54:16 -0700 (PDT)
In-Reply-To: <20160929035428.204355-5-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-09-28 at 20:54 -0700, Tom Herbert wrote:
> xps_flows maintains a per device flow table that is indexed by the
> skbuff hash. The table is only consulted when there is no queue saved in
> a transmit socket for an skbuff.
> 
> Each entry in the flow table contains a queue index and a queue
> pointer. The queue pointer is set when a queue is chosen using a
> flow table entry. This pointer is set to the head pointer in the
> transmit queue (which is maintained by BQL).
> 
> The new function get_xps_flows_index that looks up flows in the
> xps_flows table. The entry returned gives the last queue a matching flow
> used. The returned queue is compared against the normal XPS queue. If
> they are different, then we only switch if the tail pointer in the TX
> queue has advanced past the pointer saved in the entry. In this
> way OOO should be avoided when XPS wants to use a different queue.

There is something I do not understand with this.

If this OOO avoidance is tied to BQL, it means that packets sitting in a
qdisc wont be part of the detection.

So packets of flow X could possibly be queued on multiple qdiscs.
