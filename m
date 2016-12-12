From: Josef Bacik <jbacik@fb.com>
Subject: Re: Soft lockup in inet_put_port on 4.6
Date: Mon, 12 Dec 2016 16:23:22 -0500
Message-ID: <1481577802.24490.1@smtp.office365.com>
References: <CALx6S36OVUqAxq9vNnfHp2eJOuG+gSSg896zzaZoc3Og4tyxFw@mail.gmail.com>
        <1481231024.1911284.813071977.72AF4DEE@webmail.messagingengine.com>
        <1481233016.11849.1@smtp.office365.com>
        <1481243432.4930.145.camel@edumazet-glaptop3.roam.corp.google.com>
        <6C6EE0ED-7E78-4866-8AAF-D75FD4719EF3@fb.com>
        <1481335192.3663.0@smtp.office365.com>
        <1481341624.4930.204.camel@edumazet-glaptop3.roam.corp.google.com>
        <1481343298.4930.208.camel@edumazet-glaptop3.roam.corp.google.com>
        <1481565929.24490.0@smtp.office365.com>
        <3c022731-e703-34ac-55f1-60f5b94b6d62@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:41233 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751652AbcLLVXf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 16:23:35 -0500
In-Reply-To: <3c022731-e703-34ac-55f1-60f5b94b6d62@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 12, 2016 at 1:44 PM, Hannes Frederic Sowa 
<hannes@stressinduktion.org> wrote:
> On 12.12.2016 19:05, Josef Bacik wrote:
>>  On Fri, Dec 9, 2016 at 11:14 PM, Eric Dumazet 
>> <eric.dumazet@gmail.com>
>>  wrote:
>>>  On Fri, 2016-12-09 at 19:47 -0800, Eric Dumazet wrote:
>>> 
>>>> 
>>>>   Hmm... Is your ephemeral port range includes the port your load
>>>>   balancing app is using ?
>>> 
>>>  I suspect that you might have processes doing bind( port = 0) that 
>>> are
>>>  trapped into the bind_conflict() scan ?
>>> 
>>>  With 100,000 + timewaits there, this possibly hurts.
>>> 
>>>  Can you try the following loop breaker ?
>> 
>>  It doesn't appear that the app is doing bind(port = 0) during normal
>>  operation.  I tested this patch and it made no difference.  I'm 
>> going to
>>  test simply restarting the app without changing to the SO_REUSEPORT
>>  option.  Thanks,
> 
> Would it be possible to trace the time the function uses with trace? 
> If
> we don't see the number growing considerably over time we probably can
> rule out that we loop somewhere in there (I would instrument
> inet_csk_bind_conflict, __inet_hash_connect and inet_csk_get_port).
> 
> __inet_hash_connect -> __inet_check_established also takes a lock
> (inet_ehash_lockp) which can be locked from inet_diag code path during
> socket diag info dumping.
> 
> Unfortunately we couldn't reproduce it so far. :/

Working on getting the timing info, will probably be tomorrow due to 
meetings.  I did test simply restarting the app without changing to the 
config that enabled the use of SO_REUSEPORT and the problem didn't 
occur, so it definitely has something to do with SO_REUSEPORT.  Thanks,

Josef
