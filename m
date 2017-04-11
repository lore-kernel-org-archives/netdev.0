From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: move padding in struct skb_shared_info
Date: Tue, 11 Apr 2017 10:52:26 -0400 (EDT)
Message-ID: <20170411.105226.1838701404197948502.davem@davemloft.net>
References: <20170410080755.GA24514@avx2>
        <1491835406.10587.12.camel@edumazet-glaptop3.roam.corp.google.com>
        <CACVxJT9ixBPtO4JN=dgLT_gbDOQ8tL_kTFfoYmDahaomatCKEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, steffen.klassert@secunet.com,
        edumazet@google.com, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60200 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752151AbdDKOw2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 10:52:28 -0400
In-Reply-To: <CACVxJT9ixBPtO4JN=dgLT_gbDOQ8tL_kTFfoYmDahaomatCKEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 11 Apr 2017 12:41:08 +0300

> On Mon, Apr 10, 2017 at 5:43 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Mon, 2017-04-10 at 11:07 +0300, Alexey Dobriyan wrote:
>>>  struct skb_shared_info {
>>> -     unsigned short  _unused;
>>>       unsigned char   nr_frags;
>>>       __u8            tx_flags;
>>>       unsigned short  gso_size;
>>
>> Nack
>>
>> This exact placement was discussed at Netconf and Netdev.
>>
>> We had off-by-one errors in the past leading to nr_frags being mangled,
>> and some exploits were quite happy to use these bugs.
>>
>> Some shuffling in shared_info might help us to find other bugs, and give
>> more work to security researchers
> 
> By this logic there should be redzone around every field in networking stack.

It is not a general rule, but a situation we specifically know about
here for this structure and how exploits are actively being coded.

I would like to politely ask that we don't strive so strongly for
"tree wide rules" that we fail to see the need for specific handling
in specific situations as is the case here.

Thank you.
