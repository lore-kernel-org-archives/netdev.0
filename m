From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: Regression on TX throughput when using bonding
Date: Thu, 14 Jun 2012 17:43:58 +0200
Message-ID: <CAL8zT=joBA5pgXB7QfDM5qhOizmdneghXsSnwN5G74-yoGzg_Q@mail.gmail.com>
References: <CAL8zT=j8pEVc7AHwJzk+4skj=1tfRYZ_C7CuXD_08T_VmkwoFg@mail.gmail.com>
 <1339665719.22704.692.camel@edumazet-glaptop> <1339667417.22704.707.camel@edumazet-glaptop>
 <CAL8zT=icffEiz9MeaNwMtzteQnXiaT4k++s0TPWt5zsnHxFbmw@mail.gmail.com>
 <CAL8zT=huqtqBKzH3DDwid_C8jH16SH=kjYEK6zjxp_spfnLxXA@mail.gmail.com> <1339684157.22704.722.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:47038 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756057Ab2FNPoV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 11:44:21 -0400
Received: by wibhn6 with SMTP id hn6so2094358wib.1
        for <netdev@vger.kernel.org>; Thu, 14 Jun 2012 08:44:20 -0700 (PDT)
In-Reply-To: <1339684157.22704.722.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/6/14 Eric Dumazet <eric.dumazet@gmail.com>:
> On Thu, 2012-06-14 at 16:14 +0200, Jean-Michel Hautbois wrote:
>
>> ~# tc -s -d qdisc show dev eth1 > before_tc && sleep 10 && tc -s -d
>> qdisc show dev eth1 > after_tc && ./beforeafter before_tc after_tc
>> qdisc mq 0: root
>> =C2=A0Sent 3185900568 bytes 788681 pkt (dropped 0, overlimits 0 requ=
eues 620)
>> =C2=A0backlog 0b 0p requeues 620
>>
>> As you can see, 2.5Gbps without any difficulties :).
>>
>> Thanks,
>> JM
>
> I have no idea why throughput on ethernet link is changed.
>
> There is another bug elsewhere. =C2=A0Use a thousand of sockets inste=
ad of
> few, and you'll hit the bug.
>
> Orphaning skbs should not lower speed of the device, only drops exces=
s
> packets, instead of blocking the application, waiting the socket wmem
> alloc being freed by destructors.
>
> Are you playing with process priorities ?
>
> If the ksoftirqd cannot run, this could explain the problem.
>

As suggested by Eric, here is a description I wish to be as precise as =
possible.
I send three RAW video frames, 1920x1088@30fps on three udp sockets to
the same NIC.
Each sending is in a thread, so I will focus on the numbers for one thr=
ead.

This generates burst of send(), as this : each 1/30s send 3.133.440
bytes to the ethernet interface.
This is in fact something similar to this :
while (n !=3D 0)
{
  sendto(socket, packet, 4000);
  n -=3D 4000;
  packet +=3D 4000
}

My interface is a bond with a 10Gbps interface and MTU set to 4096.
This means I have 784 packets each 1/30s which are sent on my
interface by one thread, then I wait for the next burst, and so on.
The videos are not necessarily the same video, so the threads may send
simultaneously or not...

My socket is in blocking mode.

JM
