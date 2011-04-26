From: Dominik Kaspar <dokaspar.ietf@gmail.com>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Tue, 26 Apr 2011 23:27:52 +0200
Message-ID: <BANLkTim=hdVTD2dkLdPEOcoYvzB=3Z2g6Q@mail.gmail.com>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com>
	<1303730701.2747.110.camel@edumazet-laptop>
	<BANLkTi=xns1Gdjyt-SX3yDETSQfO23rXXg@mail.gmail.com>
	<1303745915.2747.151.camel@edumazet-laptop>
	<BANLkTikcn832pXzxPjM032ZuRi8o0SQ++Q@mail.gmail.com>
	<1303837801.3358.65.camel@edumazet-laptop>
	<BANLkTikjcd6ZAF5wH_8CKA_OCrfprGokmw@mail.gmail.com>
	<BANLkTikoQfbSxnJi_OR+N6sa5iVNcTO6Ug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Carsten Wolff <carsten@wolffcarsten.de>, netdev@vger.kernel.org
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:52731 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932352Ab1DZV1w convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 17:27:52 -0400
Received: by iwn34 with SMTP id 34so867108iwn.19
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 14:27:52 -0700 (PDT)
In-Reply-To: <BANLkTikoQfbSxnJi_OR+N6sa5iVNcTO6Ug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John,

Thanks for your advice. I am very well aware that TCP is not designed
to work under such conditions. I am still surprised how well Linux TCP
handles many situations of excessive, persistent packet reordering. In
scenarios of fairly heterogeneous path characteristics, Linux TCP
aggregates multiple paths close to ideally :-)

If I'm not mistaken, cwnd moderation is a measure to prevent TCP from
sending large bursts if a single ACK covers many segments. In what way
can cwnd moderation prevent TCP from increasing its estimate of packet
reordering?

Greetings,
Dominik

On Tue, Apr 26, 2011 at 10:16 PM, John Heffner <johnwheffner@gmail.com>=
 wrote:
> First, TCP is definitely not designed to work under such conditions.
> For example, assumptions behind RTO calculation and fast retransmit
> heuristics are violated. =A0However, in this particular case my first
> guess is that you are being limited by "cwnd moderation," which was
> the topic of recent discussion here. =A0Under persistent reordering,
> cwnd moderation can inhibit the ability of cwnd to grow.
>
> Thanks,
> =A0-John
>
>
> On Tue, Apr 26, 2011 at 2:00 PM, Dominik Kaspar <dokaspar.ietf@gmail.=
com> wrote:
>> Hi Eric,
>>
>> Here are the tcpdump files for the first TSO-disabled experiment, in=
 a
>> full version and a short version with only the first 10000 packets:
>>
>> http://home.simula.no/~kaspar/static/mptcp-emu-wlan-hspa-01-tos0-exp=
1-full.pcap
>> http://home.simula.no/~kaspar/static/mptcp-emu-wlan-hspa-01-tos0-exp=
1-short.pcap
>>
>> By the way, the packets are sent from the server (x.x.x.189) to the
>> client interfaces (x.x.x.74) and (x.x.x.216) with the following
>> pattern (which is a non-bursty 128-bit approximation of scheduling
>> with a 600:400 ratio over primary path 0 and secondary path 1):
>>
>> 0010010100101001010010100101001010010100101001010010100101001010
>> 0101001010010100101001010010100101001010010100101001010010100101
>>
>> Greetings,
>> Dominik
>>
>> On Tue, Apr 26, 2011 at 7:10 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>>> Le mardi 26 avril 2011 =E0 18:58 +0200, Dominik Kaspar a =E9crit :
>>>> Hi Eric,
>>>>
>>>> On Mon, Apr 25, 2011 at 5:38 PM, Eric Dumazet <eric.dumazet@gmail.=
com> wrote:
>>>> >
>>>> > Since you have at sender a rule to spoof destination address of =
packets,
>>>> > you should make sure you dont send "super packets (up to 64Kbyte=
s)",
>>>> > because it would stress the multipath more than you wanted to. T=
his way,
>>>> > you send only normal packets (1500 MTU).
>>>> >
>>>> > ethtool -K eth0 tso off
>>>> > ethtool -K eth0 gso off
>>>> >
>>>> > I am pretty sure it should help your (atypic) workload.
>>>>
>>>> I made new experiments with the exact same multipath setup as befo=
re,
>>>> but disabled TSO and GSO on all involved Ethernet interfaces. Howe=
ver,
>>>> this did not seem to change much about TCP's behavior when packets=
 are
>>>> striped over heterogeneous paths. You can see the results of four
>>>> 20-minute experiments on this plot:
>>>>
>>>> http://home.simula.no/~kaspar/static/mptcp-emu-wlan-hspa-01-tos0.p=
ng
>>>>
>>>> Cheers,
>>>> Dominik
>>>
>>> Hi Dominik
>>>
>>> Any chance to have a pcap file from sender side, of say first 10.00=
0
>>> packets ?
>>>
>>>
>>>
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>>
>
