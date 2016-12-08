From: Josef Bacik <jbacik@fb.com>
Subject: Re: Soft lockup in inet_put_port on 4.6
Date: Thu, 8 Dec 2016 16:36:56 -0500
Message-ID: <1481233016.11849.1@smtp.office365.com>
References: <CALx6S36OVUqAxq9vNnfHp2eJOuG+gSSg896zzaZoc3Og4tyxFw@mail.gmail.com>
        <1481231024.1911284.813071977.72AF4DEE@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Cc: Tom Herbert <tom@herbertland.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:38259 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752186AbcLHVhz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 16:37:55 -0500
In-Reply-To: <1481231024.1911284.813071977.72AF4DEE@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 8, 2016 at 4:03 PM, Hannes Frederic Sowa 
<hannes@stressinduktion.org> wrote:
> Hello Tom,
> 
> On Wed, Dec 7, 2016, at 00:06, Tom Herbert wrote:
>>  We are seeing a fair number of machines getting into softlockup in 
>> 4.6
>>  kernel. As near as I can tell this is happening on the spinlock in
>>  bind hash bucket. When inet_csk_get_port exits and does 
>> spinunlock_bh
>>  the TCP timer runs and we hit lockup in inet_put_port (presumably on
>>  same lock). It seems like the locked isn't properly be unlocked
>>  somewhere but I don't readily see it.
>> 
>>  Any ideas?
> 
> Likewise we received reports that pretty much look the same on our
> heavily patched kernel. Did you have a chance to investigate or
> reproduce the problem?
> 
> I am wondering if you would be able to take a complete thread stack 
> dump
> if you can reproduce this to check if one of the user space processes 
> is
> looping inside finding a free port?

We can reproduce the problem at will, still trying to run down the 
problem.  I'll try and find one of the boxes that dumped a core and get 
a bt of everybody.  Thanks,

Josef
