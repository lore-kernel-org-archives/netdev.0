From: Dominik Kaspar <dokaspar.ietf@gmail.com>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Tue, 26 Apr 2011 20:00:11 +0200
Message-ID: <BANLkTikjcd6ZAF5wH_8CKA_OCrfprGokmw@mail.gmail.com>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com>
	<1303730701.2747.110.camel@edumazet-laptop>
	<BANLkTi=xns1Gdjyt-SX3yDETSQfO23rXXg@mail.gmail.com>
	<1303745915.2747.151.camel@edumazet-laptop>
	<BANLkTikcn832pXzxPjM032ZuRi8o0SQ++Q@mail.gmail.com>
	<1303837801.3358.65.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Carsten Wolff <carsten@wolffcarsten.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:51037 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757756Ab1DZSAM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 14:00:12 -0400
Received: by iwn34 with SMTP id 34so716684iwn.19
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 11:00:12 -0700 (PDT)
In-Reply-To: <1303837801.3358.65.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Here are the tcpdump files for the first TSO-disabled experiment, in a
full version and a short version with only the first 10000 packets:

http://home.simula.no/~kaspar/static/mptcp-emu-wlan-hspa-01-tos0-exp1-f=
ull.pcap
http://home.simula.no/~kaspar/static/mptcp-emu-wlan-hspa-01-tos0-exp1-s=
hort.pcap

By the way, the packets are sent from the server (x.x.x.189) to the
client interfaces (x.x.x.74) and (x.x.x.216) with the following
pattern (which is a non-bursty 128-bit approximation of scheduling
with a 600:400 ratio over primary path 0 and secondary path 1):

0010010100101001010010100101001010010100101001010010100101001010
0101001010010100101001010010100101001010010100101001010010100101

Greetings,
Dominik

On Tue, Apr 26, 2011 at 7:10 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 26 avril 2011 =E0 18:58 +0200, Dominik Kaspar a =E9crit :
>> Hi Eric,
>>
>> On Mon, Apr 25, 2011 at 5:38 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>> >
>> > Since you have at sender a rule to spoof destination address of pa=
ckets,
>> > you should make sure you dont send "super packets (up to 64Kbytes)=
",
>> > because it would stress the multipath more than you wanted to. Thi=
s way,
>> > you send only normal packets (1500 MTU).
>> >
>> > ethtool -K eth0 tso off
>> > ethtool -K eth0 gso off
>> >
>> > I am pretty sure it should help your (atypic) workload.
>>
>> I made new experiments with the exact same multipath setup as before=
,
>> but disabled TSO and GSO on all involved Ethernet interfaces. Howeve=
r,
>> this did not seem to change much about TCP's behavior when packets a=
re
>> striped over heterogeneous paths. You can see the results of four
>> 20-minute experiments on this plot:
>>
>> http://home.simula.no/~kaspar/static/mptcp-emu-wlan-hspa-01-tos0.png
>>
>> Cheers,
>> Dominik
>
> Hi Dominik
>
> Any chance to have a pcap file from sender side, of say first 10.000
> packets ?
>
>
>
>
