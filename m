From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: TCP communication for raw image transmission
Date: Mon, 2 Jan 2012 19:00:31 +0100
Message-ID: <CAL8zT=jKGYPe+bi44m0ADWzr+h0Hx59oGUYZoYsuu5syQQ-N5g@mail.gmail.com>
References: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com>
 <1325519943.2375.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAL8zT=giNe46FYQYxPkbshVfyG-DvCTKS0RLdiN8Kz+e-x-JFw@mail.gmail.com>
 <1325521745.18116.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAL8zT=gbCmtNpw1Lot0P7zB+b_Kw911jhxsXCzO3JOBmMLRcFg@mail.gmail.com>
 <1325523137.18116.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1325523178.18116.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAL8zT=gA2pd8wJtBRRLSH_MKXOj3_FzfcXg7v705+8w-xdByLg@mail.gmail.com> <1325526085.18116.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:54276 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752747Ab2ABSAx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 13:00:53 -0500
Received: by wibhm6 with SMTP id hm6so8550217wib.19
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2012 10:00:52 -0800 (PST)
In-Reply-To: <1325526085.18116.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/2 Eric Dumazet <eric.dumazet@gmail.com>:
> Le lundi 02 janvier 2012 =C3=A0 18:20 +0100, Jean-Michel Hautbois a =C3=
=A9crit :
>
>> Here we go...
>>
>> Recv =C2=A0 Send =C2=A0 =C2=A0Send
>> Socket Socket =C2=A0Message =C2=A0Elapsed
>> Size =C2=A0 Size =C2=A0 =C2=A0Size =C2=A0 =C2=A0 Time =C2=A0 =C2=A0 =
Throughput
>> bytes =C2=A0bytes =C2=A0 bytes =C2=A0 =C2=A0secs. =C2=A0 =C2=A010^6b=
its/sec
>>
>> =C2=A087380 =C2=A016384 =C2=A016384 =C2=A0 =C2=A060.01 =C2=A0 =C2=A0=
 =C2=A021.79
>>
>> It is not very good, AFAIK.
>> CPU usage is between 17 and 35%.
>
> Ouch...
>
> Better find out what is happening before even starting coding
> anything...
>
> checkout "netstat -s" on both sender/receiver

OK, here are the results :
netserver is launched on the x86 side and the ARM and x86 are
connected through ethernet network via a switch. There is nobody on
this network.

On ARM side :
netperf -H 192.168.1.10 -l 60 -t TCP_STREAM
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.1.10 (192.168.1.10) port 0 AF_INET
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    60.02      22.01
/ # netstat -s
Ip:
    67326 total packets received
    4 with invalid addresses
    0 forwarded
    0 incoming packets discarded
    67322 incoming packets delivered
    133712 requests sent out
Icmp:
    0 ICMP messages received
    0 input ICMP message failed.
    ICMP input histogram:
    0 ICMP messages sent
    0 ICMP messages failed
    ICMP output histogram:
Tcp:
    4 active connections openings
    0 passive connection openings
    0 failed connection attempts
    0 connection resets received
    0 connections established
    67167 segments received
    133712 segments send out
    0 segments retransmited
    0 bad segments received.
    0 resets sent
Udp:
    0 packets received
    0 packets to unknown port received.
    0 packet receive errors
    0 packets sent
    0 receive buffer errors
    0 send buffer errors
UdpLite:
TcpExt:
    2 TCP sockets finished time wait in fast timer
    2 delayed acks sent
    18 packets directly queued to recvmsg prequeue.
    3 packet headers predicted
    127 acknowledgments not containing data payload received
    67026 predicted acknowledgments
IpExt:
    InBcastPkts: 155
    InOctets: 3511540
    OutOctets: 199739352
    InBcastOctets: 16072

On the x86 side :
netperf -H 192.168.1.10 -l 60 -t TCP_STREAM
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.1.10 (192.168.1.10) port 0 AF_INET
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    60.02      22.01
/ # netstat -s
Ip:
    67326 total packets received
    4 with invalid addresses
    0 forwarded
    0 incoming packets discarded
    67322 incoming packets delivered
    133712 requests sent out
Icmp:
    0 ICMP messages received
    0 input ICMP message failed.
    ICMP input histogram:
    0 ICMP messages sent
    0 ICMP messages failed
    ICMP output histogram:
Tcp:
    4 active connections openings
    0 passive connection openings
    0 failed connection attempts
    0 connection resets received
    0 connections established
    67167 segments received
    133712 segments send out
    0 segments retransmited
    0 bad segments received.
    0 resets sent
Udp:
    0 packets received
    0 packets to unknown port received.
    0 packet receive errors
    0 packets sent
    0 receive buffer errors
    0 send buffer errors
UdpLite:
TcpExt:
    2 TCP sockets finished time wait in fast timer
    2 delayed acks sent
    18 packets directly queued to recvmsg prequeue.
    3 packet headers predicted
    127 acknowledgments not containing data payload received
    67026 predicted acknowledgments
IpExt:
    InBcastPkts: 155
    InOctets: 3511540
    OutOctets: 199739352
    InBcastOctets: 16072


JM
