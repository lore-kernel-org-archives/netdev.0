From: Gaspar Chilingarov <gasparch@gmail.com>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge amount
	of outgoing connections (unable to bind ... )
Date: Wed, 21 Apr 2010 05:12:44 +0500
Message-ID: <n2n46c8cb3e1004201712iaccfebdcl619842a555eba56@mail.gmail.com>
References: <g2z46c8cb3e1004201517i5641a75cze2ec5bd33e81fb0f@mail.gmail.com>
	 <4BCE33B9.8050101@candelatech.com>
	 <u2t46c8cb3e1004201620tf9fce087ibae421759f9e1e84@mail.gmail.com>
	 <4BCE392F.60104@candelatech.com>
	 <y2p46c8cb3e1004201635s8f84672dq90d3115dca04a1ed@mail.gmail.com>
	 <4BCE3D8D.3030500@candelatech.com>
	 <1271808314.7895.614.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:41979 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752818Ab0DUAMq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 20:12:46 -0400
Received: by bwz25 with SMTP id 25so7468023bwz.28
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 17:12:45 -0700 (PDT)
In-Reply-To: <1271808314.7895.614.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/4/21 Eric Dumazet <eric.dumazet@gmail.com>:
> Le mardi 20 avril 2010 =C3=A0 16:49 -0700, Ben Greear a =C3=A9crit :
>> On 04/20/2010 04:35 PM, Gaspar Chilingarov wrote:
>> > sysctl -a | grep local_port_range
>>
>> [root@ct503-10G-09 ~]# sysctl -a | grep local_port_range
>> net.ipv4.ip_local_port_range =3D 10000 =C2=A061000
>>
>> I'm explicitly binding to local ports as well as local IPs, btw.
>>
>
> I believe the bsockets 'optimization' is a bug, we should remove it.
>
> This is a stable candidate (2.6.30+)
>
> [PATCH net-next-2.6] tcp: remove bsockets count
>
> Counting number of bound sockets to avoid a loop is buggy, since we c=
ant
> know how many IP addresses are in use. When threshold is reached, we =
try
> 5 random slots and can fail while there are plenty available ports.
>

Thank you a lot for the patch - I will try it.

In FreeBSD I was able to add about 32 C classes (8192 ips) on the
single interface (never tried to do that in Linux yet :) - so you
really never know how much IP's are there available. Tens and even up
to hundred IPs on the single machine are not that usual in hosting
environment at all.

/Gaspar
