From: Andrew <nitr0@seti.kr.ua>
Subject: Re: HTB, HFSC, PIE, FIFO stuck on 2.4Gbit on default values
Date: Tue, 3 Nov 2015 23:04:08 +0200
Message-ID: <56392148.4090309@seti.kr.ua>
References: <14bd7629199800f798c8ab932e0285d3@visp.net.lb>
 <1446577894.23275.71.camel@edumazet-glaptop2.roam.corp.google.com>
 <907cb54c0a27beed12381247ba29bca5@visp.net.lb>
 <1446580156.23275.74.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.seti.kr.ua ([91.202.132.4]:38405 "EHLO mail.seti.kr.ua"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932525AbbKCVEN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2015 16:04:13 -0500
Received: from [91.202.135.243] (helo=[192.168.0.145])
	by mail.seti.kr.ua with esmtpa (Exim 4.68)
	(envelope-from <nitr0@seti.kr.ua>)
	id 1ZtikT-00047s-2C
	for netdev@vger.kernel.org; Tue, 03 Nov 2015 23:04:10 +0200
In-Reply-To: <1446580156.23275.74.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

This is common trouble due to hierarchical shapers realization (global=20
tree lock on packet dequeuing - so when one CPU looks for parent class=20
where tokens can be borrowed, other CPUs are waiting). It's mentioned=20
even in academic publications :) You can read about it here:=20
http://www.ijcset.com/docs/IJCSET13-04-04-113.pdf

I think that simple lock removing will greatly improve performance; and=
=20
race conditions on packets dequeuing shouldn't hurt anything except=20
shaping accuracy. Another solutions looks more complex.

03.11.2015 21:49, Eric Dumazet =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Tue, 2015-11-03 at 21:17 +0200, Denys Fedoryshchenko wrote:
>>   GSO/TSO on the output and watch performance coming back.
>>
>> It is not, since i have more than 120 servers installed over country
>> (most of them handle small traffic), in forwarding mode, first thing=
 i
>> am doing on forwarding setup - disabling gro/gso/tso. It is helped a=
lso
>> many ISP on their forum where i visit often, first thing in
>> troubleshooting unreliable network traffic forwarding - disabling
>> offloading.
>> Because problem starts from incorrect shaping, and ends in some case=
s
>> with network drivers spitting watchdog errors. Sometimes even shaper=
 not
>> necessary, just plain forwarding with offload enabled can cause issu=
es,
>> but it might be bug in networking drivers.
>> Should i try to reproduce and report? Sure if anybody can look into =
this
>> issue.
>
> Well, I am telling you.
>
> Say no to people advising to turn off GRO/TSO.
>
> If you were the guy adviding others to do so, it is time to see the
> light.
>
> Lets fix the bugs if any, instead of spreading disinformation.
>
> I am so tired of telling these very simple facts guys.
>
> If you prefer, continue to work on linux-2.0 but don't ask help on
> netdev.
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
