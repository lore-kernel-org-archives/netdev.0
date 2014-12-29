From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Marvell Kirkwood - MV643XX: near 100% UDP RX packet loss
Date: Mon, 29 Dec 2014 15:25:15 -0800
Message-ID: <54A1E2DB.2010309@hp.com>
References: <20141224001844.15e13db8@neptune.home>	<549C878B.3030308@hp.com> <20141227121727.20fe52c8@neptune.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org
To: =?windows-1252?Q?Bruno_Pr=E9mont?= <bonbons@linux-vserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t1613g.houston.hp.com ([15.240.0.71]:57875 "EHLO
	g9t1613g.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751453AbaL2XZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 18:25:21 -0500
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com [15.217.128.52])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by g9t1613g.houston.hp.com (Postfix) with ESMTPS id 9B77762620
	for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 23:25:20 +0000 (UTC)
In-Reply-To: <20141227121727.20fe52c8@neptune.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/27/2014 03:17 AM, Bruno Pr=E9mont wrote:
> On Thu, 25 December 2014 Rick Jones <rick.jones2@hp.com> wrote:
>>> Why are so many packets being discarded?
>>
>> You should also check the netstat statistics, particularly UDP on th=
e
>> receiving side.  Look before and after the test and see how they cha=
nge,
>> if at all.
>
> Here they go.
>
> Summary of numbers:
> iperf UDP run, 5 seconds @ 1Gb/s
>   lost 71216/71776 packets
>
>                                    before      after      delta
> ethtool:
>   rx_packets:                      420001     688424     268423
>   rx_bytes:                     433251917  809803463  376551546
>   rx_errors:                            0          0          0
>   rx_dropped:                           0          0          0
>   bad_octets_received:                  0          0          0
>   bad_frames_received:                  0          0          0
>   rx_discard:                      159691     323123     163432
>   rx_overrun:                           0          0          0
> netstat, udp:
>   packets received                  15559      16137        578
>   packets to unknown port received     18         18          0
>   packet receive errors             41599      83890      42291
>   packets sent                      34697      34770         73
>   receive buffer errors                 0          0          0
>   send buffer errors                    0          0          0
>

Well, it certainly looks like a decent fraction of your lost traffic ar=
e=20
UDP packet receive errors.  Overrunning the SO_RCVBUF on the receiving=20
side presumably.  You can either start walking-down the transmission=20
rate of the iperf client, or try a larger receive socket buffer size on=
=20
the iperf server, though that will only help if those drops are from th=
e=20
receiving side being only occasionally slower than the sending side.=20
You might also want to make sure the UDP datagrams being sent are huge=20
and so getting fragmented.  All it takes is to lose one fragment of an=20
IP datagram to render the entire datagram useless.

As for the rx_discard in the ethtool stats, someone more familiar with=20
the hardware will have to describe the various reasons for that stat to=
=20
be incremented.

rick jones
