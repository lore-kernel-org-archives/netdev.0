From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: Difficulties to get 1Gbps on be2net ethernet card
Date: Wed, 30 May 2012 09:25:46 +0200
Message-ID: <CAL8zT=jHWhDdv-DyXL8XnL8qRc7o-jZfA7ADU-qt54hB5aLyCw@mail.gmail.com>
References: <CAL8zT=hHAc5-wGMKgumV=K9jG6tDxzej9Dffe9UYQ24gdWQRtw@mail.gmail.com>
 <CAL8zT=jKhRjVCdYRCerMzimxPAhP5Gi+JBBfuKjG-rfg-LMoVw@mail.gmail.com>
 <1338360536.2760.85.camel@edumazet-glaptop> <CAL8zT=h2hoTWDMpTe8P-xfm-USXD6spx8fFVmm1UXyOfuuqhZw@mail.gmail.com>
 <1338361587.2760.94.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:40882 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756857Ab2E3H0H convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 03:26:07 -0400
Received: by wibhj8 with SMTP id hj8so3523712wib.1
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 00:26:06 -0700 (PDT)
In-Reply-To: <1338361587.2760.94.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/5/30 Eric Dumazet <eric.dumazet@gmail.com>:
> On Wed, 2012-05-30 at 08:51 +0200, Jean-Michel Hautbois wrote:
>> 2012/5/30 Eric Dumazet <eric.dumazet@gmail.com>:
>> > On Wed, 2012-05-30 at 08:28 +0200, Jean-Michel Hautbois wrote:
>> >
>> >> If this can help, setting tx queue length to 5000 seems to make t=
he
>> >> problem disappear.
>> >
>> > Then you should have drops at Qdisc layer (before your change to 5=
000)
>> >
>> > tc -s -d qdisc
>> >
>> >> I didn't specified it : MTU is 4096, UDP packets are 4000 bytes.
>> >
>>
>> Yes :
>> qdisc mq 0: dev eth1 root
>> =C2=A0Sent 5710049154383 bytes 1413544639 pkt (dropped 73078, overli=
mits 0
>> requeues 281540)
>> =C2=A0backlog 0b 0p requeues 281540
>>
>> Why ? With a 2.6.26 kernel it works well with a tx queue length of 1=
000.
>
> If you send big bursts of packets, then you need a large enough queue=
=2E
>
> Maybe your kernel is now faster than before and queue fills faster, o=
r
> TX ring is smaller ?
>
> ethtool -g eth0
>
> Note that everybody try to reduce dumb queue sizes because of latenci=
es.
>

TX ring is not the same :
On 3.2 :
$> ethtool -g eth1
Ring parameters for eth1:
Pre-set maximums:
RX:             1024
RX Mini:        0
RX Jumbo:       0
TX:             2048
Current hardware settings:
RX:             1024
RX Mini:        0
RX Jumbo:       0
TX:             2048


On 2.6.26 :
$>ethtool -g eth1
Ring parameters for eth1:
Pre-set maximums:
RX:             1024
RX Mini:        0
RX Jumbo:       0
TX:             2048
Current hardware settings:
RX:             1003
RX Mini:        0
RX Jumbo:       0
TX:             0

I can't set TX ring using ethtool -G eth1 tx N : operation not supporte=
d
I am not really impacted by latency, but the lower the better.

JM
