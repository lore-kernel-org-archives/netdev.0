From: "Steve Magnani" <steve@digidescorp.com>
Subject: Re: Network performance - iperf
Date: Tue, 30 Mar 2010 07:11:51 -0500
Message-ID: <WC20100330121151.170078@digidescorp.com>
References: <4BB09021.6020202@petalogix.com>	 <1269864994.2164.21.camel@edumazet-laptop> <4BB0BF28.5090505@petalogix.com>	 <4BB0C6E1.2090606@petalogix.com> <1269884717.1958.2.camel@edumazet-laptop> <4BB1C5A5.5070202@petalogix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "LKML" <linux-kernel@vger.kernel.org>,
	"John Williams" <john.williams@petalogix.com>,
	netdev@vger.kernel.org, "Grant Likely" <grant.likely@secretlab.ca>,
	"John Linn" <John.Linn@xilinx.com>,
	"Arnd Bergmann" <arnd@arndb.de>, akpm@linux-foundation.org
To: "Michal Simek" <michal.simek@petalogix.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BB1C5A5.5070202@petalogix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Looks like a lot of time spent in tcp_collapse(). I think there is assu=
mption that the memcpys=20
involved in collapsing lead to better throughput than packet retransmit=
, which on our platforms=20
may not be the case. If so is there a way to tune when tcp_collapse get=
s invoked? I haven't=20
seen one.

Steve

-----Original Message-----
=46rom: Michal Simek <michal.simek@petalogix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>,  John Williams <john.williams@=
petalogix.com>,=20
netdev@vger.kernel.org, Grant Likely <grant.likely@secretlab.ca>,  John=
 Linn=20
<John.Linn@xilinx.com>, "Steven J. Magnani" <steve@digidescorp.com>,  A=
rnd Bergmann=20
<arnd@arndb.de>, akpm@linux-foundation.org
Date: Tue, 30 Mar 2010 11:34:29 +0200
Subject: Re: Network performance - iperf

> Eric Dumazet wrote:
> > Le lundi 29 mars 2010 =E0 17:27 +0200, Michal Simek a =E9crit :
> >> Michal Simek wrote:
> >>> Eric Dumazet wrote:
> >>>> Le lundi 29 mars 2010 =E0 13:33 +0200, Michal Simek a =E9crit :
> >>>>
> >>>>> Do you have any idea howto improve TCP/UDP performance in
> general?
> >>>>> Or tests which can point me on weak places.
> >>>> Could you post "netstat -s" on your receiver, after fresh boot a=
nd
> your
> >>>> iperf session, for 32 MB and 256 MB ram case ?
> >>>>
> >>> I am not sure if is helpful but look below.
> >>>
> >> Sorry I forget to c&p that second part. :-(
> >>
> >=20
> > Sorry, your netstat is not up2date.
>=20
> I am afraid that is up2date.
>=20
> >=20
> > If you cannot correct it to last version
> > [ net-tools 1.60 , netstat 1.42 ], please send
> >=20
> > cat /proc/net/snmp
> > cat /proc/net/netstat
>=20
> There is small buffer for parsing /proc/net/netstat.
> There is necessary to extend buffer size because one line is greater=20
> than 1024 chars.
>=20
> ~ # head -n 1 /proc/net/netstat
> TcpExt: SyncookiesSent SyncookiesRecv SyncookiesFailed EmbryonicRsts=20
> PruneCalled RcvPruned OfoPruned OutOfWindowIcmps LockDroppedIcmps=20
> ArpFilter TW TWRecycled TWKilled PAWSPassive PAWSActive PAWSEstab=20
> DelayedACKs DelayedACKLocked DelayedACKLost ListenOverflows ListenDro=
ps
> TCPPrequeued TCPDirectCopyFromBacklog TCPDirectCopyFromPrequeue=20
> TCPPrequeueDropped TCPHPHits TCPHPHitsToUser TCPPureAcks TCPHPAcks=20
> TCPRenoRecovery TCPSackRecovery TCPSACKReneging TCPFACKReorder=20
> TCPSACKReorder TCPRenoReorder TCPTSReorder TCPFullUndo TCPPartialUndo=
=20
> TCPDSACKUndo TCPLossUndo TCPLoss TCPLostRetransmit TCPRenoFailures=20
> TCPSackFailures TCPLossFailures TCPFastRetrans TCPForwardRetrans=20
> TCPSlowStartRetrans TCPTimeouts TCPRenoRecoveryFail TCPSackRecoveryFa=
il
> TCPSchedulerFailed TCPRcvCollapsed TCPDSACKOldSent TCPDSACKOfoSent=20
> TCPDSACKRecv TCPDSACKOfoRecv TCPAbortOnSyn TCPAbortOnData=20
> TCPAbortOnClose TCPAbortOnMemory TCPAbortOnTimeout TCPAbortOnLinger=20
> TCPAbortFailed TCPMemoryPressures TCPSACKDiscard TCPDSACKIgnoredOld=20
> TCPDSACKIgnoredNoUndo TCPSpuriousRTOs TCPMD5NotFound TCPMD5Unexpected=
=20
> TCPSackShifted TCPSackMerged TCPSackShiftFallback TCPBacklogDrop=20
> TCPMinTTLDrop
>=20
> Look at attached patch.
> And updated results are below.
>=20
> Thanks,
> Michal
>=20
>=20
>=20
>=20
>=20
> 256M
>=20
> ~ # iperf -s
> ------------------------------------------------------------
> Server listening on TCP port 5001
> TCP window size: 85.3 KByte (default)
> ------------------------------------------------------------
> [  6] local 192.168.0.10 port 5001 connected with 192.168.0.101 port
> 33261
> [ ID] Interval       Transfer     Bandwidth
> [  6]  0.0-50.2 sec  22.9 MBytes  3.83 Mbits/sec
> ~ # ./netstat -s
> Ip:
>      16618 total packets received
>      0 forwarded
>      0 incoming packets discarded
>      16618 incoming packets delivered
>      6490 requests sent out
> Icmp:
>      0 ICMP messages received
>      0 input ICMP message failed.
>      ICMP input histogram:
>      0 ICMP messages sent
>      0 ICMP messages failed
>      ICMP output histogram:
> Tcp:
>      0 active connections openings
>      1 passive connection openings
>      0 failed connection attempts
>      0 connection resets received
>      0 connections established
>      16618 segments received
>      6490 segments send out
>      0 segments retransmited
>      0 bad segments received.
>      0 resets sent
> Udp:
>      0 packets received
>      0 packets to unknown port received.
>      0 packet receive errors
>      0 packets sent
>      RcvbufErrors: 0
>      SndbufErrors: 0
> UdpLite:
>      InDatagrams: 0
>      NoPorts: 0
>      InErrors: 0
>      OutDatagrams: 0
>      RcvbufErrors: 0
>      SndbufErrors: 0
> TcpExt:
>      2233 packets pruned from receive queue because of socket buffer
> overrun
>      ArpFilter: 0
>      1 delayed acks sent
>      5519 packets header predicted
>      TCPPureAcks: 2
>      TCPHPAcks: 0
>      TCPRenoRecovery: 0
>      TCPSackRecovery: 0
>      TCPSACKReneging: 0
>      TCPFACKReorder: 0
>      TCPSACKReorder: 0
>      TCPRenoReorder: 0
>      TCPTSReorder: 0
>      TCPFullUndo: 0
>      TCPPartialUndo: 0
>      TCPDSACKUndo: 0
>      TCPLossUndo: 0
>      TCPLoss: 0
>      TCPLostRetransmit: 0
>      TCPRenoFailures: 0
>      TCPSackFailures: 0
>      TCPLossFailures: 0
>      TCPFastRetrans: 0
>      TCPForwardRetrans: 0
>      TCPSlowStartRetrans: 0
>      TCPTimeouts: 0
>      TCPRenoRecoveryFail: 0
>      TCPSackRecoveryFail: 0
>      TCPSchedulerFailed: 0
>      TCPRcvCollapsed: 207654
>      TCPDSACKOldSent: 0
>      TCPDSACKOfoSent: 0
>      TCPDSACKRecv: 0
>      TCPDSACKOfoRecv: 0
>      TCPAbortOnSyn: 0
>      TCPAbortOnData: 0
>      TCPAbortOnClose: 0
>      TCPAbortOnMemory: 0
>      TCPAbortOnTimeout: 0
>      TCPAbortOnLinger: 0
>      TCPAbortFailed: 0
>      TCPMemoryPressures: 0
>      TCPSACKDiscard: 0
>      TCPDSACKIgnoredOld: 0
>      TCPDSACKIgnoredNoUndo: 0
>      TCPSpuriousRTOs: 0
>      TCPMD5NotFound: 0
>      TCPMD5Unexpected: 0
>      TCPSackShifted: 0
>      TCPSackMerged: 0
>      TCPSackShiftFallback: 0
>      TCPBacklogDrop: 0
>      TCPMinTTLDrop: 0
> IpExt:
>      InNoRoutes: 0
>      InTruncatedPkts: 0
>      InMcastPkts: 0
>      OutMcastPkts: 0
>      InBcastPkts: 0
>      OutBcastPkts: 0
>      InOctets: 24915880
>      OutOctets: 337488
>      InMcastOctets: 0
>      OutMcastOctets: 0
>      InBcastOctets: 0
>      OutBcastOctets: 0
> ~ # ./netstat --version
> net-tools 1.60
> netstat 1.42 (2001-04-15)
> Fred Baumgarten, Alan Cox, Bernd Eckenfels, Phil Blundell, Tuan Hoang=
=20
> and others
> +NEW_ADDRT +RTF_IRTT +RTF_REJECT +FW_MASQUERADE -I18N
> AF: (inet) +UNIX +INET -INET6 -IPX -AX25 -NETROM -X25 -ATALK -ECONET
> -ROSE
> HW:  +ETHER -ARC +SLIP +PPP -TUNNEL -TR -AX25 -NETROM -X25 -FR -ROSE=20
> -ASH -SIT -FDDI -HIPPI -HDLC/LAPB
> ~ # head -n 1 /proc/meminfo
> MemTotal:         257108 kB
>=20
>=20
>=20
> 32MB
>=20
> ~ # head -n 1 /proc/meminfo
> MemTotal:          29920 kB
> ~ # iperf -s
> ------------------------------------------------------------
> Server listening on TCP port 5001
> TCP window size: 85.3 KByte (default)
> ------------------------------------------------------------
> [  6] local 192.168.0.10 port 5001 connected with 192.168.0.101 port
> 50088
> [ ID] Interval       Transfer     Bandwidth
> [  6]  0.0-50.0 sec    109 MBytes  18.3 Mbits/sec
> ~ # ./netstat -s
> Ip:
>      79040 total packets received
>      0 forwarded
>      0 incoming packets discarded
>      79040 incoming packets delivered
>      29655 requests sent out
> Icmp:
>      0 ICMP messages received
>      0 input ICMP message failed.
>      ICMP input histogram:
>      0 ICMP messages sent
>      0 ICMP messages failed
>      ICMP output histogram:
> Tcp:
>      0 active connections openings
>      1 passive connection openings
>      0 failed connection attempts
>      0 connection resets received
>      0 connections established
>      79040 segments received
>      29655 segments send out
>      0 segments retransmited
>      0 bad segments received.
>      0 resets sent
> Udp:
>      0 packets received
>      0 packets to unknown port received.
>      0 packet receive errors
>      0 packets sent
>      RcvbufErrors: 0
>      SndbufErrors: 0
> UdpLite:
>      InDatagrams: 0
>      NoPorts: 0
>      InErrors: 0
>      OutDatagrams: 0
>      RcvbufErrors: 0
>      SndbufErrors: 0
> TcpExt:
>      9773 packets pruned from receive queue because of socket buffer
> overrun
>      ArpFilter: 0
>      1 delayed acks sent
>      101 packets directly queued to recvmsg prequeue.
>      558928 packets directly received from prequeue
>      33274 packets header predicted
>      378 packets header predicted and directly queued to user
>      TCPPureAcks: 2
>      TCPHPAcks: 0
>      TCPRenoRecovery: 0
>      TCPSackRecovery: 0
>      TCPSACKReneging: 0
>      TCPFACKReorder: 0
>      TCPSACKReorder: 0
>      TCPRenoReorder: 0
>      TCPTSReorder: 0
>      TCPFullUndo: 0
>      TCPPartialUndo: 0
>      TCPDSACKUndo: 0
>      TCPLossUndo: 0
>      TCPLoss: 0
>      TCPLostRetransmit: 0
>      TCPRenoFailures: 0
>      TCPSackFailures: 0
>      TCPLossFailures: 0
>      TCPFastRetrans: 0
>      TCPForwardRetrans: 0
>      TCPSlowStartRetrans: 0
>      TCPTimeouts: 0
>      TCPRenoRecoveryFail: 0
>      TCPSackRecoveryFail: 0
>      TCPSchedulerFailed: 0
>      TCPRcvCollapsed: 120195
>      TCPDSACKOldSent: 0
>      TCPDSACKOfoSent: 0
>      TCPDSACKRecv: 0
>      TCPDSACKOfoRecv: 0
>      TCPAbortOnSyn: 0
>      TCPAbortOnData: 0
>      TCPAbortOnClose: 0
>      TCPAbortOnMemory: 0
>      TCPAbortOnTimeout: 0
>      TCPAbortOnLinger: 0
>      TCPAbortFailed: 0
>      TCPMemoryPressures: 0
>      TCPSACKDiscard: 0
>      TCPDSACKIgnoredOld: 0
>      TCPDSACKIgnoredNoUndo: 0
>      TCPSpuriousRTOs: 0
>      TCPMD5NotFound: 0
>      TCPMD5Unexpected: 0
>      TCPSackShifted: 0
>      TCPSackMerged: 0
>      TCPSackShiftFallback: 0
>      TCPBacklogDrop: 0
>      TCPMinTTLDrop: 0
> IpExt:
>      InNoRoutes: 0
>      InTruncatedPkts: 0
>      InMcastPkts: 0
>      OutMcastPkts: 0
>      InBcastPkts: 0
>      OutBcastPkts: 0
>      InOctets: 118232864
>      OutOctets: 1542068
>      InMcastOctets: 0
>      OutMcastOctets: 0
>      InBcastOctets: 0
>      OutBcastOctets: 0
> ~ #
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
>=20
> --=20
> Michal Simek, Ing. (M.Eng)
> PetaLogix - Linux Solutions for a Reconfigurable World
> w: www.petalogix.com p: +61-7-30090663,+42-0-721842854 f:
> +61-7-30090663
