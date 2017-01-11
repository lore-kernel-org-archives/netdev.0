From: "Jonathan T. Leighton" <jtleight@udel.edu>
Subject: Re: TCP using IPv4-mapped IPv6 address as source
Date: Wed, 11 Jan 2017 14:48:30 -0500
Message-ID: <14f352f9-6c0a-17da-f28f-b23fe8ecd2a2@udel.edu>
References: <87f4e2ec-22bf-2401-8401-57205f893289@udel.edu>
 <1484151607.21472.55.camel@edumazet-glaptop3.roam.corp.google.com>
 <d8df0fb3-6053-10e1-fc43-cccbfc3799bf@udel.edu>
 <1484159519.21472.72.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:36056 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932966AbdAKTtP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 14:49:15 -0500
Received: by mail-qk0-f182.google.com with SMTP id 11so121723146qkl.3
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 11:48:33 -0800 (PST)
In-Reply-To: <1484159519.21472.72.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 1/11/17 1:31 PM, Eric Dumazet wrote:
> On Wed, 2017-01-11 at 12:34 -0500, Jonathan T. Leighton wrote:
>> On 1/11/17 11:20 AM, Eric Dumazet wrote:
>>> On Thu, 2017-01-05 at 16:25 -0500, Jonathan T. Leighton wrote:
>>>> I've observed TCP using an IPv4-mapped IPv6 address as the source
>>>> address, which I believe contradicts
>>>> https://tools.ietf.org/html/rfc6890#page-14 (BCP 153). This occurs when
>>>> an IPv6 TCP socket, bound to a local IPv4-mapped IPv6 address, attempts
>>>> to connect to a remote IPv6 address. Presumable connect() should return
>>>> EAFNOSUPPORT in this case. Please advise me if this is not to
>>>> appropriate list to report this.
>>> Hi Jonathan
>>>
>>> I believe your concern makes sense.
>>> Do you have a patch to address this issue ?
>> Thanks for responding Eric. I have limited experience with kernel
>> patches. Nevertheless, unless there's someone with the experience and
>> time to jump on this, I'm interested in taking a crack at it. I think
>> the issue certainly warrants attention: instead of returning immediately
>> with EAFNOSUPPPORT, connect() retransmits its SYN 6 times, ultimately
>> returning ETIMEDOUT after 127 sec (1+2+4+...+64).
> I am not aware of an application trying to perform a bind() to an IPV4
> address before a connect() to an IPv6 destination.
>
> A kernel fix is certainly something that would detect application bugs
> in a more friendly way.

I would say that an IPv6 socket binds to an IPv4-mapped IPv6 address, 
but yes - using it to connect to an IPv6 address would be an application 
bug. It also think that having connect() spend 2 minutes sending packets 
containing an illegal source address is a bug. (And unfriendly!) I'll 
look into writing a patch for this, and let you know whether or not I 
think I'm up to it.

- Jon

> Thanks !
>
>
