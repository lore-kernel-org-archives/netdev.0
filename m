From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: do not underestimate skb->truesize in
 tcp_trim_head()
Date: Fri, 28 Apr 2017 16:05:56 -0400 (EDT)
Message-ID: <20170428.160556.2072008893563794166.davem@davemloft.net>
References: <1493222866.6453.75.camel@edumazet-glaptop3.roam.corp.google.com>
        <1493252140.6453.96.camel@edumazet-glaptop3.roam.corp.google.com>
        <CAAeHK+xWDnPu05g4Hqt3wkHEsuW=Ry7p7rLnxL3ct1MuSLBXLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: andreyknvl@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58616 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S642453AbdD1UF6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 16:05:58 -0400
In-Reply-To: <CAAeHK+xWDnPu05g4Hqt3wkHEsuW=Ry7p7rLnxL3ct1MuSLBXLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 27 Apr 2017 13:49:57 +0200

> On Thu, Apr 27, 2017 at 2:15 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> Andrey found a way to trigger the WARN_ON_ONCE(delta < len) in
>> skb_try_coalesce() using syzkaller and a filter attached to a TCP
>> socket over loopback interface.
>>
>> I believe one issue with looped skbs is that tcp_trim_head() can end up
>> producing skb with under estimated truesize.
>>
>> It hardly matters for normal conditions, since packets sent over
>> loopback are never truncated.
>>
>> Bytes trimmed from skb->head should not change skb truesize, since
>> skb->head is not reallocated.
> 
> Hi Eric,
> 
> With all 3 of your patches applied to net-next I don't see the warning any more.
> 
> Thanks!
> 
> Tested-by: Andrey Konovalov <andreyknvl@google.com>

Applied and queued up for -stable, thanks Eric.
