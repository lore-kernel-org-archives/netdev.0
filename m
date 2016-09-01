From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/4] xps_flows: XPS flow steering when there is
 no socket
Date: Wed, 31 Aug 2016 17:37:58 -0700
Message-ID: <1472690278.14381.393.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472688605-2613704-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com,
        rick.jones2@hpe.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33244 "EHLO
        mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753623AbcIAAiA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 20:38:00 -0400
Received: by mail-pa0-f50.google.com with SMTP id cy9so23584081pac.0
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 17:38:00 -0700 (PDT)
In-Reply-To: <1472688605-2613704-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-08-31 at 17:10 -0700, Tom Herbert wrote:

> Tested:
>   Manually forced all packets to go through the xps_flows path.
>   Observed that some flows were deferred to change queues because
>   packets were in flight witht the flow bucket.

I did not realize you were ready to submit this new infra !

Please add performance tests and documentation.
( Documentation/networking/scaling.txt should be a nice place ) 

Unconnected UDP packets are candidates to this selection,
even locally generated, while maybe the applications are pinning their
thread(s) to cpu(s)
TX completion will then happen on multiple cpus.

Not sure about af_packet and/or pktgen ?

- The new hash table is vmalloc()ed on a single NUMA node. (in
comparison RFS table (per rx queue) can be properly accessed by a single
cpu servicing queue interrupts)

- Each packet will likely get an additional cache miss in a DDOS
forwarding workload.

Thanks.
