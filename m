From: Michal Simek <monstr@monstr.eu>
Subject: Re: ICMP packets - ll_temac with Microblaze
Date: Wed, 21 Dec 2011 14:28:32 +0100
Message-ID: <4EF1DF00.1090309@monstr.eu>
References: <4EF1B0D9.2010007@monstr.eu>			 <1324463334.2728.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>			 <1324463452.2728.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>			 <4EF1B5BC.5020103@monstr.eu>			 <1324463838.2728.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>			 <4EF1B7E4.4010602@monstr.eu>			 <1324464308.2728.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>		 <1324465386.2728.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>		 <4EF1BEA4.7080005@monstr.eu>	 <1324466023.2728.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	 <4EF1C80B.4060701@monstr.eu> <1324471194.2728.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:54304 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413Ab1LUN2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 08:28:37 -0500
Received: by eekc4 with SMTP id c4so7530346eek.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 05:28:35 -0800 (PST)
In-Reply-To: <1324471194.2728.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 12:50 +0100, Michal Simek a =
=C3=A9crit :
>=20
>>> #define SOCK_MIN_RCVBUF (16384 + sizeof(struct sk_buff))
>>>
>> Doesn't work. :-(
>>
>=20
> Sorry, I have no idea where packet is dropped, I dont know your
> application.

Application is simple ping from Busybox - nothing special.


> You might send "netstat -s" output if you cant find it ...

~ # ./netstat -s
Ip:
     36 total packets received
     2 with invalid addresses
     0 forwarded
     0 incoming packets discarded
     34 incoming packets delivered
     34 requests sent out
Icmp:
     34 ICMP messages received
     0 input ICMP message failed.
     ICMP input histogram:
         echo replies: 34
     34 ICMP messages sent
     0 ICMP messages failed
     ICMP output histogram:
         echo request: 34
IcmpMsg:
         InType0: 34
         OutType8: 34
Tcp:
     0 active connections openings
     0 passive connection openings
     0 failed connection attempts
     0 connection resets received
     0 connections established
     0 segments received
     0 segments send out
     0 segments retransmited
     0 bad segments received.
     0 resets sent
Udp:
     0 packets received
     0 packets to unknown port received.
     0 packet receive errors
     0 packets sent
     RcvbufErrors: 0
     SndbufErrors: 0
UdpLite:
     InDatagrams: 0
     NoPorts: 0
     InErrors: 0
     OutDatagrams: 0
     RcvbufErrors: 0
     SndbufErrors: 0
TcpExt:
     ArpFilter: 0
     0 packets header predicted
     TCPPureAcks: 0
     TCPHPAcks: 0
     TCPRenoRecovery: 0
     TCPSackRecovery: 0
     TCPSACKReneging: 0
     TCPFACKReorder: 0
     TCPSACKReorder: 0
     TCPRenoReorder: 0
     TCPTSReorder: 0
     TCPFullUndo: 0
     TCPPartialUndo: 0
     TCPDSACKUndo: 0
     TCPLossUndo: 0
     TCPLoss: 0
     TCPLostRetransmit: 0
     TCPRenoFailures: 0
     TCPSackFailures: 0
     TCPLossFailures: 0
     TCPFastRetrans: 0
     TCPForwardRetrans: 0
     TCPSlowStartRetrans: 0
     TCPTimeouts: 0
     TCPRenoRecoveryFail: 0
     TCPSackRecoveryFail: 0
     TCPSchedulerFailed: 0
     TCPRcvCollapsed: 0
     TCPDSACKOldSent: 0
     TCPDSACKOfoSent: 0
     TCPDSACKRecv: 0
     TCPDSACKOfoRecv: 0
     TCPAbortOnSyn: 0
     TCPAbortOnData: 0
     TCPAbortOnClose: 0
     TCPAbortOnMemory: 0
     TCPAbortOnTimeout: 0
     TCPAbortOnLinger: 0
     TCPAbortFailed: 0
     TCPMemoryPressures: 0
     TCPSACKDiscard: 0
     TCPDSACKIgnoredOld: 0
     TCPDSACKIgnoredNoUndo: 0
     TCPSpuriousRTOs: 0
     TCPMD5NotFound: 0
     TCPMD5Unexpected: 0
     TCPSackShifted: 0
     TCPSackMerged: 0
     TCPSackShiftFallback: 0
     TCPBacklogDrop: 0
     TCPMinTTLDrop: 0
     TCPDeferAcceptDrop: 0
     IPReversePathFilter: 0
     TCPTimeWaitOverflow: 0
     TCPReqQFullDoCookies: 0
     TCPReqQFullDrop: 0
IpExt:
     InNoRoutes: 0
     InTruncatedPkts: 0
     InMcastPkts: 0
     OutMcastPkts: 0
     InBcastPkts: 0
     OutBcastPkts: 0
     InOctets: 4008
     OutOctets: 2856
     InMcastOctets: 0
     OutMcastOctets: 0
     InBcastOctets: 0
     OutBcastOctets: 0



> You spoke of ICMP message, I cant find a limit in this area ?

ok. Can you provide me any background why size should be setup by
size =3D SKB_WITH_OVERHEAD(ksize(data));
and not to use size which is passed to kmalloc in __alloc_skb.

In past I have seen some issues because of caches but this is not that
case because on QEMU (where cache is not modeled) everything works the =
same as on HW.

Below is the log what I see.

Thanks,
Michal


~ # ping -c 5 192.168.0.101
PING 192.168.0.101 (192.168.0.101): 56 data bytes

--- 192.168.0.101 ping statistics ---
5 packets transmitted, 0 packets received, 100% packet loss
~ # mount -t nfs -o nolock -o tcp 192.168.0.101:/tftpboot/nfs /mnt
~ # ls /mnt/ | head
0001-sd.patch
0001-syscalls-getdtablesize01-fix-for-missing-etc-hosts.patch
1
1-xils
2
arp
arp-mb
busybox
core
exec
~ # umount /mnt/
~ # ./netstat -s
Ip:
     36 total packets received
     2 with invalid addresses
     0 forwarded
     0 incoming packets discarded
     34 incoming packets delivered
     43 requests sent out
Icmp:
     5 ICMP messages received
     0 input ICMP message failed.
     ICMP input histogram:
         echo replies: 5
     5 ICMP messages sent
     0 ICMP messages failed
     ICMP output histogram:
         echo request: 5
IcmpMsg:
         InType0: 5
         OutType8: 5
Tcp:
     4 active connections openings
     0 passive connection openings
     0 failed connection attempts
     0 connection resets received
     0 connections established
     29 segments received
     38 segments send out
     0 segments retransmited
     0 bad segments received.
     0 resets sent
Udp:
     0 packets received
     0 packets to unknown port received.
     0 packet receive errors
     0 packets sent
     RcvbufErrors: 0
     SndbufErrors: 0
UdpLite:
     InDatagrams: 0
     NoPorts: 0
     InErrors: 0
     OutDatagrams: 0
     RcvbufErrors: 0
     SndbufErrors: 0
TcpExt:
     ArpFilter: 0
     1 delayed acks sent
     10 packets header predicted
     TCPPureAcks: 4
     TCPHPAcks: 6
     TCPRenoRecovery: 0
     TCPSackRecovery: 0
     TCPSACKReneging: 0
     TCPFACKReorder: 0
     TCPSACKReorder: 0
     TCPRenoReorder: 0
     TCPTSReorder: 0
     TCPFullUndo: 0
     TCPPartialUndo: 0
     TCPDSACKUndo: 0
     TCPLossUndo: 0
     TCPLoss: 0
     TCPLostRetransmit: 0
     TCPRenoFailures: 0
     TCPSackFailures: 0
     TCPLossFailures: 0
     TCPFastRetrans: 0
     TCPForwardRetrans: 0
     TCPSlowStartRetrans: 0
     TCPTimeouts: 0
     TCPRenoRecoveryFail: 0
     TCPSackRecoveryFail: 0
     TCPSchedulerFailed: 0
     TCPRcvCollapsed: 0
     TCPDSACKOldSent: 0
     TCPDSACKOfoSent: 0
     TCPDSACKRecv: 0
     TCPDSACKOfoRecv: 0
     TCPAbortOnSyn: 0
     TCPAbortOnData: 0
     TCPAbortOnClose: 0
     TCPAbortOnMemory: 0
     TCPAbortOnTimeout: 0
     TCPAbortOnLinger: 0
     TCPAbortFailed: 0
     TCPMemoryPressures: 0
     TCPSACKDiscard: 0
     TCPDSACKIgnoredOld: 0
     TCPDSACKIgnoredNoUndo: 0
     TCPSpuriousRTOs: 0
     TCPMD5NotFound: 0
     TCPMD5Unexpected: 0
     TCPSackShifted: 0
     TCPSackMerged: 0
     TCPSackShiftFallback: 0
     TCPBacklogDrop: 0
     TCPMinTTLDrop: 0
     TCPDeferAcceptDrop: 0
     IPReversePathFilter: 0
     TCPTimeWaitOverflow: 0
     TCPReqQFullDoCookies: 0
     TCPReqQFullDrop: 0
IpExt:
     InNoRoutes: 0
     InTruncatedPkts: 0
     InMcastPkts: 0
     OutMcastPkts: 0
     InBcastPkts: 0
     OutBcastPkts: 0
     InOctets: 11348
     OutOctets: 3752
     InMcastOctets: 0
     OutMcastOctets: 0
     InBcastOctets: 0
     OutBcastOctets: 0
~ #
~ #
~ # tcpdump
device eth0 entered promiscuous mode
tcpdump: listening on eth0
00:01:31.421191 192.168.0.101 > 192.168.0.100: icmp: echo request (DF)
00:01:31.479686 192.168.0.100 > 192.168.0.101: icmp: echo reply
00:01:31.442325 arp who-has 192.168.0.1 tell 192.168.0.100
00:01:31.446052 arp reply 192.168.0.1 is-at f4:ec:38:b2:6a:9e
00:01:31.446256 192.168.0.100.47044 > 192.168.0.1.53: 45191+ (44) (DF)
00:01:31.461859 192.168.0.1.53 > 192.168.0.100.47044: 45191 NXDomain 0/=
1/0 (121)
00:01:31.464125 192.168.0.100.41833 > 192.168.0.1.53: 37485+ (44) (DF)
00:01:31.478026 192.168.0.1.53 > 192.168.0.100.41833: 37485 NXDomain 0/=
1/0 (121)
00:01:31.481794 192.168.0.100.35138 > 192.168.0.1.53: 56594+ (42) (DF)
00:01:31.497202 192.168.0.1.53 > 192.168.0.100.35138: 56594 NXDomain 0/=
1/0 (119)
00:01:32.419130 192.168.0.101 > 192.168.0.100: icmp: echo request (DF)
00:01:32.419482 192.168.0.100 > 192.168.0.101: icmp: echo reply
00:01:33.418342 192.168.0.101 > 192.168.0.100: icmp: echo request (DF)
00:01:33.418693 192.168.0.100 > 192.168.0.101: icmp: echo reply
00:01:34.419327 192.168.0.101 > 192.168.0.100: icmp: echo request (DF)
00:01:34.419676 192.168.0.100 > 192.168.0.101: icmp: echo reply
00:01:35.418042 192.168.0.101 > 192.168.0.100: icmp: echo request (DF)
00:01:35.418406 192.168.0.100 > 192.168.0.101: icmp: echo reply
00:01:36.418923 192.168.0.101 > 192.168.0.100: icmp: echo request (DF)
00:01:36.419275 192.168.0.100 > 192.168.0.101: icmp: echo reply
00:01:36.459936 arp who-has 192.168.0.100 tell 192.168.0.1
00:01:36.460216 arp reply 192.168.0.100 is-at 0:a:35:0:19:15
00:01:37.418800 192.168.0.101 > 192.168.0.100: icmp: echo request (DF)
00:01:37.419149 192.168.0.100 > 192.168.0.101: icmp: echo reply
00:01:38.419247 192.168.0.101 > 192.168.0.100: icmp: echo request (DF)
00:01:38.419617 192.168.0.100 > 192.168.0.101: icmp: echo reply
00:01:39.418820 192.168.0.101 > 192.168.0.100: icmp: echo request (DF)
00:01:39.419169 192.168.0.100 > 192.168.0.101: icmp: echo reply
=03
56 packets received by filter
0 packets droppeddevice eth0 left promiscuous mode
  by kernel
~ #
~ # ping 192.168.0.101
PING 192.168.0.101 (192.168.0.101): 56 data bytes
=03
--- 192.168.0.101 ping statistics ---
2 packets transmitted, 0 packets received, 100% packet loss
~ # ping 192.168.0.1
PING 192.168.0.1 (192.168.0.1): 56 data bytes
=03
--- 192.168.0.1 ping statistics ---
1 packets transmitted, 0 packets received, 100% packet loss
~ # ping 192.168.0.101 -c 10 &
~ # PING 192.168.0.101 (192.168.0.101): 56 data bytes
~ # tcpdump
device eth0 entered promiscuous mode
tcpdump: listening on eth0
00:01:59.615918 192.168.0.100 > 192.168.0.101: icmp: echo request (DF)
00:01:59.619166 192.168.0.101 > 192.168.0.100: icmp: echo reply
00:01:59.636473 192.168.0.100.57212 > 192.168.0.1.53: 43026+ (44) (DF)
00:01:59.650838 192.168.0.1.53 > 192.168.0.100.57212: 43026 NXDomain 0/=
1/0 (121)
00:01:59.652915 192.168.0.100.41475 > 192.168.0.1.53: 28371+ (44) (DF)
00:01:59.666907 192.168.0.1.53 > 192.168.0.100.41475: 28371 NXDomain 0/=
1/0 (121)
00:01:59.670832 192.168.0.100.47770 > 192.168.0.1.53: 61908+ (42) (DF)
00:01:59.684921 192.168.0.1.53 > 192.168.0.100.47770: 61908 NXDomain 0/=
1/0 (119)
00:02:00.616493 192.168.0.100 > 192.168.0.101: icmp: echo request (DF)
00:02:00.620237 192.168.0.101 > 192.168.0.100: icmp: echo reply
00:02:00.624275 arp who-has 192.168.0.101 tell 192.168.0.100
00:02:00.627936 arp reply 192.168.0.101 is-at 0:22:15:fb:34:a1
00:02:01.617232 192.168.0.100 > 192.168.0.101: icmp: echo request (DF)
00:02:01.620980 192.168.0.101 > 192.168.0.100: icmp: echo reply
00:02:02.617962 192.168.0.100 > 192.168.0.101: icmp: echo request (DF)
00:02:02.621687 192.168.0.101 > 192.168.0.100: icmp: echo reply
00:02:03.618687 192.168.0.100 > 192.168.0.101: icmp: echo request (DF)
00:02:03.622389 192.168.0.101 > 192.168.0.100: icmp: echo reply
00:02:04.619414 192.168.0.100 > 192.168.0.101: icmp: echo request (DF)
00:02:04.623129 192.168.0.101 > 192.168.0.100: icmp: echo reply


42 packets received by filter
0 packets droppeddevice eth0 left promiscuous mode
  by kernel
~ #
--- 192.168.0.101 ping statistics ---
10 packets transmitted, 0 packets received, 100% packet loss

[1] + Done(1)                    ping 192.168.0.101 -c 10
~ #


--=20
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/=
fdt/
Microblaze U-BOOT custodian
