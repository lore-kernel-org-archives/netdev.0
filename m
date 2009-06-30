From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: tc filter flow hash question
Date: Tue, 30 Jun 2009 13:18:42 +0400
Message-ID: <4A49D872.5050403@bigtelecom.ru>
References: <20090630085706.GD5589@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:60735 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893AbZF3JSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 05:18:40 -0400
In-Reply-To: <20090630085706.GD5589@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 30-06-2009 10:12, Badalian Vyacheslav wrote:
>  =20
>> Hello all.
>> Sorry for mail to this maillist, but in internet i can't found any
>> information to understand this situation, lartc list is dead, functi=
on
>> do not documented and only developers understand how it works.
>>    =20
>
> They only pretend they understand how it works...
>
>  =20
>> As i understand if i add flow hash i divide speed to KEYs (example t=
o
>> dst) not for sessions right?
>>
>> Why if i add simple example my traffic stop and i get DROP at parent=
 class?
>>
>> This my sample
>>
>> tc qdisc add dev eth0 root handle 1 htb default 7
>> class add dev eth0 parent 1: classid 1:7 htb rate 500mbit ceil 1000m=
bit
>> prio 3
>> qdisc add dev eth0 parent 1:7 handle 10: sfq perturb 10
>> # all normal
>> tc filter add dev eth0 protocol ip parent 10: handle 2 flow hash key=
s
>> src,dst
>> # all traffic drop
>>
>>    =20
>
>  =20
Yep. I was read this commit and create example based on it.
My question why its drop all traffic after add flow filter? Its simple
must group traffic to sfq qidsc by HASH like equal cost routing by KEY
if i understand. I need balance traffic in class/qdisc by KEY, but not
by sessions.

Any worked example will be great. In commit i see only syntax :)

Thanks!

> Here are some hints (if we don't mention google ;-)
> http://git.kernel.org/?p=3Dlinux/kernel/git/stable/linux-2.6.29.y.git=
;a=3Dcommitdiff;h=3De5dfb815181fcb186d6080ac3a091eadff2d98fe
>
> Regards,
> Jarek P.
>
>
>  =20

