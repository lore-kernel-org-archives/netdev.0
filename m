From: John Heffner <johnwheffner@gmail.com>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Tue, 26 Apr 2011 16:16:15 -0400
Message-ID: <BANLkTikoQfbSxnJi_OR+N6sa5iVNcTO6Ug@mail.gmail.com>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com>
	<1303730701.2747.110.camel@edumazet-laptop>
	<BANLkTi=xns1Gdjyt-SX3yDETSQfO23rXXg@mail.gmail.com>
	<1303745915.2747.151.camel@edumazet-laptop>
	<BANLkTikcn832pXzxPjM032ZuRi8o0SQ++Q@mail.gmail.com>
	<1303837801.3358.65.camel@edumazet-laptop>
	<BANLkTikjcd6ZAF5wH_8CKA_OCrfprGokmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Carsten Wolff <carsten@wolffcarsten.de>, netdev@vger.kernel.org
To: Dominik Kaspar <dokaspar.ietf@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:38974 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846Ab1DZUQQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 16:16:16 -0400
Received: by eyx24 with SMTP id 24so314826eyx.19
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 13:16:15 -0700 (PDT)
In-Reply-To: <BANLkTikjcd6ZAF5wH_8CKA_OCrfprGokmw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46irst, TCP is definitely not designed to work under such conditions.
=46or example, assumptions behind RTO calculation and fast retransmit
heuristics are violated.  However, in this particular case my first
guess is that you are being limited by "cwnd moderation," which was
the topic of recent discussion here.  Under persistent reordering,
cwnd moderation can inhibit the ability of cwnd to grow.

Thanks,
  -John


On Tue, Apr 26, 2011 at 2:00 PM, Dominik Kaspar <dokaspar.ietf@gmail.co=
m> wrote:
> Hi Eric,
>
> Here are the tcpdump files for the first TSO-disabled experiment, in =
a
> full version and a short version with only the first 10000 packets:
>
> http://home.simula.no/~kaspar/static/mptcp-emu-wlan-hspa-01-tos0-exp1=
-full.pcap
> http://home.simula.no/~kaspar/static/mptcp-emu-wlan-hspa-01-tos0-exp1=
-short.pcap
>
> By the way, the packets are sent from the server (x.x.x.189) to the
> client interfaces (x.x.x.74) and (x.x.x.216) with the following
> pattern (which is a non-bursty 128-bit approximation of scheduling
> with a 600:400 ratio over primary path 0 and secondary path 1):
>
> 0010010100101001010010100101001010010100101001010010100101001010
> 0101001010010100101001010010100101001010010100101001010010100101
>
> Greetings,
> Dominik
>
> On Tue, Apr 26, 2011 at 7:10 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
>> Le mardi 26 avril 2011 =E0 18:58 +0200, Dominik Kaspar a =E9crit :
>>> Hi Eric,
>>>
>>> On Mon, Apr 25, 2011 at 5:38 PM, Eric Dumazet <eric.dumazet@gmail.c=
om> wrote:
>>> >
>>> > Since you have at sender a rule to spoof destination address of p=
ackets,
>>> > you should make sure you dont send "super packets (up to 64Kbytes=
)",
>>> > because it would stress the multipath more than you wanted to. Th=
is way,
>>> > you send only normal packets (1500 MTU).
>>> >
>>> > ethtool -K eth0 tso off
>>> > ethtool -K eth0 gso off
>>> >
>>> > I am pretty sure it should help your (atypic) workload.
>>>
>>> I made new experiments with the exact same multipath setup as befor=
e,
>>> but disabled TSO and GSO on all involved Ethernet interfaces. Howev=
er,
>>> this did not seem to change much about TCP's behavior when packets =
are
>>> striped over heterogeneous paths. You can see the results of four
>>> 20-minute experiments on this plot:
>>>
>>> http://home.simula.no/~kaspar/static/mptcp-emu-wlan-hspa-01-tos0.pn=
g
>>>
>>> Cheers,
>>> Dominik
>>
>> Hi Dominik
>>
>> Any chance to have a pcap file from sender side, of say first 10.000
>> packets ?
>>
>>
>>
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
