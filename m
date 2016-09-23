From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] softirq: let ksoftirqd do its job
Date: Fri, 23 Sep 2016 13:35:59 +0200
Message-ID: <57E5139F.5040708@iogearbox.net>
References: <20160831164216.2901190c@redhat.com>        <1472661956.14381.335.camel@edumazet-glaptop3.roam.corp.google.com>        <1472665349.14381.356.camel@edumazet-glaptop3.roam.corp.google.com> <20160901.233913.237544263411665891.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, riel@redhat.com, pabeni@redhat.com,
        hannes@redhat.com, jbrouer@redhat.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        corbet@lwn.net
To: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35256 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758882AbcIWLgL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 07:36:11 -0400
In-Reply-To: <20160901.233913.237544263411665891.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/2016 08:39 AM, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 31 Aug 2016 10:42:29 -0700
>
>> From: Eric Dumazet <edumazet@google.com>
>>
>> A while back, Paolo and Hannes sent an RFC patch adding threaded-able
>> napi poll loop support : (https://patchwork.ozlabs.org/patch/620657/)
>>
>> The problem seems to be that softirqs are very aggressive and are often
>> handled by the current process, even if we are under stress and that
>> ksoftirqd was scheduled, so that innocent threads would have more chance
>> to make progress.
>>
>> This patch makes sure that if ksoftirq is running, we let it
>> perform the softirq work.
>>
>> Jonathan Corbet summarized the issue in https://lwn.net/Articles/687617/
>>
>> Tested:
>>
>>   - NIC receiving traffic handled by CPU 0
>>   - UDP receiver running on CPU 0, using a single UDP socket.
>>   - Incoming flood of UDP packets targeting the UDP socket.
>>
>> Before the patch, the UDP receiver could almost never get cpu cycles and
>> could only receive ~2,000 packets per second.
>>
>> After the patch, cpu cycles are split 50/50 between user application and
>> ksoftirqd/0, and we can effectively read ~900,000 packets per second,
>> a huge improvement in DOS situation. (Note that more packets are now
>> dropped by the NIC itself, since the BH handlers get less cpu cycles to
>> drain RX ring buffer)
>>
>> Since the load runs in well identified threads context, an admin can
>> more easily tune process scheduling parameters if needed.
>>
>> Reported-by: Paolo Abeni <pabeni@redhat.com>
>> Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>
> I'm just kind of assuming this won't go through my tree, but I can take
> it if that's what everyone agrees to.

Was this actually picked up somewhere in the mean time?
