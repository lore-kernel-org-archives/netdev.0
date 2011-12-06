From: Dave Taht <dave.taht@gmail.com>
Subject: Re: Latency difference between fifo and pfifo_fast
Date: Tue, 6 Dec 2011 19:39:13 +0100
Message-ID: <CAA93jw4rRsp0t0g4E0YOB=_N-rvTXj9aY+2qfN5hGXvi6R0auw@mail.gmail.com>
References: <03369d06-ee52-4eef-a8b6-5a21e6d56840@jasiiieee>
	<1323161496.2448.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<4EDE5D09.1060404@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John A. Sullivan III" <jsullivan@opensourcedevel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:42765 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776Ab1LFSjQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 13:39:16 -0500
Received: by eaak14 with SMTP id k14so5442635eaa.19
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2011 10:39:15 -0800 (PST)
In-Reply-To: <4EDE5D09.1060404@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 6, 2011 at 7:20 PM, Rick Jones <rick.jones2@hp.com> wrote:
> On 12/06/2011 12:51 AM, Eric Dumazet wrote:
>>
>> Le mardi 06 d=E9cembre 2011 =E0 03:39 -0500, John A. Sullivan III a =
=E9crit :
>>
>>>> ifconfig eth2 txqueuelen 0
>>>> tc qdisc add dev eth2 root pfifo
>>>> tc qdisc del dev eth2 root
>>>>
>>>>
>>>>
>>>>
>>> Really? I didn't know one could do that. =A0Thanks. =A0However, wit=
h no
>>> queue length, do I have a significant risk of dropping packets? To
>>> answer your other response's question, these are Intel quad port e1=
000
>>> cards. =A0We are frequently pushing them to near line speed so
>>> 1,000,000,000 / 1534 / 8 =3D 81,486 pps - John
>>
>>
>> You can remove qdisc layer, since NIC itself has a TX ring queue
>>
>> (check exact value with ethtool -g ethX)
>>
>> # ethtool -g eth2
>> Ring parameters for eth2:
>> Pre-set maximums:
>> RX: =A0 =A0 =A0 =A0 =A0 =A0 4078
>> RX Mini: =A0 =A0 =A0 =A00
>> RX Jumbo: =A0 =A0 =A0 0
>> TX: =A0 =A0 =A0 =A0 =A0 =A0 4078
>> Current hardware settings:
>> RX: =A0 =A0 =A0 =A0 =A0 =A0 254
>> RX Mini: =A0 =A0 =A0 =A00
>> RX Jumbo: =A0 =A0 =A0 0
>> TX: =A0 =A0 =A0 =A0 =A0 =A0 4078 =A0 =A0 =A0---- HERE ----
>
>
> And while you are down at the NIC, if every microsecond is precious (=
no
> matter how close to epsilon compared to the latencies of spinning rus=
t :)
> you might consider disabling interrupt coalescing via ethtool -C.
>
> rick jones

Ya know, me being me, and if latency is your real problem, I can't help
but think you'd do better by reducing those tx queues enormously,
applying QFQ and maybe something like RED on top, would balance
out the differences between flows and result in a net benefit.

I realize that you are struggling to achieve line rate in the first pla=
ce...

but from where I sit (with asbestos suit on), it would be an interestin=
g
experiment. (I have no data on how much cpu this stuff uses at these
sort of speeds)

>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
