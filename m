From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: KS8695: possible NAPI issue
Date: Fri, 5 Mar 2010 11:06:48 +0100
Message-ID: <f69abfc31003050206h4f9ffe65s2b90e6acea014ec2@mail.gmail.com>
References: <f69abfc31003020404y7af77fe5icefeee4644c7d08e@mail.gmail.com>
	 <4B8D1C02.1010204@softplc.com>
	 <c6ed1ac51003021746n2b246591g880b584550ec5e84@mail.gmail.com>
	 <f69abfc31003040210i7e8a136am4b4a97306ba770cf@mail.gmail.com>
	 <c6ed1ac51003042254g27f65f9dhd9bd731e05a9518@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dick Hollenbeck <dick@softplc.com>, netdev@vger.kernel.org,
	zealcook@gmail.com
To: figo zhang <figo1802@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:48188 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754287Ab0CEKGu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 05:06:50 -0500
Received: by ey-out-2122.google.com with SMTP id 25so571316eya.19
        for <netdev@vger.kernel.org>; Fri, 05 Mar 2010 02:06:49 -0800 (PST)
In-Reply-To: <c6ed1ac51003042254g27f65f9dhd9bd731e05a9518@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 5, 2010 at 7:54 AM, figo zhang <figo1802@gmail.com> wrote:
> 2010/3/4 Yegor Yefremov <yegorslists@googlemail.com>:
>>>>> I'm using 2.6.33 kernel and I noticed such a strange behavior:
>>>>>
>>>>> after system start I transfer one file via netcat from my develop=
ment
>>>>> host, after this transfer the network is not functioning i.e. no =
pings
>>>>> possible etc.
>>>>>
>>>>> To narrow down the problem I checked out this commit
>>>>>
>>>>> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.gi=
t;a=3Dcommit;h=3D451f14439847db302e5104c44458b2dbb4b1829d.
>>>>> Till here the network driver is functioning as intended, but afte=
r
>>>>> NAPI introduction I have this issue. With latest git-pull of "Lin=
us'
>>>>> kernel tree" I can't even ping right after the systems start.
>>>>>
>>>>> Any Ideas? What am I missing?
>>>>>
>>>>
>>>> No idea, although I am using the same ARM chip, my kernel is at 2.=
6.30.5,
>>>> and except for this occasional loss of connection I get, the ether=
net driver
>>>> seems to work better than what you are reporting.
>>>
>>> from linux-2.6.32, this ethernet =C2=A0driver have add NAPI support=
, would
>>> you like to
>>> try using this version?
>>
>> Figo, I just looked at the 2.6.32 kernel and found out that it
>> doesn't' contain NAPI support (see the history
>> http://git.kernel.org/?p=3Dlinux/kernel/git/stable/linux-2.6.32.y.gi=
t;a=3Dhistory;f=3Ddrivers/net/arm/ks8695net.c;h=3D2a7b7745cc55b54cefada=
690b0ea47865b54b6b9;hb=3DHEAD).
>> So 2.6.33 is the first stable kernel to support NAPI.
>>
>> I made some further tests but I can't find the reason for network
>> failures: the interrupts are coming and the packets will be received
>> and sent so that rx/tx counters would be increased, but none of them
>> seem to reach the IP stack. I don't know where and why the things ge=
t
>> desynchronized.
>>
>> Could you try the 2.6.33 or Linus tree? Thank you in advance.
>
> yes, i have test it on linux-2.6.33, it is work well.

Thanks for testing. What kind of tests have you made? And with what dat=
a amount?

My tests look like following:

1. system start
2. ping one host: O.K.
3. nc -l -p 5000 > /var/test (about 1Mb): O.K.
4. ping the same host: failed

and even if the fourth test succeeds, if I then send a file from other
host the next ping or any other communication fails. I just tried to
make some SSH sessions. It goes without a problem till I issue a ping
after that.

If I test the system with nuttcp I have no problem.

Do you have any idea how to debug this? If I remove the NAPI support I
have no problem with the same kernel and environment. I'd really like
to get the whole stuff working.

Regards,
Yegor
