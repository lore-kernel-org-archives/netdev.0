From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: KS8695: possible NAPI issue
Date: Thu, 4 Mar 2010 11:10:37 +0100
Message-ID: <f69abfc31003040210i7e8a136am4b4a97306ba770cf@mail.gmail.com>
References: <f69abfc31003020404y7af77fe5icefeee4644c7d08e@mail.gmail.com>
	 <4B8D1C02.1010204@softplc.com>
	 <c6ed1ac51003021746n2b246591g880b584550ec5e84@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dick Hollenbeck <dick@softplc.com>, netdev@vger.kernel.org,
	zealcook@gmail.com
To: figo zhang <figo1802@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:38931 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755217Ab0CDKKl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 05:10:41 -0500
Received: by ewy20 with SMTP id 20so1586494ewy.21
        for <netdev@vger.kernel.org>; Thu, 04 Mar 2010 02:10:40 -0800 (PST)
In-Reply-To: <c6ed1ac51003021746n2b246591g880b584550ec5e84@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> I'm using 2.6.33 kernel and I noticed such a strange behavior:
>>>
>>> after system start I transfer one file via netcat from my developme=
nt
>>> host, after this transfer the network is not functioning i.e. no pi=
ngs
>>> possible etc.
>>>
>>> To narrow down the problem I checked out this commit
>>>
>>> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;=
a=3Dcommit;h=3D451f14439847db302e5104c44458b2dbb4b1829d.
>>> Till here the network driver is functioning as intended, but after
>>> NAPI introduction I have this issue. With latest git-pull of "Linus=
'
>>> kernel tree" I can't even ping right after the systems start.
>>>
>>> Any Ideas? What am I missing?
>>>
>>
>> No idea, although I am using the same ARM chip, my kernel is at 2.6.=
30.5,
>> and except for this occasional loss of connection I get, the etherne=
t driver
>> seems to work better than what you are reporting.
>
> from linux-2.6.32, this ethernet =C2=A0driver have add NAPI support, =
would
> you like to
> try using this version?

=46igo, I just looked at the 2.6.32 kernel and found out that it
doesn't' contain NAPI support (see the history
http://git.kernel.org/?p=3Dlinux/kernel/git/stable/linux-2.6.32.y.git;a=
=3Dhistory;f=3Ddrivers/net/arm/ks8695net.c;h=3D2a7b7745cc55b54cefada690=
b0ea47865b54b6b9;hb=3DHEAD).
So 2.6.33 is the first stable kernel to support NAPI.

I made some further tests but I can't find the reason for network
failures: the interrupts are coming and the packets will be received
and sent so that rx/tx counters would be increased, but none of them
seem to reach the IP stack. I don't know where and why the things get
desynchronized.

Could you try the 2.6.33 or Linus tree? Thank you in advance.

Regards,
Yegor
