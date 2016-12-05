From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH v2 net-next 7/8] net: reorganize struct sock for better
 data locality
Date: Mon, 05 Dec 2016 13:36:24 +0100
Message-ID: <1480941384.4694.13.camel@redhat.com>
References: <1480792497-16607-1-git-send-email-edumazet@google.com>
         <1480792497-16607-8-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60334 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750951AbcLEMg0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Dec 2016 07:36:26 -0500
In-Reply-To: <1480792497-16607-8-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Sat, 2016-12-03 at 11:14 -0800, Eric Dumazet wrote:
> Group fields used in TX path, and keep some cache lines mostly read
> to permit sharing among cpus.
> 
> Gained two 4 bytes holes on 64bit arches.
> 
> Added a place holder for tcp tsq_flags, next to sk_wmem_alloc
> to speed up tcp_wfree() in the following patch.
> 
> I have not added ____cacheline_aligned_in_smp, this might be done later.
> I prefer doing this once inet and tcp/udp sockets reorg is also done.
> 
> Tested with both TCP and UDP.
> 
> UDP receiver performance under flood increased by ~20 % :
> Accessing sk_filter/sk_wq/sk_napi_id no longer stalls because sk_drops
> was moved away from a critical cache line, now mostly read and shared.

I cherry-picked this patch only for some UDP benchmark. Under flood with
many concurrent flows, I see this 20% improvement and a relevant
decrease in system load.

Nice work, thanks Eric!

Tested-by: Paolo Abeni <pabeni@redhat.com>
