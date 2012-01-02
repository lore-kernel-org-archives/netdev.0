From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: TCP communication for raw image transmission
Date: Mon, 2 Jan 2012 19:02:33 +0100
Message-ID: <CAL8zT=h=mDNiDRVDo=jjcCjkyRGZ79iQiQLT3ZVRLb2PuC2ugg@mail.gmail.com>
References: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com>
 <1325519943.2375.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAL8zT=giNe46FYQYxPkbshVfyG-DvCTKS0RLdiN8Kz+e-x-JFw@mail.gmail.com>
 <1325521745.18116.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAL8zT=gbCmtNpw1Lot0P7zB+b_Kw911jhxsXCzO3JOBmMLRcFg@mail.gmail.com>
 <1325523137.18116.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1325523178.18116.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAL8zT=gA2pd8wJtBRRLSH_MKXOj3_FzfcXg7v705+8w-xdByLg@mail.gmail.com>
 <1325526085.18116.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CAL8zT=jKGYPe+bi44m0ADWzr+h0Hx59oGUYZoYsuu5syQQ-N5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:37073 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753242Ab2ABSCz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 13:02:55 -0500
Received: by wibhm6 with SMTP id hm6so8551309wib.19
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2012 10:02:54 -0800 (PST)
In-Reply-To: <CAL8zT=jKGYPe+bi44m0ADWzr+h0Hx59oGUYZoYsuu5syQQ-N5g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/2 Jean-Michel Hautbois <jhautbois@gmail.com>:
> 2012/1/2 Eric Dumazet <eric.dumazet@gmail.com>:
>> Le lundi 02 janvier 2012 =C3=A0 18:20 +0100, Jean-Michel Hautbois a =
=C3=A9crit :
>>
>>> Here we go...
>>>
>>> Recv =C2=A0 Send =C2=A0 =C2=A0Send
>>> Socket Socket =C2=A0Message =C2=A0Elapsed
>>> Size =C2=A0 Size =C2=A0 =C2=A0Size =C2=A0 =C2=A0 Time =C2=A0 =C2=A0=
 Throughput
>>> bytes =C2=A0bytes =C2=A0 bytes =C2=A0 =C2=A0secs. =C2=A0 =C2=A010^6=
bits/sec
>>>
>>> =C2=A087380 =C2=A016384 =C2=A016384 =C2=A0 =C2=A060.01 =C2=A0 =C2=A0=
 =C2=A021.79
>>>
>>> It is not very good, AFAIK.
>>> CPU usage is between 17 and 35%.
>>
>> Ouch...
>>
>> Better find out what is happening before even starting coding
>> anything...
>>
>> checkout "netstat -s" on both sender/receiver
>
> OK, here are the results :
> netserver is launched on the x86 side and the ARM and x86 are
> connected through ethernet network via a switch. There is nobody on
> this network.
>
> On ARM side :
> netperf -H 192.168.1.10 -l 60 -t TCP_STREAM
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
> 192.168.1.10 (192.168.1.10) port 0 AF_INET
> Recv =C2=A0 Send =C2=A0 =C2=A0Send
> Socket Socket =C2=A0Message =C2=A0Elapsed
> Size =C2=A0 Size =C2=A0 =C2=A0Size =C2=A0 =C2=A0 Time =C2=A0 =C2=A0 T=
hroughput
> bytes =C2=A0bytes =C2=A0 bytes =C2=A0 =C2=A0secs. =C2=A0 =C2=A010^6bi=
ts/sec
>
> =C2=A087380 =C2=A016384 =C2=A016384 =C2=A0 =C2=A060.02 =C2=A0 =C2=A0 =
=C2=A022.01
> / # netstat -s
> Ip:
> =C2=A0 =C2=A067326 total packets received
> =C2=A0 =C2=A04 with invalid addresses
> =C2=A0 =C2=A00 forwarded
> =C2=A0 =C2=A00 incoming packets discarded
> =C2=A0 =C2=A067322 incoming packets delivered
> =C2=A0 =C2=A0133712 requests sent out
> Icmp:
> =C2=A0 =C2=A00 ICMP messages received
> =C2=A0 =C2=A00 input ICMP message failed.
> =C2=A0 =C2=A0ICMP input histogram:
> =C2=A0 =C2=A00 ICMP messages sent
> =C2=A0 =C2=A00 ICMP messages failed
> =C2=A0 =C2=A0ICMP output histogram:
> Tcp:
> =C2=A0 =C2=A04 active connections openings
> =C2=A0 =C2=A00 passive connection openings
> =C2=A0 =C2=A00 failed connection attempts
> =C2=A0 =C2=A00 connection resets received
> =C2=A0 =C2=A00 connections established
> =C2=A0 =C2=A067167 segments received
> =C2=A0 =C2=A0133712 segments send out
> =C2=A0 =C2=A00 segments retransmited
> =C2=A0 =C2=A00 bad segments received.
> =C2=A0 =C2=A00 resets sent
> Udp:
> =C2=A0 =C2=A00 packets received
> =C2=A0 =C2=A00 packets to unknown port received.
> =C2=A0 =C2=A00 packet receive errors
> =C2=A0 =C2=A00 packets sent
> =C2=A0 =C2=A00 receive buffer errors
> =C2=A0 =C2=A00 send buffer errors
> UdpLite:
> TcpExt:
> =C2=A0 =C2=A02 TCP sockets finished time wait in fast timer
> =C2=A0 =C2=A02 delayed acks sent
> =C2=A0 =C2=A018 packets directly queued to recvmsg prequeue.
> =C2=A0 =C2=A03 packet headers predicted
> =C2=A0 =C2=A0127 acknowledgments not containing data payload received
> =C2=A0 =C2=A067026 predicted acknowledgments
> IpExt:
> =C2=A0 =C2=A0InBcastPkts: 155
> =C2=A0 =C2=A0InOctets: 3511540
> =C2=A0 =C2=A0OutOctets: 199739352
> =C2=A0 =C2=A0InBcastOctets: 16072
>
> On the x86 side :
> netperf -H 192.168.1.10 -l 60 -t TCP_STREAM
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
> 192.168.1.10 (192.168.1.10) port 0 AF_INET
> Recv =C2=A0 Send =C2=A0 =C2=A0Send
> Socket Socket =C2=A0Message =C2=A0Elapsed
> Size =C2=A0 Size =C2=A0 =C2=A0Size =C2=A0 =C2=A0 Time =C2=A0 =C2=A0 T=
hroughput
> bytes =C2=A0bytes =C2=A0 bytes =C2=A0 =C2=A0secs. =C2=A0 =C2=A010^6bi=
ts/sec
>
> =C2=A087380 =C2=A016384 =C2=A016384 =C2=A0 =C2=A060.02 =C2=A0 =C2=A0 =
=C2=A022.01
> / # netstat -s
> Ip:
> =C2=A0 =C2=A067326 total packets received
> =C2=A0 =C2=A04 with invalid addresses
> =C2=A0 =C2=A00 forwarded
> =C2=A0 =C2=A00 incoming packets discarded
> =C2=A0 =C2=A067322 incoming packets delivered
> =C2=A0 =C2=A0133712 requests sent out
> Icmp:
> =C2=A0 =C2=A00 ICMP messages received
> =C2=A0 =C2=A00 input ICMP message failed.
> =C2=A0 =C2=A0ICMP input histogram:
> =C2=A0 =C2=A00 ICMP messages sent
> =C2=A0 =C2=A00 ICMP messages failed
> =C2=A0 =C2=A0ICMP output histogram:
> Tcp:
> =C2=A0 =C2=A04 active connections openings
> =C2=A0 =C2=A00 passive connection openings
> =C2=A0 =C2=A00 failed connection attempts
> =C2=A0 =C2=A00 connection resets received
> =C2=A0 =C2=A00 connections established
> =C2=A0 =C2=A067167 segments received
> =C2=A0 =C2=A0133712 segments send out
> =C2=A0 =C2=A00 segments retransmited
> =C2=A0 =C2=A00 bad segments received.
> =C2=A0 =C2=A00 resets sent
> Udp:
> =C2=A0 =C2=A00 packets received
> =C2=A0 =C2=A00 packets to unknown port received.
> =C2=A0 =C2=A00 packet receive errors
> =C2=A0 =C2=A00 packets sent
> =C2=A0 =C2=A00 receive buffer errors
> =C2=A0 =C2=A00 send buffer errors
> UdpLite:
> TcpExt:
> =C2=A0 =C2=A02 TCP sockets finished time wait in fast timer
> =C2=A0 =C2=A02 delayed acks sent
> =C2=A0 =C2=A018 packets directly queued to recvmsg prequeue.
> =C2=A0 =C2=A03 packet headers predicted
> =C2=A0 =C2=A0127 acknowledgments not containing data payload received
> =C2=A0 =C2=A067026 predicted acknowledgments
> IpExt:
> =C2=A0 =C2=A0InBcastPkts: 155
> =C2=A0 =C2=A0InOctets: 3511540
> =C2=A0 =C2=A0OutOctets: 199739352
> =C2=A0 =C2=A0InBcastOctets: 16072
>
>
Sorry, bad copy/paste...
Here is the x86 side :
netstat -s
Ip:
    134157 total packets received
    14 with invalid addresses
    0 forwarded
    0 incoming packets discarded
    134079 incoming packets delivered
    67446 requests sent out
    84 outgoing packets dropped
    2 dropped because of missing route
Icmp:
    86 ICMP messages received
    0 input ICMP message failed.
    ICMP input histogram:
        destination unreachable: 86
    92 ICMP messages sent
    0 ICMP messages failed
    ICMP output histogram:
        destination unreachable: 92
IcmpMsg:
        InType3: 86
        OutType3: 92
Tcp:
    0 active connections openings
    4 passive connection openings
    0 failed connection attempts
    0 connection resets received
    0 connections established
    133712 segments received
    67167 segments send out
    0 segments retransmited
    0 bad segments received.
    0 resets sent
Udp:
    294 packets received
    92 packets to unknown port received.
    0 packet receive errors
    187 packets sent
    0 receive buffer errors
    0 send buffer errors
UdpLite:
TcpExt:
    1 delayed acks sent
    133689 packets directly queued to recvmsg prequeue.
    192786040 bytes directly received in process context from prequeue
    0 packet headers predicted
    133689 packets header predicted and directly queued to user
    14 acknowledgments not containing data payload received
IpExt:
    InBcastPkts: 140
    OutBcastPkts: 51
    InOctets: 199778186
    OutOctets: 3519013
    InBcastOctets: 14912
    OutBcastOctets: 6639
