From: Michal Simek <michal.simek@petalogix.com>
Subject: Re: Network performance - iperf
Date: Tue, 30 Mar 2010 11:34:29 +0200
Message-ID: <4BB1C5A5.5070202@petalogix.com>
References: <4BB09021.6020202@petalogix.com>	 <1269864994.2164.21.camel@edumazet-laptop> <4BB0BF28.5090505@petalogix.com>	 <4BB0C6E1.2090606@petalogix.com> <1269884717.1958.2.camel@edumazet-laptop>
Reply-To: michal.simek@petalogix.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080408020503010204010104"
Cc: LKML <linux-kernel@vger.kernel.org>,
	John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org, Grant Likely <grant.likely@secretlab.ca>,
	John Linn <John.Linn@xilinx.com>,
	"Steven J. Magnani" <steve@digidescorp.com>,
	Arnd Bergmann <arnd@arndb.de>, akpm@linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f223.google.com ([209.85.220.223]:32929 "EHLO
	mail-fx0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756028Ab0C3Jei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 05:34:38 -0400
In-Reply-To: <1269884717.1958.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080408020503010204010104
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Eric Dumazet wrote:
> Le lundi 29 mars 2010 à 17:27 +0200, Michal Simek a écrit :
>> Michal Simek wrote:
>>> Eric Dumazet wrote:
>>>> Le lundi 29 mars 2010 à 13:33 +0200, Michal Simek a écrit :
>>>>
>>>>> Do you have any idea howto improve TCP/UDP performance in general?
>>>>> Or tests which can point me on weak places.
>>>> Could you post "netstat -s" on your receiver, after fresh boot and your
>>>> iperf session, for 32 MB and 256 MB ram case ?
>>>>
>>> I am not sure if is helpful but look below.
>>>
>> Sorry I forget to c&p that second part. :-(
>>
> 
> Sorry, your netstat is not up2date.

I am afraid that is up2date.

> 
> If you cannot correct it to last version
> [ net-tools 1.60 , netstat 1.42 ], please send
> 
> cat /proc/net/snmp
> cat /proc/net/netstat

There is small buffer for parsing /proc/net/netstat.
There is necessary to extend buffer size because one line is greater 
than 1024 chars.

~ # head -n 1 /proc/net/netstat
TcpExt: SyncookiesSent SyncookiesRecv SyncookiesFailed EmbryonicRsts 
PruneCalled RcvPruned OfoPruned OutOfWindowIcmps LockDroppedIcmps 
ArpFilter TW TWRecycled TWKilled PAWSPassive PAWSActive PAWSEstab 
DelayedACKs DelayedACKLocked DelayedACKLost ListenOverflows ListenDrops 
TCPPrequeued TCPDirectCopyFromBacklog TCPDirectCopyFromPrequeue 
TCPPrequeueDropped TCPHPHits TCPHPHitsToUser TCPPureAcks TCPHPAcks 
TCPRenoRecovery TCPSackRecovery TCPSACKReneging TCPFACKReorder 
TCPSACKReorder TCPRenoReorder TCPTSReorder TCPFullUndo TCPPartialUndo 
TCPDSACKUndo TCPLossUndo TCPLoss TCPLostRetransmit TCPRenoFailures 
TCPSackFailures TCPLossFailures TCPFastRetrans TCPForwardRetrans 
TCPSlowStartRetrans TCPTimeouts TCPRenoRecoveryFail TCPSackRecoveryFail 
TCPSchedulerFailed TCPRcvCollapsed TCPDSACKOldSent TCPDSACKOfoSent 
TCPDSACKRecv TCPDSACKOfoRecv TCPAbortOnSyn TCPAbortOnData 
TCPAbortOnClose TCPAbortOnMemory TCPAbortOnTimeout TCPAbortOnLinger 
TCPAbortFailed TCPMemoryPressures TCPSACKDiscard TCPDSACKIgnoredOld 
TCPDSACKIgnoredNoUndo TCPSpuriousRTOs TCPMD5NotFound TCPMD5Unexpected 
TCPSackShifted TCPSackMerged TCPSackShiftFallback TCPBacklogDrop 
TCPMinTTLDrop

Look at attached patch.
And updated results are below.

Thanks,
Michal





256M

~ # iperf -s
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
[  6] local 192.168.0.10 port 5001 connected with 192.168.0.101 port 33261
[ ID] Interval       Transfer     Bandwidth
[  6]  0.0-50.2 sec  22.9 MBytes  3.83 Mbits/sec
~ # ./netstat -s
Ip:
     16618 total packets received
     0 forwarded
     0 incoming packets discarded
     16618 incoming packets delivered
     6490 requests sent out
Icmp:
     0 ICMP messages received
     0 input ICMP message failed.
     ICMP input histogram:
     0 ICMP messages sent
     0 ICMP messages failed
     ICMP output histogram:
Tcp:
     0 active connections openings
     1 passive connection openings
     0 failed connection attempts
     0 connection resets received
     0 connections established
     16618 segments received
     6490 segments send out
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
     2233 packets pruned from receive queue because of socket buffer overrun
     ArpFilter: 0
     1 delayed acks sent
     5519 packets header predicted
     TCPPureAcks: 2
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
     TCPRcvCollapsed: 207654
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
IpExt:
     InNoRoutes: 0
     InTruncatedPkts: 0
     InMcastPkts: 0
     OutMcastPkts: 0
     InBcastPkts: 0
     OutBcastPkts: 0
     InOctets: 24915880
     OutOctets: 337488
     InMcastOctets: 0
     OutMcastOctets: 0
     InBcastOctets: 0
     OutBcastOctets: 0
~ # ./netstat --version
net-tools 1.60
netstat 1.42 (2001-04-15)
Fred Baumgarten, Alan Cox, Bernd Eckenfels, Phil Blundell, Tuan Hoang 
and others
+NEW_ADDRT +RTF_IRTT +RTF_REJECT +FW_MASQUERADE -I18N
AF: (inet) +UNIX +INET -INET6 -IPX -AX25 -NETROM -X25 -ATALK -ECONET -ROSE
HW:  +ETHER -ARC +SLIP +PPP -TUNNEL -TR -AX25 -NETROM -X25 -FR -ROSE 
-ASH -SIT -FDDI -HIPPI -HDLC/LAPB
~ # head -n 1 /proc/meminfo
MemTotal:         257108 kB



32MB

~ # head -n 1 /proc/meminfo
MemTotal:          29920 kB
~ # iperf -s
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
[  6] local 192.168.0.10 port 5001 connected with 192.168.0.101 port 50088
[ ID] Interval       Transfer     Bandwidth
[  6]  0.0-50.0 sec    109 MBytes  18.3 Mbits/sec
~ # ./netstat -s
Ip:
     79040 total packets received
     0 forwarded
     0 incoming packets discarded
     79040 incoming packets delivered
     29655 requests sent out
Icmp:
     0 ICMP messages received
     0 input ICMP message failed.
     ICMP input histogram:
     0 ICMP messages sent
     0 ICMP messages failed
     ICMP output histogram:
Tcp:
     0 active connections openings
     1 passive connection openings
     0 failed connection attempts
     0 connection resets received
     0 connections established
     79040 segments received
     29655 segments send out
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
     9773 packets pruned from receive queue because of socket buffer overrun
     ArpFilter: 0
     1 delayed acks sent
     101 packets directly queued to recvmsg prequeue.
     558928 packets directly received from prequeue
     33274 packets header predicted
     378 packets header predicted and directly queued to user
     TCPPureAcks: 2
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
     TCPRcvCollapsed: 120195
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
IpExt:
     InNoRoutes: 0
     InTruncatedPkts: 0
     InMcastPkts: 0
     OutMcastPkts: 0
     InBcastPkts: 0
     OutBcastPkts: 0
     InOctets: 118232864
     OutOctets: 1542068
     InMcastOctets: 0
     OutMcastOctets: 0
     InBcastOctets: 0
     OutBcastOctets: 0
~ #










-- 
Michal Simek, Ing. (M.Eng)
PetaLogix - Linux Solutions for a Reconfigurable World
w: www.petalogix.com p: +61-7-30090663,+42-0-721842854 f: +61-7-30090663

--------------080408020503010204010104
Content-Type: text/x-patch;
 name="0001-Extend-buffer-size-because-line-size-is-greater-than.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0001-Extend-buffer-size-because-line-size-is-greater-than.pa";
 filename*1="tch"

>From e2d160e2e235103af3e08b5bbbc451982bc0fed0 Mon Sep 17 00:00:00 2001
From: Michal Simek <monstr@monstr.eu>
Date: Tue, 30 Mar 2010 10:45:06 +0200
Subject: [PATCH] Extend buffer size because line size is greater than 1024 chars

Error shown on console

UdpLite:
    InDatagrams: 0
    NoPorts: 0
    InErrors: 0
    OutDatagrams: 0
    RcvbufErrors: 0
    SndbufErrors: 0
error parsing /proc/net/snmp: Success

It is easy to check size of line which is necessary to check.

1151

Signed-off-by: Michal Simek <monstr@monstr.eu>
---
 statistics.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/statistics.c b/statistics.c
index a878df8..51beb8a 100644
--- a/statistics.c
+++ b/statistics.c
@@ -291,7 +291,7 @@ struct tabtab *newtable(struct tabtab *tabs, char *title)
 
 void process_fd(FILE *f)
 {
-    char buf1[1024], buf2[1024];
+    char buf1[2048], buf2[2048];
     char *sp, *np, *p;
     while (fgets(buf1, sizeof buf1, f)) {
 	int endflag;
-- 
1.5.5.1


--------------080408020503010204010104--
