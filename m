From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/5] nfp: make use of the
 DMA_ATTR_SKIP_CPU_SYNC attr
Date: Fri, 21 Apr 2017 15:37:45 -0400 (EDT)
Message-ID: <20170421.153745.1563910787910746446.davem@davemloft.net>
References: <20170421142052.107388-1-jakub.kicinski@netronome.com>
        <20170421142052.107388-2-jakub.kicinski@netronome.com>
        <CAKgT0UfdbLV9tdYZXVQK6U2cF1Ljzc27uuVoNaZF-rHcmLUnPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        oss-drivers@netronome.com, kubakici@wp.pl
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37566 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425299AbdDUThq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:37:46 -0400
In-Reply-To: <CAKgT0UfdbLV9tdYZXVQK6U2cF1Ljzc27uuVoNaZF-rHcmLUnPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 21 Apr 2017 08:07:45 -0700

> On Fri, Apr 21, 2017 at 7:20 AM, Jakub Kicinski
> <jakub.kicinski@netronome.com> wrote:
>> DMA unmap may destroy changes CPU made to the buffer.  To make XDP
>> run correctly on non-x86 platforms we should use the
>> DMA_ATTR_SKIP_CPU_SYNC attribute.
>>
>> Thanks to using the attribute we can now push the sync operation to
>> the common code path from XDP handler.
>>
>> A little bit of variable name reshuffling is required to bring the
>> code back to readable state.
>>
>> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> 
> So I see where you added the sync_single_for_cpu, but what about the
> sync_single_for_device? It needs to be called for the buffer before
> you assign it for Rx. On x86 it won't really matter but for proper
> utilization of the DMA API you need to sync the buffer even for Rx
> just to make certain that the cache lines are evicted prior to the
> device attempting to write to the buffer.

Agreed, a sync before giving the buffer to the device is necessary.
